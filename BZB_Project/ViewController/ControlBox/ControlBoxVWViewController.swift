//
//  test.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/1.
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

class ControlBoxVWViewController : BaseViewController{
    
    
    @IBOutlet weak var btSelectSource: UIButton!
    @IBOutlet weak var videoWallLayoutlabel: UILabel!
    @IBOutlet weak var transmitterLabel: UILabel!
    @IBOutlet weak var txSourceLabel: UILabel!
    @IBOutlet weak var txSourceView: UIView!
    @IBOutlet weak var motherView: UIView!
    @IBOutlet weak var segmentVideoWall: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var transmitterLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoWalLayoutWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoWallPresetWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var presetMainStack: UIStackView!
    @IBOutlet weak var presetTopStack: UIStackView!
    @IBOutlet weak var presetBottomStack: UIStackView!
    
    @IBOutlet weak var videoWallLayoutTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btPreset1: UIButton!
    @IBOutlet weak var btPreset2: UIButton!
    @IBOutlet weak var btPreset3: UIButton!
    @IBOutlet weak var btPreset4: UIButton!
    @IBOutlet weak var btPreset5: UIButton!
    @IBOutlet weak var btPreset6: UIButton!
    @IBOutlet weak var btPreset7: UIButton!
    @IBOutlet weak var btPreset8: UIButton!
    
    var gradientLayer: CAGradientLayer!
    var txMenu: RSSelectionMenu<String>!
    var currentTotalVideoWallSize = 0 //Total video wall counts in current preset
    var currentRowVideoWallSize = 0 //Row counts in current preset
    var currentColVideoWallSize = 0 //Col counts in current preset
    var currentPresetTXMac = "" //TX mac address user select import than in preset
    var currentPresetTXGroupID = "" //TX group ID user select import than in preset
    var presetNameForUI: Array<String> = []
    var presetDataList: Array<Device> = []
    static var txListForUI: Array<String> = []
    var selectedPresetIndex = 1
    var queueHTTP: DispatchQueue!
    var rxIPProtocol = [String : RXDevice]() // [ mac & RXDevice ]
    var txDeviceProtocol = [String : TXDevice]() // [ mac & TXDevice ]
    var btPresetArray = [UIButton]()
    
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
        print("ControlBoxVWViewController-viewDidLoad")
        super.viewDidLoad()
        self.addNavBarLogoImage(isTabViewController: true)
        self.setupBackButton(isTabViewController: true)
        self.btPresetArray = [btPreset1, btPreset2, btPreset3, btPreset4, btPreset5, btPreset6, btPreset7, btPreset8]
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(txSwitch(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_vw_switch_source), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ControlBoxVWViewController-viewWillAppear")
        super.viewWillAppear(true)
        self.selectedPresetIndex = 1
        for index in 0...7 {
            self.btPresetArray[index].setTitleColor(.opaqueSeparator, for: .normal)
        }
        self.btPresetArray[0].setTitleColor(.orange, for: .normal)
        var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
        if(device_ip != nil){
            self.queueHTTP.async {
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }
        }
    }
    
    func setupUI(){
        let selectAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        self.segmentVideoWall.setTitleTextAttributes(selectAttributes, for: .selected)
        let normalAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.segmentVideoWall.setTitleTextAttributes(normalAttributes, for: .normal)
        self.collectionView.layer.cornerRadius = 6
        self.collectionView.layer.borderWidth = 0.4
        self.collectionView.layer.borderColor = UIColor.white.cgColor
        self.btSelectSource.layer.cornerRadius = 3
        self.btSelectSource.layer.borderWidth = 0.4
        self.btSelectSource.layer.borderColor = UIColor.white.cgColor
        self.presetMainStack.layer.cornerRadius = 6
        self.presetMainStack.layer.borderWidth = 0.4
        self.transmitterLabel.layer.masksToBounds = true
        self.presetMainStack.layer.borderColor = UIColor.white.cgColor
        self.motherView.sendSubviewToBack(presetMainStack)
        self.motherView.bringSubviewToFront(transmitterLabel)
        self.motherView.bringSubviewToFront(segmentVideoWall)
        self.motherView.bringSubviewToFront(videoWallLayoutlabel)
        self.motherView.sendSubviewToBack(txSourceView)
        self.txSourceView.layer.cornerRadius = 6
        self.segmentVideoWall.addTarget(self, action: #selector(presetEanbleChanged(_:)), for: .valueChanged)
        
        for index in 0...7 {
            if(ControlBoxVWViewController.isPhone){
                self.btPresetArray[index].layer.cornerRadius = 6
            }else{
                self.btPresetArray[index].layer.cornerRadius = 8
            }
        }
        
        self.presetTopStack.isLayoutMarginsRelativeArrangement = true
        self.presetBottomStack.isLayoutMarginsRelativeArrangement = true
        if(ControlBoxVWViewController.isPhone){
            let font = UIFont.systemFont(ofSize: 10)
            
            self.segmentVideoWall.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            self.presetTopStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            self.presetBottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right:    10)
            
            if(UIScreen.main.bounds.height > 700){
                self.transmitterLabel.layer.cornerRadius = 10
            }else{
                self.transmitterLabel.layer.cornerRadius = 6
                self.videoWallLayoutTopConstraint.constant = 13.4
            }
            
        }else{
            self.transmitterLabel.layer.cornerRadius = 10
            self.presetTopStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            self.presetBottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            let font = UIFont.systemFont(ofSize: 18)
            self.segmentVideoWall.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            let newVideoWallPresetWidthConstraint = videoWallPresetWidthConstraint.constraintWithMultiplier(0.28)
            self.view.removeConstraint(videoWallPresetWidthConstraint)
            self.view.addConstraint(newVideoWallPresetWidthConstraint)
            self.view.layoutIfNeeded()
            let newVideoWalLayoutWidthConstraint = videoWalLayoutWidthConstraint.constraintWithMultiplier(0.28)
            self.view.removeConstraint(videoWalLayoutWidthConstraint)
            self.view.addConstraint(newVideoWalLayoutWidthConstraint)
            self.view.layoutIfNeeded()
            let newTransmitterLabelWidthConstraint = transmitterLabelWidthConstraint.constraintWithMultiplier(0.2)
            self.view.removeConstraint(transmitterLabelWidthConstraint)
            self.view.addConstraint(newTransmitterLabelWidthConstraint)
            self.view.layoutIfNeeded()
        }
    }
    
    //Preset Eanble Changed (SegmentedControl)
    @objc func presetEanbleChanged(_ sender: UISegmentedControl){
        print(sender.selectedSegmentIndex)
        if(sender.selectedSegmentIndex == 0){
            print("enble")
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
                    self.showToast(context: "Enable finish !")
                }
            }
        }else if(sender.selectedSegmentIndex == 1){
            print("disable")
            DispatchQueue.main.async() {
                self.showLoadingView()
            }
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
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if(BaseViewController.isPhone){
                        self.view.showToast(text: "Disable finish !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                    }else{
                        self.view.showToast(text: "Disable finish !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                    }
                    self.dismissLoadingView()
                }
            }
        }
    }
}

extension ControlBoxVWViewController {
    
    @objc func txSwitch(notification: NSNotification){
        for (e, txObject) in self.txDeviceProtocol  {
            if(txObject.name == ControlBoxVMSourceDialogViewController.userSelectSourceName){
                self.currentPresetTXGroupID = txObject.group_id
                break
            }
        }
        self.txSourceLabel.text = ControlBoxVMSourceDialogViewController.userSelectSourceName
        self.recursiveSwitchAllRX(currentIndex: 0, txGroupId: self.currentPresetTXGroupID)
    }
    
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
                                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                                            self.showToast(context: "Switch source finish !")
                                        }
                                    }else{
                                        self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                    }
                                    
                                case .failure(_):
                                    
                                    print("recursive fail")
                                    
                                    if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                                            self.showToast(context: "Switch source finish !")
                                        }
                                    }else{
                                        self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                    }
                                }
                            }
                            
                        }else{
                            if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    self.showToast(context: "Switch source finish !")
                                }
                            }else{
                                self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                            }
                        }
                    }else{
                        
                        if((currentIndex + 1) > (self.presetDataList.count - 1 )){
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                self.showToast(context: "Switch source finish !")
                            }
                        }else{
                            self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                        }
                        
                    }
                    
                }
            }
            
        }
    }
}

extension ControlBoxVWViewController {
    
    @IBAction func btPresetTX(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ControlBoxVMSourceDialogViewController.typeName) as! ControlBoxVMSourceDialogViewController
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)

    }
    
    
    @IBAction func btPresetClickEvent(sender: UIButton) {
        
        print("click  = " , sender.tag)
        DispatchQueue.main.async() {
            
            for index in 0...7 {
                self.btPresetArray[index].setTitleColor(.opaqueSeparator, for: .normal)
            }
            
            sender.setTitleColor(.orange, for: .normal)
            
            switch sender.tag{
            
            case 101:
                self.selectedPresetIndex = 1
                break
                
            case 102:
                self.selectedPresetIndex = 2
                break
                
            case 103:
                self.selectedPresetIndex = 3
                break
                
            case 104:
                self.selectedPresetIndex = 4
                break
                
            case 105:
                self.selectedPresetIndex = 5
                break
                
            case 106:
                self.selectedPresetIndex = 6
                break
                
            case 107:
                self.selectedPresetIndex = 7
                break
                
            case 108:
                self.selectedPresetIndex = 8
                break
                
            default:
                
                break
            }
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_video_wall_preset, cmdNumber: HTTPCmdHelper._4_cmd_video_wall_preset)
            }
        }
    }
}

extension ControlBoxVWViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
}


extension ControlBoxVWViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("currentTotalVideoWallSize = " +  String(self.currentTotalVideoWallSize))
        return self.currentTotalVideoWallSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxVWCollectionViewCell", for: indexPath) as! ControlBoxVWCollectionViewCell
        cell.numberLabel.text = String(indexPath.item + 1)
        
        var rx_name = ""
        var rx_temp_name = "" //if live device not exist use this
        
        for rx in self.presetDataList{
            if(String(indexPath.item + 1) != rx.pos){
                
            }else{
                rx_temp_name = rx.name
                if(self.rxIPProtocol[rx.mac] != nil){
                    rx_name =  self.rxIPProtocol[rx.mac]!.name
                }
            }
        }
        
        if(rx_name.length > 0){
            
        }else{
            rx_name = rx_temp_name
        }
        
        if(self.currentTotalVideoWallSize > 20){
            cell.displayLabel.text = ""
        }else{
            if(UIScreen.main.bounds.height > 700){
                cell.displayLabel.text = rx_name
            }else{
                if(self.currentTotalVideoWallSize >= 16){
                    cell.displayLabel.text = ""
                }else{
                    cell.displayLabel.text = rx_name
                }
            }
        }
        return cell
    }
}

extension ControlBoxVWViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(ControlBoxVWViewController.isPhone){
            if(self.currentTotalVideoWallSize > 20){
                return CGSize(width: (self.collectionView.frame.size.width) / (CGFloat(self.currentColVideoWallSize) + CGFloat(self.currentColVideoWallSize) * 0.4), height: (self.collectionView.frame.size.height) / (CGFloat(self.currentRowVideoWallSize) + CGFloat(self.currentRowVideoWallSize) * 0.4))
            }else{
                if(UIScreen.main.bounds.height > 700){
                    return CGSize(width: (self.collectionView.frame.size.width) / (CGFloat(self.currentColVideoWallSize) + CGFloat(self.currentColVideoWallSize) * 0.2), height: (self.collectionView.frame.size.height) / (CGFloat(self.currentRowVideoWallSize) + CGFloat(self.currentRowVideoWallSize) * 0.4))
                }else{
                    return CGSize(width: (self.collectionView.frame.size.width) / (CGFloat(self.currentColVideoWallSize) + CGFloat(self.currentColVideoWallSize) * 0.3), height: (self.collectionView.frame.size.height) / (CGFloat(self.currentRowVideoWallSize) + CGFloat(self.currentRowVideoWallSize) * 0.4))
                }
            }
        }else{
            if(self.currentTotalVideoWallSize > 20){
                return CGSize(width: (self.collectionView.frame.size.width) / (CGFloat(self.currentColVideoWallSize) + CGFloat(self.currentColVideoWallSize) * 0.2), height: (self.collectionView.frame.size.height) / (CGFloat(self.currentRowVideoWallSize) + CGFloat(self.currentRowVideoWallSize) * 0.4))
            }else{
                return CGSize(width: (self.collectionView.frame.size.width) / (CGFloat(self.currentColVideoWallSize) + CGFloat(self.currentColVideoWallSize) * 0.2), height: (self.collectionView.frame.size.height) / (CGFloat(self.currentRowVideoWallSize) + CGFloat(self.currentRowVideoWallSize) * 0.4))
            }
        }
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVWViewController.isPhone){
            return 10
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVWViewController.isPhone){
            return 5
        }else{
            return 12
        }
    }
}

extension ControlBoxVWViewController{
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd, method: .get){ urlRequest in
            urlRequest.timeoutInterval = 5
            urlRequest.allowsExpensiveNetworkAccess = false
        }.response{ response in
           // print(response)
            
            switch response.result{
            
            case .success(let value):
                let json = JSON(value)
                
                
               // print(json)
                switch(cmdNumber){
                
                case HTTPCmdHelper._1_cmd_get_node_info:
                    print("_1_cmd_get_node_info")
                    self.txDeviceProtocol.removeAll()
                    ControlBoxVWViewController.txListForUI.removeAll()
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
                                ControlBoxVWViewController.txListForUI.append(name)
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
                    print("_4_cmd_video_wall_preset")
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
                                //  self.btPreset.setTitle(name, for: .normal)
                                self.currentTotalVideoWallSize = Int(row)! * Int(col)!
                                self.currentRowVideoWallSize = Int(row)!
                                self.currentColVideoWallSize = Int(col)!
                                if let rxList = deviceObject["rx_list"].array {
                                    for rxObject in rxList {
                                        let mac = rxObject["mac"].stringValue
                                        let he_shift = Int(rxObject["he_shift"].stringValue)! * (-1)
                                        let hs_shift = Int(rxObject["hs_shift"].stringValue)! * (-1)
                                        
                                        
                                        self.presetDataList.append(Device(row: row, col:col, name: rxObject["name"].stringValue, pos: rxObject["pos"].stringValue, mac: rxObject["mac"].stringValue, he_shift: String(he_shift), ve_shift: rxObject["ve_shift"].stringValue, vs_shift: rxObject["vs_shift"].stringValue, hs_shift: String(hs_shift)))
                                    }
                                }
                                
                                self.collectionView.reloadData()
                                if(self.txDeviceProtocol.count > 0){
                                    if(self.txDeviceProtocol[self.currentPresetTXMac] != nil){
                                        self.currentPresetTXGroupID = self.txDeviceProtocol[self.currentPresetTXMac]!.group_id
                                        self.txSourceLabel.text = self.txDeviceProtocol[self.currentPresetTXMac]?.name
                                    }else{
                                        self.txSourceLabel.text = "N/A"
                                    }
                                }
                            }
                        }
                    }
                    
                    for index in 0...7 {
                        self.btPresetArray[index].setTitle( self.presetNameForUI[index], for: .normal)
                    }
                    break
                    
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismissLoadingView()
                    }
                    break
                }
                
                break
                
            case .failure(let error):
                print("HTTP GET request failed")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismissLoadingView()
                    
                    if(ControlBoxVWViewController.isPhone){
                        self.view.showToast(text: "Can't connect to device !", font_size: CGFloat(ControlBoxVWViewController.textSizeForPhone), isMenu: true)
                    }else{
                        self.view.showToast(text: "Can't connect to device !", font_size: CGFloat(ControlBoxVWViewController.textSizeForPad), isMenu: true)
                    }
                    
                }
                break
            }
        }
    }
}
