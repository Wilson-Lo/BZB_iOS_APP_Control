//
//  Matrix4MappingRename.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/9.
//

import UIKit

class Matrix4PresetRenameViewController: BaseSocketViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        print("Matrix4PresetRenameViewController-viewDidLoad")
        self.createCollectionGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4PresetRenameViewController-viewDidLoad")
       // self.showLoadingView()
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoading), name: NSNotification.Name(rawValue: "showLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeLoading), name: NSNotification.Name(rawValue: "closeLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSuccessToast), name: NSNotification.Name(rawValue: "showSuccessToast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showFailToast), name: NSNotification.Name(rawValue: "showFailToast"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4PresetRenameViewController-viewDidLoad")
        
    }
    
    @objc func reloadList(notification: NSNotification){
        print("Matrix4PresetRenameViewController-reloadList")
        //load data here
        self.collectionView.reloadData()
    }
    
    @objc func showLoading(notification: NSNotification){
        print("Matrix4PresetRenameViewController-showLoading")
        //load data here
        self.showLoadingView()
    }
    
    @objc func closeLoading(notification: NSNotification){
        print("Matrix4PresetRenameViewController-closeLoading")
        //load data here
        self.dismissLoadingView()
    }
    
    @objc func showSuccessToast(notification: NSNotification){
        print("Matrix4PresetRenameViewController-showSuccessToast")
        //load data here
        self.view.makeToast("Rename successfully")
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_mapping_name, number:UInt8(CmdHelper._7_cmd_get_mapping_name))
    }
    
    @objc func showFailToast(notification: NSNotification){
        print("Matrix4PresetRenameViewController-showFailToast")
        //load data here
        self.view.makeToast("Rename failed")
    }
}

extension Matrix4PresetRenameViewController{
    //init collection area background color
    func createCollectionGradientLayer() {
        let bgView = UIView(frame: self.collectionView.bounds)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.155182302, green: 0.207787931, blue: 0.2941000462, alpha: 1).cgColor ,#colorLiteral(red: 0.09019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.collectionView?.backgroundView = bgView
    }
}

extension Matrix4PresetRenameViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: MappingRename4DialogViewController.typeName) as! MappingRename4DialogViewController
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
        MappingRename4DialogViewController.userSelectedMappingIndex = indexPath.item
        vc.dialogTitleLabel.text =  "Preset \(indexPath.item + 1)"
        if(indexPath.item < self.mappingName.count){
            vc.editNewName.text = self.mappingName[indexPath.item]
        }
    }
}

extension Matrix4PresetRenameViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MappingRenameCollectionViewCell", for: indexPath) as! MappingRenameCollectionViewCell
        if(self.mappingName.count > 3){
            cell.name.text = self.mappingName[indexPath.item]
        }
        cell.index.text = "Preset \(indexPath.item+1)"
        return cell
    }
}

extension Matrix4PresetRenameViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(Matrix4MappingViewController.isPhone){
            return CGSize(width: (self.view.frame.size.width - 30) / 2 , height: (self.view.frame.size.width - 30) / 2)
        }else{
            return CGSize(width: (self.view.frame.size.width) / 2.2 , height: (self.view.frame.size.height) / 8)
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
extension Matrix4PresetRenameViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4PresetRenameViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_mapping_name, number:UInt8(CmdHelper._7_cmd_get_mapping_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4PresetRenameViewController-disConnect")
        DispatchQueue.main.async() {
            self.showToast(context: "Can't connect to device !")
         //   self.dismissLoadingView()
        }
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4PresetRenameViewController-onReadData")
        switch tag{
        
        
        case CmdHelper._7_cmd_get_mapping_name:
            print("Matrix4PresetRenameViewController-_7_cmd_get_mapping_name")
            self.parserMappingName(data: data)
            self.collectionView.reloadData()
            break
            
        default:
            
            break
        }
        self.dismissLoadingView()
    }
}
