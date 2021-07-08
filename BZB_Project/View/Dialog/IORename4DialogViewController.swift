//
//  IORenameDialogViewController.swift
//
//  Created by Wilson Lo on 2021/03/31.
//  Copyright © 2021 GoMax-Electronics. All rights reserved.
//

import Foundation
import UIKit

class IORename4DialogViewController: BaseSocketViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dialogTitle: UILabel!
    
    @IBOutlet weak var editNewName: UITextField!
    
    static var userSelectedIndex = 0
    static var isInput = true
    
    @IBOutlet weak var btCancel: UIButton!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("IORename4DialogViewController-viewWillAppear")
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        print("IORename4DialogViewController-viewDidLoad")
        super.viewDidLoad()
        self.btCancel.layer.cornerRadius = 6
        editNewName.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        editNewName.delegate = self
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("IORename4DialogViewController-viewDidLoad")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 7
    }
    
    @IBAction func saveIORename(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IORename-showLoading"), object: nil)
        
        if(IORename4DialogViewController.isInput){
            if(IORename4DialogViewController.inputName.count > 0){
                print("IORename4DialogViewController input")
                IORename4DialogViewController.inputName[IORename4DialogViewController.userSelectedIndex] = editNewName.text!
            }else{
                
            }
        }else{
            if(IORename4DialogViewController.inputName.count > 0){
                print("IORename4DialogViewController output")
                IORename4DialogViewController.outputName[IORename4DialogViewController.userSelectedIndex] = editNewName.text!
            }else{
                
            }
        }
        
        var temp = ""
        
        if(IORename4DialogViewController.outputName.count > 0 ){
            for i in 0...(IORename4DialogViewController.outputName.count - 1){
                temp = temp + "0\(IORename4DialogViewController.outputName[i].length + 1)" + IORename4DialogViewController.outputName[i].toHexEncodedString()
            }
        }
        
        if(IORename4DialogViewController.inputName.count > 0 ){
            for i in 0...(IORename4DialogViewController.inputName.count - 1){
                temp = temp + "0\(IORename4DialogViewController.inputName[i].length + 1)" + IORename4DialogViewController.inputName[i].toHexEncodedString()
            }
        }
        
        
        var cmd = CmdHelper.cmd_4_x_4_set_io_name + String((temp.length/2), radix: 16) + temp
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._6_cmd_set_io_name))
        //  self.startCheckFeedbackTimer()
    }
}


extension IORename4DialogViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("IORename4DialogViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("IORename4DialogViewController-disConnect")
       // self.dismissLoadingView()
        self.view.makeToast(err)
    }
    
    func onReadData(data: Data, tag: Int) {
        print("IORename4DialogViewController-onReadData")
        switch tag{
        
        case CmdHelper._5_cmd_get_io_name:
            print("IORename4DialogViewController-_5_cmd_get_io_name")
            self.parser4IOName(data: data)
            break
            
        case CmdHelper._6_cmd_set_io_name:
            print("IORename4DialogViewController-_6_cmd_set_io_name")
            if(data.hexEncodedString().contains("aa")){
                print("set name successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IORename-showSuccessToast"), object: nil)
            }else{
                print("set name failed")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IORename-showFailToast"), object: nil)
            }
            break
            
        default:
            
            break
        }
    }
}
