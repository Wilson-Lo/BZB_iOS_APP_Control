//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 GoMax. All rights reserved.
//

import UIKit
import Network
import CryptoKit
import CocoaAsyncSocket
import CryptoSwift
import RSSelectionMenu
import Toast_Swift
import PopupDialog

class Matrix4LearnEDIDViewController: BaseSocketViewController{
    
    @IBOutlet weak var segmentedType: UISegmentedControl!
    @IBOutlet weak var btEDID: UIButton!
    @IBOutlet weak var btDevice: UIButton!
    @IBOutlet weak var btApply: UIButton!
    
    var menu: RSSelectionMenu<String>!
    var userSelectedEDIDIndex = 0
    var userSelectedDeviceIndex = 0
    var isDefault = true
    
    override func viewDidLoad() {
        print("Matrix4LearnEDIDViewController-viewDidLoad")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4LearnEDIDViewController-viewWillAppear")
        super.viewWillAppear(true)
        self.showLoadingView()
        initialUI()
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4LearnEDIDViewController-viewDidDisappear")
        // TcpSocketClient.sharedInstance.stopConnect()
    }
    
    //detect edid type (SegmentedControl)
    @objc func edidTypeChanged(_ sender: UISegmentedControl){
        self.userSelectedEDIDIndex = 0
        if(sender.selectedSegmentIndex == 0){
            self.isDefault = true
            DispatchQueue.main.async {
                self.btEDID.setTitle(CmdHelper.default_edid[self.userSelectedEDIDIndex], for: .init())
            }
        }else if(sender.selectedSegmentIndex == 1){
            self.isDefault = false
            DispatchQueue.main.async {
                if(self.outputName.count > 0){
                    self.btEDID.setTitle(self.outputName[self.userSelectedEDIDIndex], for: .init())
                }else{
                    self.btEDID.setTitle("N/A", for: .init())
                }
            }
        }
    }
}

extension Matrix4LearnEDIDViewController{
    
    func initialUI(){
        
        self.segmentedType.addTarget(self, action: #selector(edidTypeChanged(_:)), for: .valueChanged)
        
        let widthBtApply = btApply.widthAnchor.constraint(equalToConstant: 30.0)
        let heightBtApply = btApply.heightAnchor.constraint(equalToConstant: 30.0)
        NSLayoutConstraint.activate([widthBtApply, heightBtApply])
        self.btApply.layer.cornerRadius = 5
        self.btApply.layer.borderWidth = 1
        self.btApply.layer.borderColor = UIColor.black.cgColor
        
        if(Matrix4MappingViewController.isPhone){
            print("is phone")
            widthBtApply.constant = 80
            heightBtApply.constant = 40
        }else{
            print("is pad")
            widthBtApply.constant = 140
            heightBtApply.constant = 80
            self.segmentedType.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 32) ], for: .normal)
        }
    }
    
    func showDevicePopMenu(){
        
        print("showDevicePopMenu")
        
        DispatchQueue.main.async() {
            
            self.menu = RSSelectionMenu(dataSource: self.inputName) { (cell, name, indexPath) in
                cell.textLabel?.text = name
            }
            
            // provide selected items
            var selectedNames: [String] = []
            
            self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                selectedNames = selectedItems
                self.userSelectedDeviceIndex = index
                self.btDevice.setTitle(self.inputName[index], for: .init())
            }
            self.menu.show(from: self)
        }
    }
    
    func showEDIDPopMenu(){
        
        print("showEDIDPopMenu")
        
        DispatchQueue.main.async() {
            
            if(self.isDefault){
                self.menu = RSSelectionMenu(dataSource: CmdHelper.default_edid) { (cell, name, indexPath) in
                    cell.textLabel?.text = name
                }
            }else{
                self.menu = RSSelectionMenu(dataSource: self.outputName) { (cell, name, indexPath) in
                    cell.textLabel?.text = name
                }
            }
            
            // provide selected items
            var selectedNames: [String] = []
            
            self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                selectedNames = selectedItems
                self.userSelectedEDIDIndex = index
                if(self.isDefault){
                    self.btEDID.setTitle(CmdHelper.default_edid[index], for: .init())
                }else{
                    self.btEDID.setTitle(self.outputName[index], for: .init())
                }
            }
            self.menu.show(from: self)
        }
    }
}

//Button Click Event
extension Matrix4LearnEDIDViewController{
    
    @IBAction func btShowDeviceList(sender: UIButton) {
        self.showDevicePopMenu()
    }
    
    @IBAction func btShowEDIDList(sender: UIButton) {
        self.showEDIDPopMenu()
    }
    
    @IBAction func btApply(sender: UIButton) {
        
        self.showLoadingView()
        
        var cmd = ""
        
        if(isDefault){
            cmd = CmdHelper.cmd_4_x_4_learn_edid + "06" +  String(format:"%02X", self.userSelectedEDIDIndex + 1)
        }else{
            cmd = CmdHelper.cmd_4_x_4_learn_edid + "03" +  String(format:"%02X", self.userSelectedEDIDIndex + 1)
        }
        
        if(self.userSelectedDeviceIndex > 3){
            cmd = cmd + "f1"
        }else{
            cmd = cmd +  String(format:"%02X", self.userSelectedDeviceIndex + 1)
        }
        cmd = cmd + self.calCheckSum(data: cmd)
        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._12_cmd_learn_edid))
        // self.startCheckFeedbackTimer()
    }
}


//TCP Deleage
extension Matrix4LearnEDIDViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4LearnEDID-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4LearnEDID-disConnect ")
        
        self.dismissLoadingView()
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4LearnEDID-onReadData - \(tag)")
        
        switch tag{
        
        case CmdHelper._5_cmd_get_io_name:
            print("Matrix4LearnEDID-_5_cmd_get_io_name")
            self.parser4IOName(data: data)
            if(self.inputName.count > 0){
                self.btDevice.setTitle(self.inputName[self.userSelectedDeviceIndex], for: .init())
            }
            
            DispatchQueue.main.async(){
                if(self.isDefault){
                    self.btEDID.setTitle(CmdHelper.default_edid[self.userSelectedEDIDIndex], for: .init())
                }else{
                    self.btEDID.setTitle(self.outputName[self.userSelectedEDIDIndex], for: .init())
                }
            }
            break
            
        case CmdHelper._12_cmd_learn_edid:
            print("Matrix4LearnEDID-_12_cmd_learn_edid")
            if(data.hexEncodedString().contains("aa")){
                if(SettingsViewController.isPhone){
                    self.view.showToast(text: "Learn EDID Successfully !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                }else{
                    self.view.showToast(text: "Learn EDID Successfully !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                }
            }else{
                if(SettingsViewController.isPhone){
                    self.view.showToast(text: "Learn EDID failed !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                }else{
                    self.view.showToast(text: "Learn EDID failed !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                }
            }
            break
            
        default:
            
            break
        }
        self.dismissLoadingView()
    }
    
}
