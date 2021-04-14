//
//  MappingRenameDialogViewController.swift
//  GoMaxMatrix
//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 GoMax. All rights reserved.
//

import Foundation
import UIKit

class MappingRename4DialogViewController: BaseSocketViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var editNewName: UITextField!
    static var userSelectedMappingIndex = 0
    @IBOutlet weak var btCancel: UIButton!
    
    override func viewDidLoad() {
        print("MappingRename4DialogViewController-viewDidLoad")
        super.viewDidLoad()
        editNewName.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        editNewName.delegate = self
        self.btCancel.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("MappingRename4DialogViewController-viewWillAppear")
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
       
    @IBAction func closeBtnPressed(_ sender: Any) {
           self.dismiss(animated: true, completion: nil)
    }
       
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          // self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func saveMappingName(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
      //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLoading"), object: nil)
        self.mappingName[MappingRename4DialogViewController.userSelectedMappingIndex] = editNewName.text!
        var temp = ""
        for i in 0...(self.mappingName.count - 1){
            temp = temp + "0\(self.mappingName[i].length + 1)" + self.mappingName[i].toHexEncodedString()
        }
        
        var cmd = ""
        cmd = CmdHelper.cmd_4_x_4_set_mapping_name + String((temp.length/2), radix: 16) + temp
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._8_cmd_set_mapping_name))
        //  self.startCheckFeedbackTimer()
      
    }
}


extension MappingRename4DialogViewController:TcpSocketClientDeleage{
    
    func onConnect() {
        print("MappingRename4DialogViewController-onConnect")
       // self.dismissLoadingView()
        //self.view.makeToast("Connected to device successfully")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_mapping_name, number:UInt8(CmdHelper._7_cmd_get_mapping_name))
    }
    
    func disConnect(err: String) {
        print("MappingRename4DialogViewController-disConnect")
        self.dismissLoadingView()
       // self.view.makeToast(err)
    }
    
    func onReadData(data: Data, tag: Int) {
        print("MappingRename4DialogViewController-onReadData")
        switch tag {
            
        case CmdHelper._7_cmd_get_mapping_name:
            print("MappingRename4DialogViewController-_7_cmd_get_mapping_name")
            self.parserMappingName(data: data)
            break
            
        case CmdHelper._8_cmd_set_mapping_name:
            print("MappingRename4DialogViewController-_8_cmd_set_mapping_name")
            
            if(data.hexEncodedString().contains("aa")){
                print("Rename successfully")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSuccessToast"), object: nil)
                
            }else{
                print("Rename failed")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showFailToast"), object: nil)
            }
            //self.startCheckFeedbackTimer()
            break
            
        default:
            
            break
        }
        
    }
}
