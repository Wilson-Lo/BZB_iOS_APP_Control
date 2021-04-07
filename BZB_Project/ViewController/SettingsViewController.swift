//  SettingsViewController
//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit
import SwiftSocket
import CocoaAsyncSocket
import RSSelectionMenu
import CryptoKit
import CryptoSwift
import Foundation
import Toast_Swift
import SVProgressHUD
import SwiftyJSON
import RSSelectionMenu

class SettingsViewController: BaseViewController{
    
    
    @IBOutlet weak var btScan: UIButton!
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var textFieldDeviceIP: UITextField!
    
    let preferences = UserDefaults.standard
    var queueUDP: DispatchQueue!
    var udpSendSocket: UDPClient!
    var udpReceiveSocket: GCDAsyncUdpSocket!
    var deviceList: Array<Device> = []
    var menu: RSSelectionMenu<String>!
    var menuList: Array<String> = []
    
    //device info structure (mac & ip)
    struct Device {
        let mac: String
        let ip: String
    }
    
    override func viewDidLoad() {
        print("SettingsViewController-viewDidLoad")
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        initialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SettingsViewController-viewWillAppear")
        objectInitial()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("SettingsViewController-viewDidDisappear")
        self.queueUDP.async {
            
            if(self.udpSendSocket != nil){
                self.udpSendSocket.close()
            }
            if(self.udpReceiveSocket != nil){
                self.udpReceiveSocket.close()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}

extension SettingsViewController{
    
    //initial UI
    func initialUI(){
        
        if(!SettingsViewController.isPhone){
            //Scan button
            let widthConstraint = btScan.widthAnchor.constraint(equalToConstant: 30.0)
            let heightConstraint = btScan.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthConstraint, heightConstraint])
            //change button size to 50x50
            widthConstraint.constant = 50
            heightConstraint.constant = 50
            
            //Check button
            let widthBtCheckConstraint = btCheck.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtCheckConstraint = btCheck.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtCheckConstraint, heightBtCheckConstraint])
            //change button size to 50x50
            widthBtCheckConstraint.constant = 50
            heightBtCheckConstraint.constant = 50
            
            self.textFieldDeviceIP.frame.size.height = 500
        }
        
    }
    
    func objectInitial(){
        self.queueUDP = DispatchQueue(label: "com.bzb.udp", qos: DispatchQoS.userInitiated)
        
        self.udpReceiveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        self.queueUDP.async {
            do {
                self.udpReceiveSocket.setIPv4Enabled(true)
                self.udpReceiveSocket.setIPv6Enabled(false)
                try self.udpReceiveSocket.bind(toPort: 65088)
                try self.udpReceiveSocket.beginReceiving()
                print("socket create successful")
            } catch let error {
                print(error)
            }
            self.udpSendSocket = UDPClient.init(address: "255.255.255.255", port: 5002)
            self.udpSendSocket.enableBroadcast()
        }
        
        DispatchQueue.main.async(){
            if(self.preferences.value(forKey: CmdHelper.key_server_ip) != nil){
                self.textFieldDeviceIP.text = self.preferences.value(forKey: CmdHelper.key_server_ip) as! String
            }
        }
        
    }
}

extension SettingsViewController{
    
    @IBAction func saveIP(sender: UIButton) {
        if(self.textFieldDeviceIP.hasText){
            DispatchQueue.main.async(){
                self.preferences.set(self.textFieldDeviceIP.text, forKey: CmdHelper.key_server_ip)
                //self.view.makeToast("Save IP successful !", duration: 2.0, position: .bottom)
                if(SettingsViewController.isPhone){
                    self.view.showToast(text: "Save IP successful !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: false)
                }else{
                    self.view.showToast(text: "Save IP successful !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: false)
                }
            }
        }else{
            if(SettingsViewController.isPhone){
                self.view.showToast(text: "IP can't not be empty !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: false)
            }else{
                self.view.showToast(text: "IP can't not be empty !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: false)
            }
           // self.view.makeToast("IP can't not be empty !")
        }
    }
    
    @IBAction func sendUDP(sender: UIButton) {
        
        let queueUDP = DispatchQueue(label: "com.bzb.udp", qos: DispatchQoS.userInitiated)
        
        queueUDP.async {
            self.deviceList.removeAll()
            self.menuList.removeAll()
            
            self.showLoadingView()
            
            self.udpSendSocket.send(data: self.aesEncodeUDPCmd())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Change `2.0` to the desired number of seconds.
                if(self.deviceList.count > 0){
                    self.dismissLoadingView()
                    
                    DispatchQueue.main.async(){
                        //  self.dismissLoadingView()
                        var selectedNames: [String] = []
                        // create menu with data source -> here [String]
                        
                        for deviceInfo in self.deviceList{
                            self.menuList.append(deviceInfo.mac + "\n" + deviceInfo.ip)
                        }
                        
                        self.menu = RSSelectionMenu(dataSource: self.menuList) { (cell, name, indexPath) in
                            cell.textLabel?.text = name
                        }
                        // provide selected items
                        self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                            selectedNames = selectedItems
                            
                            print(self.deviceList[index])
                            
                            let selectedDevice   = self.deviceList[index]
                            self.textFieldDeviceIP.text = selectedDevice.ip
                            self.preferences.set(selectedDevice.ip, forKey: CmdHelper.key_server_ip)
                        }
                        self.menu.show(from: self)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.dismissLoadingView()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showAlert(message: "Can't find any devices")
                    }
                }
                print("times up")
            }
            
        }
    }
    
    //encode udp cmd
    func aesEncodeUDPCmd() -> [Byte]{
        var aes = [Byte]()
        do {
            let key = "qzy159pkn333rty2"
            let key1:Array<Byte> = [0x00, 0x0b, 0x80, 0x00, 0x45, 0x54, 0x48, 0x5f, 0x52, 0x45, 0x51, 0x00, 0x00,0x00,0x00,0x00]
            //use AES-128-ECB mode
            aes = try AES(key: key.bytes, blockMode: ECB(), padding: .noPadding).encrypt(key1)
        } catch {}
        
        return aes
    }
    
    //deocode udp feedback
    func aesDecode(data: Data) -> [Byte]{
        var aes = [Byte]()
        do {
            let key = "qzy159pkn333rty2"
            //use AES-128-ECB mode
            aes = try AES(key: key.bytes, blockMode: ECB(), padding: .noPadding).decrypt(data.bytes)
        } catch {}
        
        return aes
    }
}

extension SettingsViewController: GCDAsyncUdpSocketDelegate{
    
    //****** UDP ******
    private func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        print("didConnectToAddress");
    }
    
    private func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        print("didNotConnect \(String(describing: error))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
    
    private func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("didNotSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if(data != nil){
            
            var deviceInfo = aesDecode(data: data)
            
            if(deviceInfo.count > 0){
                print("receive")
                self.deviceList.append(Device(mac: "MAC:" + String(format:"%02X", deviceInfo[21]) + "-" + String(format:"%02X", deviceInfo[22]) + "-" + String(format:"%02X", deviceInfo[23]) + "-" + String(format:"%02X", deviceInfo[24]) + "-" + String(format:"%02X", deviceInfo[25]) + "-" + String(format:"%02X", deviceInfo[26]),ip: String(deviceInfo[27]) + "." + String(deviceInfo[28]) + "." + String(deviceInfo[29]) + "." + String(deviceInfo[30])))
            }
        }
    }
}
