//
//  File.swift
//  BZB_Project
//
//  Created by GoMax on 2021/7/7.
//

import Foundation
import UIKit

class CustomDeviceListDialogViewController: BaseViewController {
    
    @IBOutlet weak var cancelBtWidth: NSLayoutConstraint!
    @IBOutlet weak var cancelBtHeight: NSLayoutConstraint!
    @IBOutlet weak var dialogWidth: NSLayoutConstraint!
    @IBOutlet weak var dialogHeight: NSLayoutConstraint!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var btMatrix4: UIButton!
    @IBOutlet weak var btDelete: UIButton!
    @IBOutlet weak var btControlBox: UIButton!

    @IBOutlet weak var btControlBoxHeight: NSLayoutConstraint!
    @IBOutlet weak var btMatrix4Height: NSLayoutConstraint!
    @IBOutlet weak var btDeleteHeight: NSLayoutConstraint!
    
    var gradientLayer: CAGradientLayer!
    static var userSelectedDeviceType = 0
    static var userSelectedDeviceIndex = 0 // device list index
    override func viewDidLoad() {
        print("CustomDeviceListDialogViewController-viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("CustomDeviceListDialogViewController-viewWillAppear")
    }
    
}


extension CustomDeviceListDialogViewController{
    
    func setupUI(){
        
        print("height = \(UIScreen.main.bounds.height)")
        if(CustomDeviceListDialogViewController.isPhone){
            if(UIScreen.main.bounds.height > 700){
                let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.28)
                self.view.removeConstraint(dialogHeight)
                self.view.addConstraint(newDialogHeightConstraint)
            }
        }else{
            //dialog size
            let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.23)
            self.view.removeConstraint(dialogHeight)
            self.view.addConstraint(newDialogHeightConstraint)

            let newDialogWidthConstraint = dialogWidth.constraintWithMultiplier(0.6)
            self.view.removeConstraint(dialogWidth)
            self.view.addConstraint(newDialogWidthConstraint)


            //cancel button size
            let newCancelBtHeightConstraint = cancelBtHeight.constraintWithMultiplier(0.12)
            self.view.removeConstraint(cancelBtHeight)
            self.view.addConstraint(newCancelBtHeightConstraint)

            let newCancelBtWidthConstraint = cancelBtWidth.constraintWithMultiplier(0.1)
            self.view.removeConstraint(cancelBtWidth)
            self.view.addConstraint(newCancelBtWidthConstraint)
            
            
            let newToControlBoxBtHeightConstraint = btControlBoxHeight.constraintWithMultiplier(0.14)
            self.view.removeConstraint(btControlBoxHeight)
            self.view.addConstraint(newToControlBoxBtHeightConstraint)
            
            let newToMatrix4BtHeightConstraint = btMatrix4Height.constraintWithMultiplier(0.14)
            self.view.removeConstraint(btMatrix4Height)
            self.view.addConstraint(newToMatrix4BtHeightConstraint)
            
            let newToDeleteBtHeightConstraint = btDeleteHeight.constraintWithMultiplier(0.14)
            self.view.removeConstraint(btDeleteHeight)
            self.view.addConstraint(newToDeleteBtHeightConstraint)
        }
 
        
        self.dialogView.layer.cornerRadius = 20
        self.btDelete.layer.cornerRadius = 10
        self.btMatrix4.layer.cornerRadius = 10
        self.btControlBox.layer.cornerRadius = 10
        self.btMatrix4.layer.cornerRadius = 10
        self.btMatrix4.layer.borderWidth = 1
        self.btMatrix4.layer.borderColor = UIColor.white.cgColor
        self.btControlBox.layer.cornerRadius = 10
        self.btControlBox.layer.borderWidth = 1
        self.btControlBox.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func goToControlBoxBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        CustomDeviceListDialogViewController.userSelectedDeviceType = self.DEVICE_CONTROL_BOX
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_event_go_to_custom_device), object: nil)
    }
    
    @IBAction func goToMatrix4BtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        CustomDeviceListDialogViewController.userSelectedDeviceType = self.DEVICE_MATRIX_4_X_4_HDR
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_event_go_to_custom_device), object: nil)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_event_delete_custom_device), object: nil)
    }
}
