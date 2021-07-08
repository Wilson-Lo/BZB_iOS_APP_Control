//
//  ControllerBoxVideoWallViewController.swift
//  BZB_Project
//
//  Created by Wilson on 2021/05/20.
//  Copyright © 2021 GoMax. All rights reserved.
//

import Foundation

import UIKit
import Network
import RSSelectionMenu
import Toast_Swift
import SwiftSocket
import SwiftyJSON
import Alamofire
import PopupDialog

class ControlBoxVideoWallViewController : BaseViewController{
    
    
    @IBOutlet weak var collectionViewVideoWall: UICollectionView!
    @IBOutlet weak var collectionViewVideoWallContent: UICollectionView!
    @IBOutlet weak var stackViewTop: UIStackView!
    @IBOutlet weak var btPreset: UIButton!
    @IBOutlet weak var btDisable: UIButton!
    @IBOutlet weak var btEnable: UIButton!
    @IBOutlet weak var btTX: UIButton!
    
    var gradientLayer: CAGradientLayer!
    var txMenu: RSSelectionMenu<String>!
    var currentTotalVideoWallSize = 0 //Total video wall counts in current preset
    var currentRowVideoWallSize = 0 //Row counts in current preset
    var currentColVideoWallSize = 0 //Col counts in current preset
    var currentPresetTXMac = "" //TX mac address user select import than in preset
    var currentPresetTXGroupID = "" //TX group ID user select import than in preset
    var presetNameForUI: Array<String> = []
    var presetDataList: Array<Device> = []
    var txListForUI: Array<String> = []
    var selectedPresetIndex = 1
    var queueHTTP: DispatchQueue!
    var rxIPProtocol = [String : RXDevice]() // [ mac & RXDevice ]
    var txDeviceProtocol = [String : TXDevice]() // [ mac & TXDevice ]
    
    //preset rx device structure
    struct Device {
        let row: String
        let col: String
        let name: String
        let pos: String
        let mac: String
        let he_shift: String
        let ve_shift: String
        let vs_shift: String
        let hs_shift: String
    }
    
    //device info structure
    struct TXDevice {
        let name: String
        let mac: String
        let alive: String
        let group_id: String
    }
    
    //device info structure
    struct RXDevice {
        let name: String
        let ip: String
        let alive: String
    }
    
    override func viewDidLoad() {
        print("ControlBoxVideoWallViewController-viewDidLoad")
        super.viewDidLoad()
        self.selectedPresetIndex = 1
        initialUI()
        createVideoWallAreaGradientLayer()
        createVideoWallConAtentreaGradientLayer()
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
        self.navigationController?.navigationBar.barTintColor = UIColor(cgColor: #colorLiteral(red: 0.08523575506, green: 0.1426764978, blue: 0.2388794571, alpha: 1).cgColor )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ControlBoxVideoWallViewController-viewWillAppear")
        super.viewWillAppear(true)
        var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
        if(device_ip != nil){
            
            self.queueHTTP.async {
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }
            
        }else{
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ControlBoxVideoWallViewController-viewWillDisappear")
        
    }
    
}

extension ControlBoxVideoWallViewController{
    
    func initialUI(){
        self.btPreset.layer.cornerRadius = 10
        self.btEnable.layer.cornerRadius = 10
        self.btDisable.layer.cornerRadius = 10
        self.btEnable.layer.borderWidth = 1
        self.btEnable.layer.borderColor = UIColor.white.cgColor
        self.btTX.layer.cornerRadius = 10
    }
    
    //init TX area background color
    func createVideoWallAreaGradientLayer() {
        let bgView = UIView(frame: self.collectionViewVideoWall.bounds)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.155182302, green: 0.207787931, blue: 0.2941000462, alpha: 1).cgColor ,#colorLiteral(red: 0.09019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.collectionViewVideoWall?.backgroundView = bgView
    }
    
    
    func createVideoWallConAtentreaGradientLayer() {
        let bgView = UIView(frame: self.collectionViewVideoWallContent.bounds)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.frame
        
        // gradientLayer.colors = [UIColor(rgb: 0x2E3E56F19), UIColor(rgb: 0x090F19)]
        gradientLayer.colors = [#colorLiteral(red: 0.155182302, green: 0.207787931, blue: 0.2941000462, alpha: 1).cgColor ,#colorLiteral(red: 0.09019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.5)
        
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.collectionViewVideoWallContent?.backgroundView = bgView
    }
}

extension ControlBoxVideoWallViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        
        
    }
}


extension ControlBoxVideoWallViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionViewVideoWall {
            print("currentTotalVideoWallSize = " +  String(self.currentTotalVideoWallSize))
            
            return self.currentTotalVideoWallSize
        }
        else {
            return self.currentTotalVideoWallSize
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionViewVideoWall {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxVideoWallCollectionViewCell", for: indexPath) as! ControlBoxVideoWallCollectionViewCell
            cell.labelIndex.text = String(indexPath.item + 1)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxPresetCollectionViewCell", for: indexPath) as! ControlBoxPresetCollectionViewCell
            
            cell.indexLable.text = String(indexPath.item + 1)
            cell.nameLabel.text = ""
            
            for object in self.presetDataList{
                if(Int(object.pos)! == (indexPath.item + 1)){
                    cell.nameLabel.text = object.name
                    break
                }
            }
            return cell
        }
    }
}

extension ControlBoxVideoWallViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewVideoWall {
            return CGSize(width: (self.collectionViewVideoWall.frame.size.width) / (CGFloat(self.currentColVideoWallSize) + CGFloat(self.currentColVideoWallSize) * 0.2), height: (self.collectionViewVideoWall.frame.size.height) / (CGFloat(self.currentRowVideoWallSize) + CGFloat(self.currentRowVideoWallSize) * 0.3))
            
        }else{
            if(ControlBoxVideoWallViewController.isPhone){
                return CGSize(width: (self.view.frame.size.width - 50) , height: (self.view.frame.size.width) / 5)
            }else{
                return CGSize(width: (self.view.frame.size.width) * 0.8 , height: (self.view.frame.size.height) / 8)
            }
         
        }
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVideoWallViewController.isPhone){
            return 10
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVideoWallViewController.isPhone){
            return 5
        }else{
            return 12
        }
    }
}

//Button click event
extension ControlBoxVideoWallViewController {
    
    @IBAction func btPreset(sender: UIButton) {
        DispatchQueue.main.async() {
            
            var presetMenu = RSSelectionMenu(dataSource: self.presetNameForUI) { (cell, name, indexPath) in
                if(!ControlBoxVideoWallViewController.isPhone){
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
                }
                cell.textLabel?.text = name
            }
            
            presetMenu.title = "Select Preset"
            
            // provide selected items
            var selectedNames: [String] = []
            
            presetMenu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                self.btPreset.setTitle(self.presetNameForUI[index] , for: .normal)
                self.selectedPresetIndex = (index + 1)
                var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                if(device_ip != nil){
                    self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_video_wall_preset, cmdNumber: HTTPCmdHelper._4_cmd_video_wall_preset)
                }else{
                    
                }
            }
            
            presetMenu.show(from: self)
        }
    }
    
    @IBAction func btApply(sender: UIButton) {
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        
        self.queueHTTP.async {
            for deviceObject in self.presetDataList {
                var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                if(device_ip != nil){
                    
                    var data  = ["mac": deviceObject.mac, "vwh": deviceObject.col, "vwv": deviceObject.row, "vwp": deviceObject.pos, "vwl":deviceObject.hs_shift, "vwr":deviceObject.he_shift, "vwu":deviceObject.vs_shift, "vwb":deviceObject.ve_shift]
                    
                    AF.upload(multipartFormData: { (multiFormData) in
                        for (key, value) in data {
                            multiFormData.append(Data(value.utf8), withName: key)
                        }
                    }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_set_video_wall).responseJSON { response in
                        switch response.result {
                        case .success(let JSON):
                            print("response is :\(response)")
                        case .failure(_):
                            print("fail")
                        }
                    }
                    
                }
            }
            
            if(self.currentPresetTXGroupID.length > 0){
                self.recursiveSwitchAllRX(currentIndex: 0, txGroupId: self.currentPresetTXGroupID)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismissLoadingView()
                self.showToast(context: "Enable successful !")
            }
        }
    }
    
    @IBAction func btDisabled(sender: UIButton) {
        
        self.queueHTTP.async {
            for deviceObject in self.presetDataList {
                var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                if(device_ip != nil){
                    
                    var data  = ["mac": deviceObject.mac, "vwh": "1", "vwv": "1", "vwp": "1", "vwl":"0", "vwr":"0", "vwu":"0", "vwb":"0"]
                    
                    AF.upload(multipartFormData: { (multiFormData) in
                        for (key, value) in data {
                            multiFormData.append(Data(value.utf8), withName: key)
                        }
                    }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_set_video_wall).responseJSON { response in
                        switch response.result {
                        case .success(let JSON):
                            print("response is :\(response)")
                        case .failure(_):
                            print("fail")
                        }
                    }
                }else{
                    
                }
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if(BaseViewController.isPhone){
                    self.view.showToast(text: "Disable successful !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                }else{
                    self.view.showToast(text: "Disable successful !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                }
                
            }
        }
    }
    
    @IBAction func btPresetTX(sender: UIButton) {
        
        DispatchQueue.main.async() {
            
            self.txMenu = RSSelectionMenu(dataSource: self.txListForUI) { (cell, name, indexPath) in
                if(!ControlBoxVideoWallViewController.isPhone){
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
                }
                cell.textLabel?.text = name
            }
            
            self.txMenu.title = "Select TX"
            
            // provide selected items
            var selectedNames: [String] = []
            
            self.txMenu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                
                for (e, txObject) in self.txDeviceProtocol  {
                    
                    if(txObject.name == self.txListForUI[index]){
                        self.currentPresetTXGroupID = txObject.group_id
                        break
                    }
                }
                self.btTX.setTitle(self.txListForUI[index], for: .normal)
            }
            self.txMenu.show(from: self)
        }
        
    }
}

extension ControlBoxVideoWallViewController{
    
    func recursiveSwitchAllRX(currentIndex : Int, txGroupId : String){
        print("recursiveSwitchAllRX - \(currentIndex)" )
        if(currentIndex <= (self.presetDataList.count - 1)){
            
            self.queueHTTP.async {
                var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                if(device_ip != nil){
                    
                    if(self.rxIPProtocol[self.presetDataList[currentIndex].mac] != nil){
                        if(self.rxIPProtocol[self.presetDataList[currentIndex].mac]!.alive != "n" ){
                            var data  = ["ip": self.rxIPProtocol[self.presetDataList[currentIndex].mac]!.ip,"switch_id":self.currentPresetTXGroupID,"switch_type":"z"]
                            
                            AF.upload(multipartFormData: { (multiFormData) in
                                for (key, value) in data {
                                    multiFormData.append(Data(value.utf8), withName: key)
                                }
                            }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_switch_group_id).responseJSON { response in
                                switch response.result {
                                case .success(let JSON):
                                    print("recursive response is :\(response)")
                                    
                                    if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                                        
                                    }else{
                                        self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                    }
                                    
                                case .failure(_):
                                    
                                    print("recursive fail")
                                    
                                    if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                                        
                                    }else{
                                        self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                    }
                                }
                            }
                            
                        }else{
                            if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                                
                            }else{
                                self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                            }
                        }
                    }else{
                        
                        if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                            
                        }else{
                            self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                        }
                        
                    }
                    
                }
            }
            
        }
    }
}

extension ControlBoxVideoWallViewController{
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd, method: .get){ urlRequest in
            urlRequest.timeoutInterval = 5
            urlRequest.allowsExpensiveNetworkAccess = false
        }.response{ response in
            debugPrint(response)
            
            switch response.result{
            
            case .success(let value):
                let json = JSON(value)
                
                debugPrint(json)
                switch(cmdNumber){
                
                case HTTPCmdHelper._1_cmd_get_node_info:
                    debugPrint("_1_cmd_get_node_info")
                    self.txDeviceProtocol.removeAll()
                    self.txListForUI.removeAll()
                    self.rxIPProtocol.removeAll()
                    
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            
                            let name = deviceObject["host_name"].stringValue
                            let mac = deviceObject["mac"].stringValue
                            let ip = deviceObject["ip"].stringValue
                            let alive = deviceObject["alive"].stringValue
                            let group_id = deviceObject["id"].stringValue
                            
                            if(deviceObject["type"].stringValue != "r"){
                                self.txDeviceProtocol[mac] = TXDevice(name: name, mac: mac, alive: alive, group_id: group_id)
                                self.txListForUI.append(name)
                            }else{
                                self.rxIPProtocol[mac] = RXDevice(name: name, ip: ip, alive: alive)
                            }
                        }
                    }
                    
                    self.queueHTTP.async {
                        var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                        if(device_ip != nil){
                            self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_video_wall_preset, cmdNumber: HTTPCmdHelper._4_cmd_video_wall_preset)
                        }
                    }
                    break
                    
                    
                case HTTPCmdHelper._4_cmd_video_wall_preset:
                    debugPrint("_4_cmd_video_wall_preset")
                    self.presetDataList.removeAll()
                    self.presetNameForUI.removeAll()
                    
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            
                            let tx_mac = deviceObject["tx_mac"].stringValue
                            let row = deviceObject["row"].stringValue
                            let col = deviceObject["col"].stringValue
                            let index = deviceObject["index"].stringValue
                            let name = deviceObject["name"].stringValue
                            self.presetNameForUI.append(name)
                            
                            if(index ==  String(self.selectedPresetIndex)){
                                self.currentPresetTXMac = tx_mac
                                self.btPreset.setTitle(name, for: .normal)
                                self.currentTotalVideoWallSize = Int(row)! * Int(col)!
                                self.currentRowVideoWallSize = Int(row)!
                                self.currentColVideoWallSize = Int(col)!
                                if let rxList = deviceObject["rx_list"].array {
                                    for rxObject in rxList {
                                        let mac = rxObject["mac"].stringValue
                                        self.presetDataList.append(Device(row: row, col:col, name: rxObject["name"].stringValue, pos: rxObject["pos"].stringValue, mac: rxObject["mac"].stringValue, he_shift: rxObject["mac"].stringValue, ve_shift: rxObject["ve_shift"].stringValue, vs_shift: rxObject["vs_shift"].stringValue, hs_shift: rxObject["hs_shift"].stringValue))
                                    }
                                }
                                
                                self.collectionViewVideoWall.reloadData()
                                self.collectionViewVideoWallContent.reloadData()
                                
                                if(self.txDeviceProtocol.count > 0){
                                    if(self.txDeviceProtocol[self.currentPresetTXMac] != nil){
                                        self.currentPresetTXGroupID = self.txDeviceProtocol[self.currentPresetTXMac]!.group_id
                                        self.btTX.setTitle(self.txDeviceProtocol[self.currentPresetTXMac]?.name, for: .normal)
                                    }else{
                                        self.btTX.setTitle("N/A", for: .normal)
                                    }
                                }
                            }
                        }
                    }
                    break
                    
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break
                }
                
                break
                
            case .failure(let error):
                debugPrint("HTTP GET request failed")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismiss(animated: false, completion: nil)
                    
                    if(BaseViewController.isPhone){
                        self.view.showToast(text: "Can't connect to device !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                    }else{
                        self.view.showToast(text: "Can't connect to device !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                    }
                    
                }
                break
            }
        }
    }
}
