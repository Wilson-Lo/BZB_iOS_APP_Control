//
//  ControlBoxMappingSourceDialogViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/28.
//

import Foundation
import UIKit

class ControlBoxMappingSourceDialogViewController: BaseViewController {
    
    @IBOutlet weak var rxNameLabel: UILabel!
    @IBOutlet weak var dialog: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    static var userSelectSourceIndex = 0
    static var userSelectSourceName = ""
    static var userSelectSourceIP = ""
    
    override func viewDidLoad() {
        print("ControlBoxMappingSourceDialogViewController - viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ControlBoxMappingSourceDialogViewController - viewWillAppear")
        ControlBoxMappingSourceDialogViewController.userSelectSourceIndex = 0
        self.rxNameLabel.text = ControlBoxMappingSourceDialogViewController.userSelectSourceName
    }
}

extension ControlBoxMappingSourceDialogViewController{
    
    func setupUI(){
        self.dialog.layer.cornerRadius = 10
    }
    
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_close_dialog), object: true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ControlBoxMappingSourceDialogViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("ControlBoxMappingSourceDialogViewController - click ")
        ControlBoxMappingSourceDialogViewController.userSelectSourceIndex = indexPath.item
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_switch_channel), object: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_close_dialog), object: true)
        self.dismiss(animated: true, completion: nil)
    }
}


extension ControlBoxMappingSourceDialogViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("currentTotalVideoWallSize = ")
        return ControlBoxMappingViewController.txOnlineList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxMappingSourceCollectionViewCell", for: indexPath) as! ControlBoxMappingSourceCollectionViewCell
        cell.sourceName.text = ControlBoxMappingViewController.txOnlineList[indexPath.item].name
        return cell
    }
}

extension ControlBoxMappingSourceDialogViewController: UICollectionViewDelegateFlowLayout {
    
    /// ?????? Collection View ?????? Super View?????????????????????????????????
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.collectionView.frame.size.width/1.2), height: (self.collectionView.frame.size.height)/8)
        
    }
    
    /// ?????????????????????????????????????????????????????????(???????????????)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVMSourceDialogViewController.isPhone){
            return 10
        }else{
            return 30
        }
    }
    
    /// ?????????????????????????????????????????????????????????(???????????????)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVMSourceDialogViewController.isPhone){
            return 20
        }else{
            return 12
        }
    }
}
