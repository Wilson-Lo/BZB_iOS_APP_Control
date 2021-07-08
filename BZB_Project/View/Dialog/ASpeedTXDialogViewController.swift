//
//  File.swift
//  BZB_Project
//
//  Created by GoMax on 2021/7/7.
//

import Foundation
import UIKit

class ASpeedTXDialogViewController: BaseViewController {
    
 
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var dialog: UIView!
    @IBOutlet weak var btSwitchAll: UIButton!
    @IBOutlet weak var btBlinkredLight: UIButton!
    @IBOutlet weak var dialogHeight: NSLayoutConstraint!
    static var deviceIP = ""
    static var deviceGroupId = ""
    static var deviceName = ""
    
    override func viewDidLoad() {
        print("ASpeedTXDialogViewController-viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ASpeedTXDialogViewController-viewWillAppear")
        labelName.text = ASpeedTXDialogViewController.deviceName
    }
    
}


extension ASpeedTXDialogViewController{
    
    func setupUI(){
        
        if(UIScreen.main.bounds.height < 700){
            let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.26)
            self.view.removeConstraint(dialogHeight)
            self.view.addConstraint(newDialogHeightConstraint)
        }else{
            let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.2)
            self.view.removeConstraint(dialogHeight)
            self.view.addConstraint(newDialogHeightConstraint)
        }
        
        self.dialog.layer.cornerRadius = 20
        self.btSwitchAll.layer.cornerRadius = 10
        self.btSwitchAll.layer.borderWidth = 1
        self.btSwitchAll.layer.borderColor = UIColor.white.cgColor
        self.btBlinkredLight.layer.cornerRadius = 10
        self.btBlinkredLight.layer.borderWidth = 1
        self.btBlinkredLight.layer.borderColor = #colorLiteral(red: 0.8941176471, green: 0.262745098, blue: 0.2078431373, alpha: 1).cgColor
    }
    
    @IBAction func switchAllBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_tx_switch_all), object: nil)
    }
    
    @IBAction func blinkRedLightBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_tx_blink_red_light), object: nil)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
