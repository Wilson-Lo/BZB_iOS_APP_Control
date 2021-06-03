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
    
    @IBOutlet weak var collectionView: UICollectionView!
    let db = DBHelper()
    var deviceList: Array<DeviceDataObject>!
    var queueDB: DispatchQueue!
    
    override func viewDidLoad() {
        print("DeviceListViewController-viewDidLoad")
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DeviceListViewController-viewWillAppear")
        self.queueDB.async {
            self.deviceList = self.db.read()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("DeviceListViewController-viewDidAppear")
        
        if(self.deviceList != nil){
            if(self.deviceList.count > 0){
                self.collectionView.reloadData()
            }
        }
    }
    
}

extension DeviceListViewController{
    
    func setupUI(){
        
        self.queueDB = DispatchQueue(label: "com.bzb.db", qos: DispatchQoS.userInitiated)
        
        
        self.navigationController?.navigationBar.barTintColor = .black
        //        self.collectionView.layer.cornerRadius = 10
        //        self.collectionView.layer.borderWidth = 1
        //        self.collectionView.layer.borderColor = UIColor.black.cgColor
    }
    
    
    @IBAction func btAdd(sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! UIViewController
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
}

extension DeviceListViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        
        let title = "\n Select Action"
        let message = ""
        
        // Create the dialog,
        let popup = PopupDialog(title: title, message: message, image: nil)
        
        var btArray: Array<CancelButton> = []
        //        if(!DeviceListViewController.isPhone){
        //            let dialogAppearance = PopupDialogDefaultView.appearance()
        //            dialogAppearance.backgroundColor      = .white
        //            dialogAppearance.titleFont            = .boldSystemFont(ofSize: 32)
        //            //    dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        //            dialogAppearance.titleTextAlignment   = .center
        //            dialogAppearance.messageFont          = .systemFont(ofSize: 26)
        //            //   dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        //
        //            let cb = CancelButton.appearance()
        //            cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 26)!
        //        }
        
        btArray.append(CancelButton(title: "Go to device") {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Matrix4UITabBarController") as! UITabBarController
            self.navigationController!.pushViewController(nextViewController, animated: true)
        })
        
        btArray.append(CancelButton(title: "Delete") {
            var feedback = self.db.delete(id: self.deviceList[indexPath.item].id!)
            
            if(feedback){
                self.queueDB.async {
                    self.deviceList = self.db.read()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.collectionView.reloadData()
                }
            }else{
                
                
            }
        })
        
        popup.addButtons(btArray)
        self.present(popup, animated: true, completion: nil)
    }
}

extension DeviceListViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.deviceList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        cell.labelName.text = self.deviceList[indexPath.item].name
        cell.labelIP.text = self.deviceList[indexPath.item].ip
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
        
        return CGSize(width: (self.view.frame.size.width - 30) , height: (self.view.frame.size.width) / 5.6)
        
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
        
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 12
        
    }
}
