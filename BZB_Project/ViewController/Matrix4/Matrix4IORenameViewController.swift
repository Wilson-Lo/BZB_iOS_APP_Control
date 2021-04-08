//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 GoMax. All rights reserved.
//

import UIKit

class Matrix4IORenameViewController: BaseSocketViewController{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    var isIntput = true
    
    override func viewDidLoad() {
        print("Matrix4IORenameViewController-viewDidLoad")
        super.viewDidLoad()
        self.typeSegment.addTarget(self, action: #selector(segmentedTypeControlChanged(_:)), for: .valueChanged)
        
        //Observer mode with IORename4DialogViewController
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "IORename-reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoading), name: NSNotification.Name(rawValue: "IORename-showLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeLoading), name: NSNotification.Name(rawValue: "IORename-closeLoading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSuccessToast), name: NSNotification.Name(rawValue: "IORename-showSuccessToast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showFailToast), name: NSNotification.Name(rawValue: "IORename-showFailToast"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4IORenameViewController-viewWillAppear")
        super.viewWillAppear(true)
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4IORenameViewController-viewDidDisappear")
        
    }
    
    @objc func segmentedTypeControlChanged(_ sender: UISegmentedControl){
        print(sender.selectedSegmentIndex)
        
        self.showLoadingView()
        
        //check device type
        switch sender.selectedSegmentIndex {
            
        case 0://input
            self.isIntput = true
            break
        case 1://output
            self.isIntput = false
            break
            
        default:
            break
        }
        self.collectionView.reloadData()
        self.dismissLoadingView()
    }
}

/**
 * Observer mode with IORename4DialogViewController
 */
extension Matrix4IORenameViewController{
    
    @objc func reloadList(notification: NSNotification){
        print("IORename4ViewController-reloadList")
        self.collectionView.reloadData()
    }
    
    @objc func showLoading(notification: NSNotification){
        print("IORename4ViewController-showLoading")
        self.showLoadingView()
    }
    
    @objc func closeLoading(notification: NSNotification){
        print("IORename4ViewController-closeLoading")
        self.dismissLoadingView()
    }
    
    @objc func showSuccessToast(notification: NSNotification){
        print("IORename4ViewController-showSuccessToast")
        if(Matrix4IORenameViewController.isPhone){
            self.view.showToast(text: "Rename successfully !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
        }else{
            self.view.showToast(text: "Rename successfully !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
        }
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
        //self.dismissLoadingView()
    }
    
    @objc func showFailToast(notification: NSNotification){
        print("IORename4ViewController-showFailToast")
        if(Matrix4IORenameViewController.isPhone){
            self.view.showToast(text: "Rename failed !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
        }else{
            self.view.showToast(text: "Rename failed !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
        }
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
        //self.dismissLoadingView()
    }
}

extension Matrix4IORenameViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: IORename4DialogViewController.typeName) as! IORename4DialogViewController
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
        IORename4DialogViewController.userSelectedIndex = indexPath.item
        IORename4DialogViewController.userSelectedIndex = indexPath.item
        if(isIntput){
            IORename4DialogViewController.isInput = true
            vc.dialogTitle.text =  "Input \(indexPath.item + 1)"
            vc.editNewName.text = self.inputName[indexPath.item]
        }else{
            IORename4DialogViewController.isInput = false
            vc.dialogTitle.text =  "Output \(indexPath.item + 1)"
            vc.editNewName.text = self.outputName[indexPath.item]
        }
        
    }
}

extension Matrix4IORenameViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.inputName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IORenameCollectionViewCell", for: indexPath) as! IORenameCollectionViewCell
        if(isIntput){
            cell.deviceType.text = "Input \(indexPath.item + 1)"
            cell.deviceName.text = self.inputName[indexPath.item]
            cell.deviceType.backgroundColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
        }else{
            cell.deviceType.text = "Output \(indexPath.item + 1)"
            cell.deviceName.text = self.outputName[indexPath.item]
            cell.deviceType.backgroundColor = UIColor(red: 88/255, green: 177/255, blue: 243/255, alpha: 1)
        }
        return cell
    }
}


extension Matrix4IORenameViewController: UICollectionViewDelegateFlowLayout {
    
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
extension Matrix4IORenameViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4IORenameViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4IORenameViewController-disConnect ")
        
        self.dismissLoadingView()
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4IORenameViewController-onReadData - \(tag)")
        
        switch tag{
        
        case CmdHelper._5_cmd_get_io_name:
            print("Matrix4IORenameViewController-_5_cmd_get_io_name")
            self.parser4IOName(data: data)
            print("I/O count \(self.inputName.count)")
            self.collectionView.reloadData()
            break
            
        default:
            
            break
        }
        self.dismissLoadingView()
    }
    
}
