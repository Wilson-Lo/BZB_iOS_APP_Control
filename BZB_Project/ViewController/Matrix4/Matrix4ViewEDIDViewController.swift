//
//  Matrix4ViewEDIDViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/9.
//

import UIKit
import Network
import CryptoKit
import CocoaAsyncSocket
import CryptoSwift
import RSSelectionMenu
import Toast_Swift
import PopupDialog

class Matrix4ViewEDIDViewController: BaseSocketViewController{
    
    
    @IBOutlet weak var deviceBt: UIButton!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var edidTextView: UITextView!
    
    var isInput = true
    var userSelectedIndex = 0
    var menu: RSSelectionMenu<String>!
    
    override func viewDidLoad() {
        print("Matrix4ViewEDIDViewController-viewDidLoad")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4ViewEDIDViewController-viewDidLoad")
        super.viewWillAppear(true)
        self.edidTextView.layer.cornerRadius = 10
        self.typeSegment.addTarget(self, action: #selector(typeChanged(_:)), for: .valueChanged)
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4ViewEDIDViewController-viewDidLoad")
        
    }
    
    //detect edid type (SegmentedControl)
    @objc func typeChanged(_ sender: UISegmentedControl){
        print(sender.selectedSegmentIndex)
        self.edidTextView.text = ""
        if(sender.selectedSegmentIndex == 0){
            self.isInput = true
            DispatchQueue.main.async {
                if(self.inputName.count > 0){
                    self.deviceBt.setTitle(self.inputName[self.userSelectedIndex], for: .init())
                }else{
                    self.deviceBt.setTitle("N/A", for: .init())
                }
            }
        }else if(sender.selectedSegmentIndex == 1){
            self.isInput = false
            DispatchQueue.main.async {
                if(self.outputName.count > 0){
                    self.deviceBt.setTitle(self.outputName[self.userSelectedIndex], for: .init())
                }else{
                    self.deviceBt.setTitle("N/A", for: .init())
                }
            }
        }
        
        var cmd = ""
        if(self.isInput){
            var cmd = CmdHelper.cmd_4_x_4_get_input_edid + String(format:"%02X", self.userSelectedIndex + 1)
            cmd = cmd + self.calCheckSum(data: cmd)
            TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._13_cmd_get_edid))
            //self.startCheckFeedbackTimer()
        }else{
            var cmd = CmdHelper.cmd_4_x_4_get_output_edid + String(format:"%02X", self.userSelectedIndex + 1)
            cmd = cmd + self.calCheckSum(data: cmd)
            TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._13_cmd_get_edid))
            //    self.startCheckFeedbackTimer()
        }
    }
}

extension Matrix4ViewEDIDViewController{
    
    @IBAction func btSelectedDevice(sender: UIButton) {
        self.showDeviceListPopMenu()
    }
    
    func showDeviceListPopMenu(){
        
        print("showDeviceListPopMenu")
        
        DispatchQueue.main.async() {
            
            
            if(self.isInput){
                if(self.inputName.count > 0){
                    self.menu = RSSelectionMenu(dataSource: self.inputName) { (cell, name, indexPath) in
                        cell.textLabel?.text = name
                    }
                }
                self.menu.title = "Source Device"
            }else{
                if(self.inputName.count > 0){
                    self.menu = RSSelectionMenu(dataSource: self.outputName) { (cell, name, indexPath) in
                        cell.textLabel?.text = name
                    }
                }
                self.menu.title = "Screen Monitor"
            }
            
            // provide selected items
            var selectedNames: [String] = []
            
            self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                selectedNames = selectedItems
                var cmd = ""
                self.userSelectedIndex = index
                self.showLoadingView()
                
                if(self.isInput){
                    
                    self.deviceBt.setTitle(self.inputName[self.userSelectedIndex], for: .init())
                    
                    var cmd = CmdHelper.cmd_4_x_4_get_input_edid + String(format:"%02X", self.userSelectedIndex + 1)
                    cmd = cmd + self.calCheckSum(data: cmd)
                    TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._13_cmd_get_edid))
                    
                    
                    
                }else{
                    self.deviceBt.setTitle(self.outputName[self.userSelectedIndex], for: .init())
                    
                    
                    var cmd = CmdHelper.cmd_4_x_4_get_output_edid + String(format:"%02X", self.userSelectedIndex + 1)
                    cmd = cmd + self.calCheckSum(data: cmd)
                    TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._13_cmd_get_edid))
                    
                }
            }
            //self.startCheckFeedbackTimer()
            self.menu.show(from: self)
        }
    }
}




//TCP Deleage
extension Matrix4ViewEDIDViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4ViewEDIDViewController-onConnect")
        self.dismissLoadingView()
        var cmd = CmdHelper.cmd_4_x_4_get_input_edid + String(format:"%02X", 1)
        cmd = cmd + self.calCheckSum(data: cmd)
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4ViewEDIDViewController-disConnect")
        self.dismissLoadingView()
        self.view.makeToast(err)
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4ViewEDIDViewController-onReadData")
        
        switch tag {
        
        case CmdHelper._5_cmd_get_io_name:
            print("Matrix4ViewEDIDViewController-_5_cmd_get_io_name")
            self.parser4IOName(data: data)
            if(self.inputName.count > 0){
                
                if(isInput){
                    self.deviceBt.setTitle(self.inputName[self.userSelectedIndex], for: .init())
                }else{
                    self.deviceBt.setTitle(self.outputName[self.userSelectedIndex],for: .init())
                }
                var cmd = CmdHelper.cmd_4_x_4_get_input_edid + String(format:"%02X", 1)
                cmd = cmd + self.calCheckSum(data: cmd)
                TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._13_cmd_get_edid))
            }
            //self.startCheckFeedbackTimer()
            break
            
        case CmdHelper._13_cmd_get_edid:
            print("Matrix4ViewEDIDViewController-_13_cmd_get_edid")
            
            var strHexData = data.hexEncodedString()
            if(strHexData.length == 514){
                strHexData = String(strHexData.dropFirst(2))
            }
            
            var newInts: Array<UInt8> = Array()
            
            let characters = Array(strHexData)
            var subString = ""
            for character in characters {
                subString = subString + String(character)
                if(subString.count == 2){
                    newInts.append(UInt8(subString, radix: 16) ?? 0x00)
                    subString = ""
                }
            }
            
            let str = OCFile().parseEDID(intToUnsafeMutablePointer(array: newInts), withLen: 256)
            self.edidTextView.text = String(cString: str)
            break
            
        default:
            
            break
        }
        
        self.dismissLoadingView()
    }
    
    func intToUnsafeMutablePointer(array:Array<UInt8>)  -> UnsafeMutablePointer<UInt8>{
        var initalArray = array
        let pointer = UnsafeMutablePointer<UInt8>(&initalArray)
        return pointer
    }
}

