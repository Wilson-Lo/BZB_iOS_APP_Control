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
    
    @IBOutlet weak var btRefresh: UIButton!
    @IBOutlet weak var btSave: UIButton!
    @IBOutlet weak var btRecall: UIButton!
    @IBOutlet weak var btAll: UIButton!
    @IBOutlet weak var collectionInput: UICollectionView!
    @IBOutlet weak var collectionOutput: UICollectionView!
    var queueHTTP: DispatchQueue!
    var gradientLayer: CAGradientLayer!
    var saveMappingMenu: RSSelectionMenu<String>!
    var deviceSourceStatus: Array<Int> = []
    
    override func viewDidLoad() {
        print("Matrix4MappingViewController-viewDidLoad")
        super.viewDidLoad()
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
        initialUI()
        createInputGradientLayer()
        createOutputGradientLayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchFromInput(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_input), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchFromOutput(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_output), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(muteFromOutput(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_mute_from_output), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchFromAll(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_matrix4_switch_from_all), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4MappingViewController-viewWillAppear")
        super.viewWillAppear(true)
        TcpSocketClient.sharedInstance.delegate = self
        // self.showLoadingView()
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4MappingViewController-viewDidDisappear")
        //  TcpSocketClient.sharedInstance.stopConnect()
        
    }
    
}

extension Matrix4MappingViewController{
    
    //init Input area background color
    func createInputGradientLayer() {
        let bgView = UIView(frame: self.collectionInput.bounds)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.155182302, green: 0.207787931, blue: 0.2941000462, alpha: 1).cgColor ,#colorLiteral(red: 0.09019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.collectionInput?.backgroundView = bgView
    }
    
    //init Ouput area background color
    func createOutputGradientLayer() {
        let bgView = UIView(frame: self.collectionOutput.bounds)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.155182302, green: 0.207787931, blue: 0.2941000462, alpha: 1).cgColor ,#colorLiteral(red: 0.09019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.collectionOutput?.backgroundView = bgView
    }
    
    func initialUI(){
        
        self.btRefresh.layer.cornerRadius = 5
        self.btRefresh.layer.borderWidth = 1
        self.btRefresh.layer.borderColor = UIColor.white.cgColor
        
        self.btSave.layer.cornerRadius = 5
        self.btSave.layer.borderWidth = 1
        self.btSave.layer.borderColor = UIColor.white.cgColor
        
        self.btRecall.layer.cornerRadius = 5
        self.btRecall.layer.borderWidth = 1
        self.btRecall.layer.borderColor = UIColor.white.cgColor
        
        self.btAll.layer.cornerRadius = 5
        self.btAll.layer.borderWidth = 1
        self.btAll.layer.borderColor = UIColor.white.cgColor
        
        
        if(Matrix4MappingViewController.isPhone){
            print("is phone")
            //Refresh button
            //            let widthBtRefresh = btRefresh.widthAnchor.constraint(equalToConstant: 30.0)
            //            let heightBtRefresh = btRefresh.heightAnchor.constraint(equalToConstant: 30.0)
            //            NSLayoutConstraint.activate([widthBtRefresh, heightBtRefresh])
            //            widthBtRefresh.constant = 50
            //            heightBtRefresh.constant = 50
        }else{
            print("is pad")
            
        }
    }
    
    /**
     *  ui_matrix4_switch_from_input NSNotification
     */
    @objc func switchFromInput(notification: NSNotification){
        print("Matrix4MappingViewController - ui_matrix4_switch_from_input")
        self.queueHTTP.async {
            var cmd = ""
            cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(Matrix4InputDialogViewController.outputIndex)0\(Matrix4InputDialogViewController.inputIndex + 1)"
            cmd = cmd + self.calCheckSum(data: cmd)
            TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
        }
    }
    
    /**
     *  ui_matrix4_switch_from_output NSNotification
     */
    @objc func switchFromOutput(notification: NSNotification){
        print("Matrix4MappingViewController - ui_matrix4_switch_from_output")
        self.queueHTTP.async {
            var cmd = ""
            cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(Matrix4OutputDialogViewController.outputIndex+1)0\(Matrix4OutputDialogViewController.inputIndex)"
            cmd = cmd + self.calCheckSum(data: cmd)
            TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
        }
    }
    
    /**
     *  ui_matrix4_switch_from_all NSNotification
     */
    @objc func switchFromAll(notification: NSNotification){
        print("Matrix4MappingViewController - ui_matrix4_switch_from_all")
        self.queueHTTP.async {
            var cmd = ""
            if(Matrix4AllDialogViewController.inputIndex > 4){
                cmd = CmdHelper.cmd_4_x_4_set_all_mapping + "00000000"
            }else{
                var inputIndex = Matrix4AllDialogViewController.inputIndex
                cmd = CmdHelper.cmd_4_x_4_set_all_mapping + "0\(inputIndex)0\(inputIndex)0\(inputIndex)0\(inputIndex)"
            }
            print(cmd)
            cmd = cmd + self.calCheckSum(data: cmd)
            TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._9_cmd_set_all_mapping))
        }
    }
    
    
    /**
     *  ui_matrix4_mute_from_output NSNotification
     */
    @objc func muteFromOutput(notification: NSNotification){
        print("Matrix4MappingViewController - ui_matrix4_mute_from_output")
        self.queueHTTP.async {
            var cmd = ""
            cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(Matrix4OutputDialogViewController.outputIndex + 1)00"
            cmd = cmd + self.calCheckSum(data: cmd)
            TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
        }
    }
}

//Button Click Event
extension Matrix4MappingViewController{
    
    
    @IBAction func btSaveMapping(sender: UIButton) {
        self.showSaveMappingPopMenu()
    }
    
    @IBAction func btSetAll(sender: UIButton) {
        //self.showOutputPopMenu(screenName: "All screen", screenNumber: 0, isSetAll: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Matrix4AllDialogViewController.typeName) as! Matrix4AllDialogViewController
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    //    Matrix4InputDialogViewController.inputIndex = indexPath.item
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
        
        if((Matrix4MappingViewController.inputName.count > 0) && (Matrix4MappingViewController.outputName.count > 0)){
            DispatchQueue.main.async() {
                
                self.saveMappingMenu = RSSelectionMenu(dataSource: self.mappingName) { (cell, name, indexPath) in
                    if(!Matrix4MappingViewController.isPhone){
                        cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
                    }
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
        }else{
            self.view.makeToast("Please reconnect to device !")
        }
    }
    
    
    func showSaveMappingPopMenu(){
        
        print("showSaveMappingPopMenu")
        
        DispatchQueue.main.async() {
            
            self.saveMappingMenu = RSSelectionMenu(dataSource: self.mappingName) { (cell, name, indexPath) in
                if(!Matrix4MappingViewController.isPhone){
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
                }
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
    
//    func showOutputPopMenu(screenName: String, screenNumber: Int, isSetAll: Bool){
//
//
//        if((Matrix4MappingViewController.inputName.count > 0) && (Matrix4MappingViewController.outputName.count > 0)){
//
//            let title = screenName
//            let message = "Select source to " + screenName.lowercased()
//
//            // Create the dialog,
//            let popup = PopupDialog(title: title, message: message, image: nil)
//
//            var btArray: Array<CancelButton> = []
//            if(!Matrix4MappingViewController.isPhone){
//                let dialogAppearance = PopupDialogDefaultView.appearance()
//                dialogAppearance.backgroundColor      = .white
//                dialogAppearance.titleFont            = .boldSystemFont(ofSize: 24)
//                //    dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
//                dialogAppearance.titleTextAlignment   = .center
//                dialogAppearance.messageFont          = .systemFont(ofSize: 20)
//                //   dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
//
//                let cb = CancelButton.appearance()
//                cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 20)!
//            }
//
//
//            for i in 0...(Matrix4MappingViewController.inputName.count - 1){
//                btArray.append(CancelButton(title: Matrix4MappingViewController.inputName[i]) {
//                    self.showLoadingView()
//                    var cmd = ""
//
//                    if(isSetAll){
//                        cmd = CmdHelper.cmd_4_x_4_set_all_mapping + "0\(i+1)0\(i+1)0\(i+1)0\(i+1)"
//                        print(cmd)
//                        cmd = cmd + self.calCheckSum(data: cmd)
//
//                        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._9_cmd_set_all_mapping))
//                    }else{
//                        cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(screenNumber)0\(i+1)"
//                        print(cmd)
//                        cmd = cmd + self.calCheckSum(data: cmd)
//                        TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
//                    }
//
//                    //  self.startCheckFeedbackTimer()
//                }
//                )
//            }
//
//            btArray.append(CancelButton(title: "Mute") {
//                self.showLoadingView()
//                var cmd = ""
//                if(isSetAll){
//                    cmd = CmdHelper.cmd_4_x_4_set_all_mapping + "00000000"
//                    cmd = cmd + self.calCheckSum(data: cmd)
//                    TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._9_cmd_set_all_mapping))
//                }else{
//                    cmd = CmdHelper.cmd_4_x_4_set_single_mapping + "0\(screenNumber)00"
//                    cmd = cmd + self.calCheckSum(data: cmd)
//                    TcpSocketClient.sharedInstance.sendCmd(cmd: cmd, number: UInt8(CmdHelper._1_cmd_set_single_mapping))
//                }
//                // self.startCheckFeedbackTimer()
//            }
//            )
//
//
//            popup.addButtons(btArray)
//
//            self.present(popup, animated: true, completion: nil)
//        }else{
//            self.view.makeToast("Please reconnect to device first !")
//        }
//    }
    
}

//TCP Deleage
extension Matrix4MappingViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4MappingViewController-onConnect")
        Matrix4MappingViewController.inputName.removeAll()
        Matrix4MappingViewController.outputName.removeAll()
        self.collectionInput.reloadData()
        self.collectionOutput.reloadData()
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4MappingViewController-disConnect ")
        DispatchQueue.main.async() {
            self.showToast(context: "Can't connect to device !")
            Matrix4MappingViewController.inputName.removeAll()
            Matrix4MappingViewController.outputName.removeAll()
            self.collectionInput.reloadData()
            self.collectionOutput.reloadData()
            self.dismissLoadingView()
        }
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: Matrix4InputDialogViewController.typeName) as! Matrix4InputDialogViewController
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
            Matrix4InputDialogViewController.inputIndex = indexPath.item
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: Matrix4OutputDialogViewController.typeName) as! Matrix4OutputDialogViewController
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
            Matrix4OutputDialogViewController.outputIndex = indexPath.item
          //  self.showOutputPopMenu(screenName: Matrix4MappingViewController.outputName[indexPath.item], screenNumber: (indexPath.item+1), isSetAll: false)
        }
    }
}

extension Matrix4MappingViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionInput {
            return Matrix4MappingViewController.inputName.count
        }
        else {
            return Matrix4MappingViewController.outputName.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionInput {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MappingInputCollectionViewCell", for: indexPath) as! MappingInputCollectionViewCell
            cell.labelIndex.text = "No." + String(indexPath.item + 1)
            cell.labelName.text = Matrix4MappingViewController.inputName[indexPath.item]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MappingOutputCollectionViewCell", for: indexPath) as! MappingOutputCollectionViewCell
            cell.labelIndex.text = "No." + String(indexPath.item + 1)
            cell.labelOutputName.text = Matrix4MappingViewController.outputName[indexPath.item]
            if((Matrix4MappingViewController.inputName.count > 0) && (Matrix4MappingViewController.outputName.count > 0)){
                // cell.labelStatus.text = self.outputName[indexPath.item]
                if(self.deviceSourceStatus.count > 0){
                    if(self.deviceSourceStatus[indexPath.item] > 100){
                        cell.labelStatus.text = "Mute"
                        //  cell.outputName.backgroundColor = UIColor.red
                    }
                    else{
                        cell.labelStatus.text = Matrix4MappingViewController.inputName[self.deviceSourceStatus[indexPath.item]-1]
                        //  cell.outputName.backgroundColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
                    }
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
            return CGSize(width: (self.view.frame.size.width) / 5 , height: (self.view.frame.size.height) / 8)
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
