//
//  ControlBoxVMSourceDialogViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/27.
//
import Foundation
import UIKit

class ControlBoxVMSourceDialogViewController: BaseViewController {
    
    @IBOutlet weak var dialog: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    static var userSelectSourceName = ""
    
    override func viewDidLoad() {
        print("ControlBoxVMSourceDialogViewController - viewDidLoad")
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ControlBoxVMSourceDialogViewController - viewWillAppear")
        ControlBoxVMSourceDialogViewController.userSelectSourceName = ""
    }
}


extension ControlBoxVMSourceDialogViewController{
    
    func setupUI(){
        self.dialog.layer.cornerRadius = 10
    }
    
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ControlBoxVMSourceDialogViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("ControlBoxVMSourceDialogViewController - click " + ControlBoxVWViewController.txListForUI[indexPath.item])
        ControlBoxVMSourceDialogViewController.userSelectSourceName = ControlBoxVWViewController.txListForUI[indexPath.item]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIEventHelper.ui_vw_switch_source), object: true)
        self.dismiss(animated: true, completion: nil)
    }
}


extension ControlBoxVMSourceDialogViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("currentTotalVideoWallSize = ")
        return ControlBoxVWViewController.txListForUI.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxVMSourceCollectionViewCell", for: indexPath) as! ControlBoxVMSourceCollectionViewCell
        cell.sourceName.text = ControlBoxVWViewController.txListForUI[indexPath.item]
        return cell
    }
}

extension ControlBoxVMSourceDialogViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.collectionView.frame.size.width/1.2), height: (self.collectionView.frame.size.height)/8)
        
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVMSourceDialogViewController.isPhone){
            return 10
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVMSourceDialogViewController.isPhone){
            return 20
        }else{
            return 12
        }
    }
}
