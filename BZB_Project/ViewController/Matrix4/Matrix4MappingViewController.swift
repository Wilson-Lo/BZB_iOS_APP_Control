//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 GoMax. All rights reserved.
//
import UIKit
import Network
import CryptoKit
import CocoaAsyncSocket
import CryptoSwift
import RSSelectionMenu
import Toast_Swift
import PopupDialog

class Matrix4MappingViewController: BaseSocketViewController{
    

    @IBOutlet weak var collectionInput: UICollectionView!
    
    @IBOutlet weak var collectionOutput: UICollectionView!
    
    var saveMappingMenu: RSSelectionMenu<String>!
    var deviceSourceStatus: Array<Int> = []
    
    override func viewDidLoad() {
        print("Matrix4MappingViewController-viewDidLoad")
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4MappingViewController-viewWillAppear")
        super.viewWillAppear(true)
        initialUI()
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4MappingViewController-viewDidDisappear")
        //  TcpSocketClient.sharedInstance.stopConnect()
        
    }
    
}

extension Matrix4MappingViewController{
    
    func initialUI(){
        if(Matrix4MappingViewController.isPhone){
            print("is phone")
            //Refresh button
//            let widthBtRefresh = btRefresh.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtRefresh = btRefresh.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtRefresh, heightBtRefresh])
//            widthBtRefresh.constant = 50
//            heightBtRefresh.constant = 50
//
//            //Save button
//            let widthBtSave = btSave.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtSave = btSave.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtSave, heightBtSave])
//            widthBtSave.constant = 50
//            heightBtSave.constant = 50
//
//            //Recall button
//            let widthBtRecall = btRecall.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtRecall = btRecall.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtRecall, heightBtRecall])
//            widthBtRecall.constant = 80
//            heightBtRecall.constant = 56
//            self.btRecall.layer.cornerRadius = 5
//            self.btRecall.layer.borderWidth = 1
//            self.btRecall.layer.borderColor = UIColor.black.cgColor
//
//            //All button
//            let widthBtAll = btAll.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtAll = btAll.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtAll, heightBtAll])
//            widthBtAll.constant = 80
//            heightBtAll.constant = 56
//            self.btAll.layer.cornerRadius = 5
//            self.btAll.layer.borderWidth = 1
//            self.btAll.layer.borderColor = UIColor.black.cgColor
//
        }else{
            print("is pad")
            //Refresh button
//            let widthBtRefresh = btRefresh.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtRefresh = btRefresh.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtRefresh, heightBtRefresh])
//            //change button size to 50x50
//            widthBtRefresh.constant = 80
//            heightBtRefresh.constant = 80
//
//            //Save button
//            let widthBtSave = btSave.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtSave = btSave.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtSave, heightBtSave])
//            widthBtSave.constant = 80
//            heightBtSave.constant = 80
//
//            //Recall button
//            let widthBtRecall = btRecall.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtRecall = btRecall.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtRecall, heightBtRecall])
//            widthBtRecall.constant = 120
//            heightBtRecall.constant = 80
//            self.btRecall.layer.cornerRadius = 5
//            self.btRecall.layer.borderWidth = 1
//            self.btRecall.layer.borderColor = UIColor.black.cgColor
//
//            //All button
//            let widthBtAll = btAll.widthAnchor.constraint(equalToConstant: 30.0)
//            let heightBtAll = btAll.heightAnchor.constraint(equalToConstant: 30.0)
//            NSLayoutConstraint.activate([widthBtAll, heightBtAll])
//            widthBtAll.constant = 120
//            heightBtAll.constant = 80
//            self.btAll.layer.cornerRadius = 5
//            self.btAll.layer.borderWidth = 1
//            self.btAll.layer.borderColor = UIColor.black.cgColor
        }
    }
}

//Button Click Event
extension Matrix4MappingViewController{
    
    
    @IBAction func btSaveMapping(sender: UIButton) {
        self.showSaveMappingPopMenu()
    }
    
    @IBAction func btSetAll(sender: UIButton) {
        self.showSourcePopMenu(screenName: "All screen", screenNumber: 0, isSetAll: true)
    }
    
    @IBAction func btRefresh(sender: UIButton) {
        self.showLoadingView()
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_current_mapping, number: UInt8(CmdHelper._2_cmd_get_mapping_status))
    }
    
    @IBAction func btRecall(sender: UIButton) {
        self.showRecallMappingPopMenu()
    }
    
    func showRecallMappingPopMenu(){
        
        print("showRecallMappingPopMenu")
        
        DispatchQueue.main.async() {
            
            self.saveMappingMenu = RSSelectionMenu(dataSource: self.mappingName) { (cell, name, indexPath) in
                cell.textLabel?.text = name
            }
            
            self.saveMappingMenu.title = "Recall Mapping"
            
            // provide selected items
            var selectedNames: [String] = []
            
            self.saveMappingMenu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                selectedNames = selectedItems
                
                self.showLoadingView()
                var cmd = ""
                cmd = CmdHelper.cmd_4_x_4_recall_mapping + "0\(index)"
                cmd = cmd + self.calCheckSum(data: cmd)
                TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._11_cmd_recall_mapping))
                // self.startCheckFeedbackTimer()
            }
            self.saveMappingMenu.show(from: self)
        }
    }
    
    
    func showSaveMappingPopMenu(){
        
        print("showSaveMappingPopMenu")
        
        DispatchQueue.main.async() {
            
            self.saveMappingMenu = RSSelectionMenu(dataSource: self.mappingName) { (cell, name, indexPath) in
                cell.textLabel?.text = name
            }
            
            self.saveMappingMenu.title = "Save Mapping"
            
            // provide selected items
            var selectedNames: [String] = []
            
            self.saveMappingMenu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                
                self.showLoadingView()
                var cmd = ""
                print(index)
                cmd = CmdHelper.cmd_4_x_4_save_mapping + "0\(index)"
                cmd = cmd + self.calCheckSum(data: cmd)
                TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._10_cmd_save_current_to_mapping))
                
                //                    self.startCheckFeedbackTimer()
                
                
            }
            self.saveMappingMenu.show(from: self)
        }
    }
    
    func showSourcePopMenu(screenName: String, screenNumber: Int, isSetAll: Bool){
        
        
        if((self.inputName.count > 0) && (self.outputName.count > 0)){
            
            let title = screenName
            let message = "Select source to " + screenName.lowercased()
            
            // Create the dialog,
            let popup = PopupDialog(title: title, message: message, image: nil)
            
            var btArray: Array<CancelButton> = []
            if(!Matrix4MappingViewController.isPhone){
                let dialogAppearance = PopupDialogDefaultView.appearance()
                dialogAppearance.backgroundColor      = .white
                dialogAppearance.titleFont            = .boldSystemFont(ofSize: 32)
                //    dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
                dialogAppearance.titleTextAlignment   = .center
                dialogAppearance.messageFont          = .systemFont(ofSize: 26)
                //   dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
                
                let cb = CancelButton.appearance()
                cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 26)!
            }
            
            
            for i in 0...(self.inputName.count - 1){
                btArray.append(CancelButton(title: self.inputName[i]) {
                    self.showLoadingView()
                    var cmd = ""
                    
                    if(isSetAll){
                        cmd = CmdHelper.cmd_4_x_4_set_all_mapping + "0\(i+1)0\(i+1)0\(i+1)0\(i+1)"
                        cmd = cmd + self.calCheckSum(data: cmd)
                        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._9_cmd_set_all_mapping))
                    }else{
                        cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(screenNumber)0\(i+1)"
                        cmd = cmd + self.calCheckSum(data: cmd)
                        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
                    }
                    
                    //  self.startCheckFeedbackTimer()
                }
                )
            }
            
            btArray.append(CancelButton(title: "Mute") {
                self.showLoadingView()
                var cmd = ""
                if(isSetAll){
                    cmd = CmdHelper.cmd_4_x_4_set_all_mapping + "00000000"
                    cmd = cmd + self.calCheckSum(data: cmd)
                    TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._9_cmd_set_all_mapping))
                }else{
                    cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(screenNumber)00"
                    cmd = cmd + self.calCheckSum(data: cmd)
                    TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
                }
                // self.startCheckFeedbackTimer()
            }
            )
            
            
            popup.addButtons(btArray)
            
            self.present(popup, animated: true, completion: nil)
        }else{
            self.view.makeToast("Please reconnect to device first !")
        }
    }
    
}

//TCP Deleage
extension Matrix4MappingViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4MappingViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4MappingViewController-disConnect ")
        
        self.dismissLoadingView()
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4MappingViewController-onReadData - \(tag)")
        
        switch tag{
        
        case CmdHelper._1_cmd_set_single_mapping:
            TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_current_mapping, number:UInt8(CmdHelper._2_cmd_get_mapping_status))
            break
            
        case CmdHelper._2_cmd_get_mapping_status:
            print("Matrix4MappingViewController-_2_cmd_get_mapping_status")
            self.deviceSourceStatus.removeAll()
            //check has index[1], data checksum
            if(data.hexEncodedString().count > 4){
                var inputdata = self.hexStringToStringArray(data.hexEncodedString())
                if(inputdata?.count == 12){
                    for i in 0...3{
                        var sourceNumber = Int(inputdata![i+2], radix: 16)!
                        print("status \(sourceNumber)")
                        self.deviceSourceStatus.append(sourceNumber)
                    }
               //     self.collectionView.reloadData()
                    self.collectionInput.reloadData()
                    self.collectionOutput.reloadData()
                }else{
                    self.view.makeToast("Get data occur error !")
                }
                break
            }else{
                self.view.makeToast("Get data occur error !")
            }
            self.collectionInput.reloadData()
            self.collectionOutput.reloadData()
            break
            
        case CmdHelper._5_cmd_get_io_name:
            print("Matrix4MappingViewController-_5_cmd_get_io_name")
            self.parser4IOName(data: data)
            TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_mapping_name, number:UInt8(CmdHelper._7_cmd_get_mapping_name))
            break
            
        case CmdHelper._7_cmd_get_mapping_name:
            print("Matrix4MappingViewController-_7_cmd_get_mapping_name")
            self.parserMappingName(data: data)
            TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_current_mapping, number:UInt8(CmdHelper._2_cmd_get_mapping_status))
            break
            
        case CmdHelper._9_cmd_set_all_mapping:
            print("Matrix4MappingViewController-_9_cmd_set_all_mapping")
            TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_current_mapping, number:UInt8(CmdHelper._2_cmd_get_mapping_status))
            break
            
        case CmdHelper._10_cmd_save_current_to_mapping:
            print("Matrix4MappingViewController-_10_cmd_save_current_to_mapping")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                if(BaseViewController.isPhone){
                    self.view.showToast(text: "Save preset successful !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                }else{
                    self.view.showToast(text: "Save preset successful !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                }
            }
            break
            
        case CmdHelper._11_cmd_recall_mapping:
            print("Matrix4MappingViewController-_11_cmd_recall_mapping")
            TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_current_mapping, number:UInt8(CmdHelper._2_cmd_get_mapping_status))
            break
            
        default:
            
            break
        }
        self.dismissLoadingView()
    }
    
}

extension Matrix4MappingViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        if collectionView == self.collectionInput {
         
        }
        else {
            self.showSourcePopMenu(screenName: self.outputName[indexPath.item], screenNumber: (indexPath.item+1), isSetAll: false)
        }
    }
}

extension Matrix4MappingViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionInput {
            return self.inputName.count
        }
        else {
            return self.outputName.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionInput {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MappingInputCollectionViewCell", for: indexPath) as! MappingInputCollectionViewCell
            cell.labelIndex.text = "No." + String(indexPath.item + 1)
            cell.labelName.text = self.inputName[indexPath.item]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MappingOutputCollectionViewCell", for: indexPath) as! MappingOutputCollectionViewCell
            cell.labelIndex.text = "No." + String(indexPath.item + 1)
            cell.labelOutputName.text = self.outputName[indexPath.item]
            if((self.inputName.count > 0) && (self.outputName.count > 0)){
               // cell.labelStatus.text = self.outputName[indexPath.item]
                
                if(self.deviceSourceStatus[indexPath.item] > 100){
                    cell.labelStatus.text = "Mute"
                  //  cell.outputName.backgroundColor = UIColor.red
                }
                else{
                    cell.labelStatus.text = self.inputName[self.deviceSourceStatus[indexPath.item]-1]
                  //  cell.outputName.backgroundColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
                }
            }
            return cell
        }
    }
}


extension Matrix4MappingViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
            if(Matrix4MappingViewController.isPhone){
                return CGSize(width: (self.view.frame.size.width) / 4.8 , height: (self.view.frame.size.width) / 4)
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
