//
//  MappingRenameDialogViewController.swift
//  GoMaxMatrix
//
//  Created by Wilson on 2021/07/06.
//  Copyright © 2021 GoMax. All rights reserved.
//
import Foundation
import UIKit

class DeviceListDialogViewController: BaseViewController {
    
    
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var btDelete: UIButton!
    @IBOutlet weak var btToDevice: UIButton!
    var gradientLayer: CAGradientLayer!
    static var userSelectedDeviceType = 0
    static var userSelectedDeviceIndex = 0 // device list index
    override func viewDidLoad() {
        print("DeviceListDialogViewController-viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DeviceListDialogViewController-viewWillAppear")
    }
    
}


extension DeviceListDialogViewController{
    
    func setupUI(){
        self.dialogView.layer.cornerRadius = 20
        self.btDelete.layer.cornerRadius = 10
        self.btToDevice.layer.cornerRadius = 10
        self.btToDevice.layer.borderWidth = 1
        self.btToDevice.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func goToDeviceBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_event_go_to_device), object: nil)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_event_delete_device), object: nil)
      
    }
}
