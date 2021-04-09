//
//  Matrix4MappingRename.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/9.
//

import UIKit

class Matrix4MappingRenameViewController: BaseSocketViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        print("Matrix4MappingRenameViewController-viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4MappingRenameViewController-viewDidLoad")
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoading), name: NSNotification.Name(rawValue: "showLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeLoading), name: NSNotification.Name(rawValue: "closeLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSuccessToast), name: NSNotification.Name(rawValue: "showSuccessToast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showFailToast), name: NSNotification.Name(rawValue: "showFailToast"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4MappingRenameViewController-viewDidLoad")
        
    }
    
    @objc func reloadList(notification: NSNotification){
        print("Matrix4MappingRenameViewController-reloadList")
        //load data here
        self.collectionView.reloadData()
    }
    
    @objc func showLoading(notification: NSNotification){
        print("Matrix4MappingRenameViewController-showLoading")
        //load data here
        self.showLoadingView()
    }
    
    @objc func closeLoading(notification: NSNotification){
        print("Matrix4MappingRenameViewController-closeLoading")
        //load data here
        self.dismissLoadingView()
    }
    
    @objc func showSuccessToast(notification: NSNotification){
        print("Matrix4MappingRenameViewController-showSuccessToast")
        //load data here
        self.view.makeToast("Rename successfully")
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_mapping_name, number:UInt8(CmdHelper._7_cmd_get_mapping_name))
    }
    
    @objc func showFailToast(notification: NSNotification){
        print("Matrix4MappingRenameViewController-showFailToast")
        //load data here
        self.view.makeToast("Rename failed")
    }
}

extension Matrix4MappingRenameViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: MappingRename4DialogViewController.typeName) as! MappingRename4DialogViewController
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
        MappingRename4DialogViewController.userSelectedMappingIndex = indexPath.item
        vc.dialogTitle.text =  "Mapping \(indexPath.item + 1)"
        vc.editNewName.text = self.mappingName[indexPath.item]
    }
}

extension Matrix4MappingRenameViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MappingRenameCollectionViewCell", for: indexPath) as! MappingRenameCollectionViewCell
        if(self.mappingName.count > 3){
            cell.name.text = self.mappingName[indexPath.item]
        }
        cell.index.text = "Mapping \(indexPath.item+1)"
        return cell
    }
}

extension Matrix4MappingRenameViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(Matrix4MappingViewController.isPhone){
            return CGSize(width: (self.view.frame.size.width - 30) / 2 , height: (self.view.frame.size.width - 30) / 2)
        }else{
            return CGSize(width: (self.view.frame.size.width - 60) / 2 , height: (self.view.frame.size.width - 170) / 2)
        }
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(Matrix4MappingViewController.isPhone){
            return 10
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(Matrix4MappingViewController.isPhone){
            return 10
        }else{
            return 12
        }
    }
}

//TCP Deleage
extension Matrix4MappingRenameViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4MappingRenameViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_mapping_name, number:UInt8(CmdHelper._7_cmd_get_mapping_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4MappingRenameViewController-disConnect")
        
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4MappingRenameViewController-onReadData")
        switch tag{
        
        
        case CmdHelper._7_cmd_get_mapping_name:
            print("Matrix4MappingViewController-_7_cmd_get_mapping_name")
            self.parserMappingName(data: data)
            self.collectionView.reloadData()
            break
            
        default:
            
            break
        }
        self.dismissLoadingView()
    }
}
