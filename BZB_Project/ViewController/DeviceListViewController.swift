//
//  DeviceListViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/6/2.
//

import UIKit
import RSSelectionMenu
import CryptoKit
import CryptoSwift
import Foundation
import Toast_Swift
import SVProgressHUD
import RSSelectionMenu
import PopupDialog

class DeviceListViewController: BaseViewController{
    
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mainView: UIView!
    var gradientLayer: CAGradientLayer!
    @IBOutlet weak var btAddHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btAddWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    let db = DBHelper()
    var deviceList: Array<DeviceDataObject>!
    var queueDB: DispatchQueue!
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DeviceListViewController-viewDidLoad")
        self.setupUI()
        
        //scan device
        NotificationCenter.default.addObserver(self, selector: #selector(goToDevice(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_event_go_to_device), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteDevice(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_event_delete_device), object: nil)
        
        //custom device
        NotificationCenter.default.addObserver(self, selector: #selector(goToCustomDevice(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_event_go_to_custom_device), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteCustomDevice(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_event_delete_custom_device), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("DeviceListViewController-viewWillAppear")
        self.createGradientLayer()
        self.queueDB.async {
            self.deviceList = self.db.read()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("DeviceListViewController-viewDidAppear")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if(self.deviceList != nil){
                if(self.deviceList.count > 0){
                    self.collectionView.reloadData()
                }else{
                    self.showToast(context: "Didn't register any devices !")
                }
            }
        }
    }
    
}

extension DeviceListViewController{
    
    func createMainGradientLayer() {
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.1803921569, green: 0.2431372549, blue: 0.337254902, alpha: 1).cgColor ,#colorLiteral(red: 0.05882352941, green: 0.09803921569, blue: 0.137254902, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        self.mainView.layer.addSublayer(gradientLayer)
    }
    
    func createGradientLayer() {
        
        let bgView = UIView(frame: self.collectionView.bounds)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.1803921569, green: 0.2431372549, blue: 0.337254902, alpha: 1).cgColor ,#colorLiteral(red: 0.03529411765, green: 0.05882352941, blue: 0.09803921569, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.collectionView?.backgroundView = bgView
    }
    
    func setupUI(){
        self.queueDB = DispatchQueue(label: "com.bzb.db", qos: DispatchQoS.userInitiated)
        self.navigationController?.navigationBar.barTintColor = UIColor(cgColor: #colorLiteral(red: 0.08523575506, green: 0.1426764978, blue: 0.2388794571, alpha: 1).cgColor )
        
        if(DeviceListViewController.isPhone){
            //bt add size
            let newbtScanHeightConstraint = btAddHeightConstraint.constraintWithMultiplier(0.0479911)
            self.view.removeConstraint(btAddHeightConstraint)
            self.view.addConstraint(newbtScanHeightConstraint)
            // self.view.layoutIfNeeded()
            let newbtScanWidthConstraint = btAddWidthConstraint.constraintWithMultiplier(0.103865)
            self.view.removeConstraint(btAddWidthConstraint)
            self.view.addConstraint(newbtScanWidthConstraint)
            self.view.layoutIfNeeded()
        }else{
            //bt add size
            let newbtScanHeightConstraint = btAddHeightConstraint.constraintWithMultiplier(0.032)
            self.view.removeConstraint(btAddHeightConstraint)
            self.view.addConstraint(newbtScanHeightConstraint)
            //self.view.layoutIfNeeded()
            let newbtScanWidthConstraint = btAddWidthConstraint.constraintWithMultiplier(0.052)
            self.view.removeConstraint(btAddWidthConstraint)
            self.view.addConstraint(newbtScanWidthConstraint)
            self.view.layoutIfNeeded()
        }
        
        if(!ControlBoxVWViewController.isPhone){
            let newLogoHeightConstraint = logoHeightConstraint.constraintWithMultiplier(0.08)
            self.view.removeConstraint(logoHeightConstraint)
            self.view.addConstraint(newLogoHeightConstraint)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btAdd(sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! UIViewController
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    
    /**
     * Recevie ui_event_go_to_device NSNotification
     */
    @objc func goToDevice(notification: NSNotification){
        print("DeviceListViewController - ui_event_go_to_device")
        
        self.queueDB.async {
            self.preferences.set(self.deviceList[DeviceListDialogViewController.userSelectedDeviceIndex].ip, forKey: CmdHelper.key_server_ip)
        }
        
        DispatchQueue.main.async() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            switch(DeviceListDialogViewController.userSelectedDeviceType){
            
            case self.DEVICE_CONTROL_BOX:
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ControlBoxUITabBarController") as! UITabBarController
                self.navigationController!.pushViewController(nextViewController, animated: true)
                break
                
            case self.DEVICE_MATRIX_4_X_4_HDR:
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Matrix4UITabBarController") as! UITabBarController
                self.navigationController!.pushViewController(nextViewController, animated: true)
                break
                
            default:
                
                break
            }
        }
    }
    
    @objc func goToCustomDevice(notification: NSNotification){
        print("DeviceListViewController - ui_event_go_to_device")
        
        self.queueDB.async {
            self.preferences.set(self.deviceList[CustomDeviceListDialogViewController.userSelectedDeviceIndex].ip, forKey: CmdHelper.key_server_ip)
        }
        
        DispatchQueue.main.async() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            switch(CustomDeviceListDialogViewController.userSelectedDeviceType){
            
            case self.DEVICE_CONTROL_BOX:
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ControlBoxUITabBarController") as! UITabBarController
                self.navigationController!.pushViewController(nextViewController, animated: true)
                break
                
            case self.DEVICE_MATRIX_4_X_4_HDR:
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Matrix4UITabBarController") as! UITabBarController
                self.navigationController!.pushViewController(nextViewController, animated: true)
                break
                
            default:
                
                break
            }
        }
    }
    
    /**
     * Recevie ui_event_delete_device NSNotification
     */
    @objc func deleteDevice(notification: NSNotification){
        
        print("DeviceListViewController - ui_event_delete_device")
        
        var feedback = false
        self.queueDB.async {
            feedback = self.db.delete(id: self.deviceList[DeviceListDialogViewController.userSelectedDeviceIndex].id!)
        }
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if(feedback){
                self.queueDB.async {
                    self.deviceList.removeAll()
                    self.deviceList = self.db.read()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.collectionView.reloadData()
                    self.dismissLoadingView()
                    self.showToast(context: "Delete successful !")
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showToast(context: "Delete failed !")
                    self.dismissLoadingView()
                }
            }
        }
    }
    
    /**
     * Recevie ui_event_delete_custom_device NSNotification
     */
    @objc func deleteCustomDevice(notification: NSNotification){
        
        print("DeviceListViewController - ui_event_delete_custom_device")
        
        var feedback = false
        self.queueDB.async {
            feedback = self.db.delete(id: self.deviceList[CustomDeviceListDialogViewController.userSelectedDeviceIndex].id!)
        }
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if(feedback){
                self.queueDB.async {
                    self.deviceList.removeAll()
                    self.deviceList = self.db.read()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.collectionView.reloadData()
                    self.dismissLoadingView()
                    self.showToast(context: "Delete successful !")
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showToast(context: "Delete failed !")
                    self.dismissLoadingView()
                }
            }
        }
    }
}

extension DeviceListViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("click ")
        
        if(self.deviceList[indexPath.item].type != self.DEVICE_CUSTOMER){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: DeviceListDialogViewController.typeName) as! DeviceListDialogViewController
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
            
            DeviceListDialogViewController.userSelectedDeviceIndex = indexPath.item
            
            switch(self.deviceList[indexPath.item].type){
            
            case self.DEVICE_CONTROL_BOX:
                DeviceListDialogViewController.userSelectedDeviceType = self.DEVICE_CONTROL_BOX
                break
                
            case self.DEVICE_MATRIX_4_X_4_HDR:
                DeviceListDialogViewController.userSelectedDeviceType = self.DEVICE_MATRIX_4_X_4_HDR
                break
                
            default:
                
                break
            }
            
        }else{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: CustomDeviceListDialogViewController.typeName) as! CustomDeviceListDialogViewController
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
            CustomDeviceListDialogViewController.userSelectedDeviceIndex = indexPath.item
        }
    }
}

extension DeviceListViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.deviceList != nil){
            return  self.deviceList.count
        }else{
            self.collectionView.reloadData()
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        if(indexPath.item < self.deviceList.count){
            cell.labelName.text = self.deviceList[indexPath.item].name
            cell.labelIP.text = self.deviceList[indexPath.item].ip
        }
        return cell
    }
}

extension DeviceListViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(DeviceListViewController.isPhone){
            return CGSize(width: (self.view.frame.size.width - 30) , height: (self.view.frame.size.width) / 5.6)
        }else{
            return CGSize(width: (self.view.frame.size.width * 0.8) , height: (self.view.frame.size.height) / 12)
        }
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if(DeviceListViewController.isPhone){
            return 18
        }else{
            return 24
        }
        
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(DeviceListViewController.isPhone){
            return 20
        }else{
            return 26
        }
    }
}
