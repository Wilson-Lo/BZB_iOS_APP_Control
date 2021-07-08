//
//  ASpeedRX.swift
//  BZB_Project
//
//  Created by GoMax on 2021/7/7.
//

import Foundation
import UIKit

class ASpeedRXDialogViewController: BaseViewController {
    
    static var deviceName = ""
    static var deviceIP = ""
    static var deviceGroupId = ""
    static var isMute = true
    @IBOutlet weak var switchVerticalDistance: NSLayoutConstraint!
    @IBOutlet weak var onVerticalDistance: NSLayoutConstraint!
    @IBOutlet weak var offVerticalDistance: NSLayoutConstraint!
    @IBOutlet weak var dialogHeight: NSLayoutConstraint!
    @IBOutlet weak var btBlinkRedLight: UIButton!
    @IBOutlet weak var btSwitchChannel: UIButton!
    @IBOutlet weak var dialog: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var muteSwitch: UISwitch!
    
    override func viewDidLoad() {
        print("ASpeedRXDialogViewController-viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ASpeedRXDialogViewController-viewWillAppear")
        labelName.text = ASpeedRXDialogViewController.deviceName
    }
    
}


extension ASpeedRXDialogViewController{
    
    func setupUI(){
        
        muteSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        self.dialog.layer.cornerRadius = 20
        self.btSwitchChannel.layer.cornerRadius = 10
        self.btSwitchChannel.layer.borderWidth = 1
        self.btSwitchChannel.layer.borderColor = UIColor.white.cgColor
        self.btBlinkRedLight.layer.cornerRadius = 10
        self.btBlinkRedLight.layer.borderWidth = 1
        self.btBlinkRedLight.layer.borderColor = #colorLiteral(red: 0.8941176471, green: 0.262745098, blue: 0.2078431373, alpha: 1).cgColor
        
        if(UIScreen.main.bounds.height < 700){
            switchVerticalDistance.constant = 28
            onVerticalDistance.constant = 28
            offVerticalDistance.constant = 28
            let newDialogHeightConstraint = dialogHeight.constraintWithMultiplier(0.36)
            self.view.removeConstraint(dialogHeight)
            self.view.addConstraint(newDialogHeightConstraint)
        }
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        ASpeedRXDialogViewController.isMute = value
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_mute), object: nil)
    }
    
    @IBAction func blinkRedLightBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_blink_red_light), object: nil)
    }
    
    @IBAction func switchChannelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_switch_channel), object: true)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
