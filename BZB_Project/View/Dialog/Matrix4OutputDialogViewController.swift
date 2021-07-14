//
//  File.swift
//  BZB_Project
//
//  Created by GoMax on 2021/7/8.
//

import Foundation
import UIKit

class Matrix4OutputDialogViewController: BaseSocketViewController {
    
    static var inputIndex = 0
    static var outputIndex = 0
  
    @IBOutlet weak var dialog: UIView!
    @IBOutlet weak var btInput1: UIButton!
    @IBOutlet weak var btInput2: UIButton!
    @IBOutlet weak var btInput3: UIButton!
    @IBOutlet weak var btInput4: UIButton!
    @IBOutlet weak var btMute: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dialogHeight: NSLayoutConstraint!
    @IBOutlet weak var dialogWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        print("Matrix4OutputDialogViewController - viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4OutputDialogViewController - viewWillAppear")
        if(Matrix4OutputDialogViewController.inputName.count == 4){
            self.btInput1.setTitle(Matrix4OutputDialogViewController.inputName[0], for: .normal)
            self.btInput2.setTitle(Matrix4OutputDialogViewController.inputName[1], for: .normal)
            self.btInput3.setTitle(Matrix4OutputDialogViewController.inputName[2], for: .normal)
            self.btInput4.setTitle(Matrix4OutputDialogViewController.inputName[3], for: .normal)
        }
        
        if(Matrix4OutputDialogViewController.outputName.count == 4){
            self.nameLabel.text = Matrix4OutputDialogViewController.outputName[Matrix4OutputDialogViewController.outputIndex]
        }
    }
}


extension Matrix4OutputDialogViewController{
    
    func setupUI(){
        self.dialog.layer.cornerRadius = 10
        
        self.btInput1.layer.cornerRadius = 10
        self.btInput1.layer.borderWidth = 1
        self.btInput1.layer.borderColor = UIColor.white.cgColor
        
        self.btInput2.layer.cornerRadius = 10
        self.btInput2.layer.borderWidth = 1
        self.btInput2.layer.borderColor = UIColor.white.cgColor
        
        self.btInput3.layer.cornerRadius = 10
        self.btInput3.layer.borderWidth = 1
        self.btInput3.layer.borderColor = UIColor.white.cgColor
        
        self.btInput4.layer.cornerRadius = 10
        self.btInput4.layer.borderWidth = 1
        self.btInput4.layer.borderColor = UIColor.white.cgColor
        
        self.btMute.layer.cornerRadius = 10
        self.btMute.layer.borderWidth = 1
        self.btMute.layer.borderColor = #colorLiteral(red: 0.8941176471, green: 0.262745098, blue: 0.2078431373, alpha: 1).cgColor
        
        if(Matrix4OutputDialogViewController.isPhone){
            if(UIScreen.main.bounds.height < 700){
                let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.52)
                self.view.removeConstraint(dialogHeight)
                self.view.addConstraint(newDialogHeightConstraint)
            }
        }else{
            let newDialogWidthConstraint = dialogWidth.constraintWithMultiplier(0.6)
            self.view.removeConstraint(dialogWidth)
            self.view.addConstraint(newDialogWidthConstraint)
            
            let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.3)
            self.view.removeConstraint(dialogHeight)
            self.view.addConstraint(newDialogHeightConstraint)
        }
    }
    
    @IBAction func input1BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4OutputDialogViewController.inputIndex = 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_output), object: true)
    }
    
    @IBAction func input2BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4OutputDialogViewController.inputIndex = 2
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_output), object: true)
    }
    
    @IBAction func input3BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4OutputDialogViewController.inputIndex = 3
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_output), object: true)
    }
    
    @IBAction func input4BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4OutputDialogViewController.inputIndex = 4
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_output), object: true)
    }
    
    @IBAction func muteBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_mute_from_output), object: true)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
