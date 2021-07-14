//
//  File.swift
//  BZB_Project
//
//  Created by GoMax on 2021/7/8.
//

import Foundation
import UIKit

class Matrix4InputDialogViewController: BaseSocketViewController {
    
    
    @IBOutlet weak var inputNameLabel: UILabel!
    static var inputIndex = 0
    static var outputIndex = 0
    @IBOutlet weak var dialog: UIView!
    @IBOutlet weak var btOutput1: UIButton!
    @IBOutlet weak var btOutput2: UIButton!
    @IBOutlet weak var btOutput3: UIButton!
    @IBOutlet weak var btOutput4: UIButton!
    @IBOutlet weak var dialogHeight: NSLayoutConstraint!
    @IBOutlet weak var dialogWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        print("Matrix4InputDialogViewController-viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4InputDialogViewController-viewWillAppear")
        if(Matrix4InputDialogViewController.outputName.count == 4){
            self.btOutput1.setTitle(Matrix4InputDialogViewController.outputName[0], for: .normal)
            self.btOutput2.setTitle(Matrix4InputDialogViewController.outputName[1], for: .normal)
            self.btOutput3.setTitle(Matrix4InputDialogViewController.outputName[2], for: .normal)
            self.btOutput4.setTitle(Matrix4InputDialogViewController.outputName[3], for: .normal)
        }
        
        if(Matrix4InputDialogViewController.inputName.count == 4){
            self.inputNameLabel.text = Matrix4InputDialogViewController.inputName[Matrix4InputDialogViewController.inputIndex]
        }
    }
}


extension Matrix4InputDialogViewController{
    
    func setupUI(){
        
        self.dialog.layer.cornerRadius = 10
        
        self.btOutput1.layer.cornerRadius = 10
        self.btOutput1.layer.borderWidth = 1
        self.btOutput1.layer.borderColor = UIColor.white.cgColor
        
        self.btOutput2.layer.cornerRadius = 10
        self.btOutput2.layer.borderWidth = 1
        self.btOutput2.layer.borderColor = UIColor.white.cgColor
        
        self.btOutput3.layer.cornerRadius = 10
        self.btOutput3.layer.borderWidth = 1
        self.btOutput3.layer.borderColor = UIColor.white.cgColor
        
        self.btOutput4.layer.cornerRadius = 10
        self.btOutput4.layer.borderWidth = 1
        self.btOutput4.layer.borderColor = UIColor.white.cgColor
        
        if(Matrix4InputDialogViewController.isPhone){
            if(UIScreen.main.bounds.height < 700){
                let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.44)
                self.view.removeConstraint(dialogHeight)
                self.view.addConstraint(newDialogHeightConstraint)
            }
        }else{
            let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.25)
            self.view.removeConstraint(dialogHeight)
            self.view.addConstraint(newDialogHeightConstraint)
            
            let newDialogWidthConstraint = dialogWidth.constraintWithMultiplier(0.6)
            self.view.removeConstraint(dialogWidth)
            self.view.addConstraint(newDialogWidthConstraint)
            
        }
    }
    
    @IBAction func output1BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4InputDialogViewController.outputIndex = 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_input), object: true)
    }
    
    @IBAction func output2BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4InputDialogViewController.outputIndex = 2
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_input), object: true)
    }
    
    @IBAction func output3BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4InputDialogViewController.outputIndex = 3
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_input), object: true)
    }
    
    @IBAction func output4BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Matrix4InputDialogViewController.outputIndex = 4
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_input), object: true)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
