//
//  ControlBoxMappingViewController.swift
//  BZB_Project
//
//  Created by Wilson on 2021/05/21.
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

class ControlBoxMappingViewController : BaseViewController{
    
    
    @IBOutlet weak var displayAreaHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayAreaWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sourceAreaWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var presetAreaWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var presetBt1: UIButton!
    @IBOutlet weak var presetBt2: UIButton!
    @IBOutlet weak var presetBt3: UIButton!
    @IBOutlet weak var presetBt4: UIButton!
    @IBOutlet weak var presetBt5: UIButton!
    @IBOutlet weak var presetBt6: UIButton!
    @IBOutlet weak var presetBt7: UIButton!
    @IBOutlet weak var presetBt8: UIButton!
    @IBOutlet weak var presetBt9: UIButton!
    @IBOutlet weak var presetTopStack: UIStackView!
    @IBOutlet weak var presetMiddleStack: UIStackView!
    @IBOutlet weak var presetBottomStack: UIStackView!
    @IBOutlet weak var previewCollectionView: UICollectionView!
    @IBOutlet weak var sourceCollectionView: UICollectionView!
    @IBOutlet weak var presetStack: UIStackView!
    var queueHTTP: DispatchQueue!
    var btPresetArray = [UIButton]()
    var rxList: Array<Device> = []
    var rxForPreset: Array<Device> = []
    //   var txAllList: Array<Device> = []
    static var txOnlineList: Array<Device> = []
    var displayCellList: Array<ControlBoxMappingDisplayCollectionViewCell> = []
    var txMenu: RSSelectionMenu<String>!
    var gradientLayer: CAGradientLayer!
    var updateTimer: Timer!
    var currentRxDeviceSize :Int = 0 //use to determine need to reload collection view or not
    var isDialogShowing:Bool = false
    var currentPresetIndex = 0
    
    //device info structure
    struct Device {
        let name: String
        let ip: String
        let alive: String
        let pin: String
        let group_id: String
        let mac: String
    }
    
    struct previewStruct: Decodable {
        var result: String
        var base64: String
    }
    
    override func viewDidLoad() {
        print("ControlBoxMappingViewController-viewDidLoad")
        super.viewDidLoad()
        self.btPresetArray = [self.presetBt1, self.presetBt2, self.presetBt3, self.presetBt4, self.presetBt5, self.presetBt6, self.presetBt7, self.presetBt8,  self.presetBt9]
        self.setupUI()
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
        self.isDialogShowing = false
        //tx device
        NotificationCenter.default.addObserver(self, selector: #selector(txBlinkRedLight(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_tx_blink_red_light), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(txSwitchAll(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_tx_switch_all), object: nil)
        //rx device
        NotificationCenter.default.addObserver(self, selector: #selector(rxSwitchChannel(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_switch_channel), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(rxBlinkRedLight(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_blink_red_light), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(rxMute(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_rx_mute), object: nil)
        //close dialog
        NotificationCenter.default.addObserver(self, selector: #selector(closeDialog(notification:)), name: NSNotification.Name(rawValue: UIEventHelper.ui_close_dialog), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("ControlBoxMappingViewController-viewWillAppear")
        //        DispatchQueue.main.async() {
        //            self.showLoadingView()
        //        }
        
        self.queueHTTP.async {
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }else{
                self.dismissLoadingView()
            }
        }
        //update device status timer, every 12 seconds
        self.updateTimer = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(updateDevice), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ControlBoxMappingViewController-viewWillDisappear")
        self.updateTimer?.invalidate()
    }
    
}

extension ControlBoxMappingViewController{
    
    func setupUI(){
        
        for index in 0...(self.btPresetArray.count-1) {
            self.btPresetArray[index].layer.cornerRadius = 6
        }
        
        self.presetTopStack.isLayoutMarginsRelativeArrangement = true
        self.presetMiddleStack.isLayoutMarginsRelativeArrangement = true
        self.presetBottomStack.isLayoutMarginsRelativeArrangement = true
        
        self.presetTopStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.presetMiddleStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right:    10)
        self.presetBottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        self.sourceCollectionView.layer.cornerRadius = 6
        self.sourceCollectionView.layer.borderWidth = 0.4
        self.sourceCollectionView.layer.borderColor = UIColor.white.cgColor
        
        self.presetStack.layer.cornerRadius = 6
        self.presetStack.layer.borderWidth = 0.4
        self.presetStack.layer.borderColor = UIColor.white.cgColor
        
        self.previewCollectionView.layer.cornerRadius = 6
        self.previewCollectionView.layer.borderWidth = 0.4
        self.previewCollectionView.layer.borderColor = UIColor.white.cgColor
        
        if(!ControlBoxMappingViewController.isPhone){
            let newSourceAreaWidthConstraint = sourceAreaWidthConstraint.constraintWithMultiplier(0.59)
            self.view.removeConstraint(sourceAreaWidthConstraint)
            self.view.addConstraint(newSourceAreaWidthConstraint)
            self.view.layoutIfNeeded()
            let newPresetAreaWidthConstraint = presetAreaWidthConstraint.constraintWithMultiplier(0.36)
            self.view.removeConstraint(presetAreaWidthConstraint)
            self.view.addConstraint(newPresetAreaWidthConstraint)
            self.view.layoutIfNeeded()
            
            let newDisplayAreaWidthConstraint = displayAreaWidthConstraint.constraintWithMultiplier(0.97)
            self.view.removeConstraint(displayAreaWidthConstraint)
            self.view.addConstraint(newDisplayAreaWidthConstraint)
            self.view.layoutIfNeeded()
        }
        
    }
}

extension ControlBoxMappingViewController{
    
    //update device request
    @objc func updateDevice(){
        print("updateDevice")
        if(!self.isDialogShowing){
            print("dialog not showing")
            self.queueHTTP.async {
                var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                if(device_ip != nil){
                    self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._6_cmd_get_node_info_without_loading)
                }
            }
        }else{
            print("dialog showing")
        }
    }
    
    /**
     * TX  ui_tx_blink_red_light NSNotification
     */
    @objc func txBlinkRedLight(notification: NSNotification){
        print("ControlBoxMappingViewController - ui_tx_blink_red_light")
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        
        self.queueHTTP.async {
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                
                var data  = ["ip": ASpeedTXDialogViewController.deviceIP, "value":"cat /sys/devices/platform/ast1500_led.2/leds:button_link/N_Led"]
                
                AF.upload(multipartFormData: { (multiFormData) in
                    for (key, value) in data {
                        multiFormData.append(Data(value.utf8), withName: key)
                    }
                }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_send_cmd).responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
                        print("response is :\(response)")
                    case .failure(_):
                        print("fail")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    /**
     * Close dialog NSNotification
     */
    @objc func closeDialog(notification: NSNotification){
        print("ControlBoxMappingViewController - closeDialog")
        self.isDialogShowing = false
    }
    
    /**
     * TX  ui_tx_switch_all NSNotification
     */
    @objc func txSwitchAll(notification: NSNotification){
        print("ControlBoxMappingViewController - ui_tx_switch_all")
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        self.recursiveSwitchAllRX(currentIndex: 0, txGroupId: ASpeedTXDialogViewController.deviceGroupId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.dismiss(animated: false, completion: nil)
            self.showToast(context: "Switch for All RX finish!")
            self.queueHTTP.async {
                self.refresh()
            }
        }
    }
    
    /**
     * RX  ui_tx_switch_all NSNotification
     */
    @objc func rxSwitchChannel(notification: NSNotification){
        print("ControlBoxMappingViewController - ui_rx_switch_channel")
        DispatchQueue.main.async() {
            self.showLoadingView()
            self.queueHTTP.async {
                if(ControlBoxMappingViewController.txOnlineList[ControlBoxMappingSourceDialogViewController.userSelectSourceIndex] != nil){
                    var tx_group_id = ControlBoxMappingViewController.txOnlineList[ControlBoxMappingSourceDialogViewController.userSelectSourceIndex].group_id
                    
                    print("tx_group_id is :\(tx_group_id)")
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        var data  = ["ip": ControlBoxMappingSourceDialogViewController.userSelectSourceIP,"switch_id":tx_group_id,"switch_type":"z"]
                        AF.upload(multipartFormData: { (multiFormData) in
                            for (key, value) in data {
                                multiFormData.append(Data(value.utf8), withName: key)
                            }
                        }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_switch_group_id).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                print("response is :\(response)")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    if(BaseViewController.isPhone){
                                        self.view.showToast(text: "Switch channel successful !", font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
                                    }else{
                                        self.view.showToast(text: "Switch channel successful !", font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
                                    }
                                }
                                self.refresh()
                            case .failure(_):
                                print("fail")
                                self.showToast(context: "Switch channel failed !")
                            }
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
            
        }
    }
    
    /**
     * RX  ui_tx_switch_all NSNotification
     */
    @objc func rxBlinkRedLight(notification: NSNotification){
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        
        self.queueHTTP.async {
            
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                
                var data  = ["ip": ASpeedRXDialogViewController.deviceIP,"value":"echo 2 > /sys/devices/platform/ast1500_led.2/leds:button_link/N_Led"]
                
                AF.upload(multipartFormData: { (multiFormData) in
                    for (key, value) in data {
                        multiFormData.append(Data(value.utf8), withName: key)
                    }
                }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_send_cmd).responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
                        print("response is :\(response)")
                    case .failure(_):
                        print("fail")
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    /**
     * RX  ui_tx_switch_all NSNotification
     */
    @objc func rxMute(notification: NSNotification){
        self.queueHTTP.async {
            self.showLoadingView()
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                
                var vaule = ""
                
                if(ASpeedRXDialogViewController.isMute){
                    vaule = "echo 1 > /sys/devices/platform/display/screen_off"
                }else{
                    vaule = "echo 0 > /sys/devices/platform/display/screen_off"
                }
                
                var data  = ["ip": ASpeedRXDialogViewController.deviceIP,"value": vaule]
                
                AF.upload(multipartFormData: { (multiFormData) in
                    for (key, value) in data {
                        multiFormData.append(Data(value.utf8), withName: key)
                    }
                }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_send_cmd).responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
                        print("response is :\(response)")
                        DispatchQueue.main.async {
                            self.showToast(context: "Successful !")
                        }
                    case .failure(_):
                        print("fail")
                        self.showToast(context: "Failed !")
                    }
                }
            }
            
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //                self.dismiss(animated: false, completion: nil)
            //            }
        }
    }
    
    //Preset button click event (SegmentedControl)
    @IBAction func btPreset(sender: UIButton) {
        
        DispatchQueue.main.async() {
            self.showLoadingView()
        }
        
        for index in 0...(self.btPresetArray.count-1) {
            self.btPresetArray[index].setTitleColor(.opaqueSeparator, for: .normal)
        }
        
        sender.setTitleColor(.orange, for: .normal)
        
        switch sender.tag{
        
        case 101:
            self.currentPresetIndex = 1
            break
            
        case 102:
            self.currentPresetIndex = 2
            break
            
        case 103:
            self.currentPresetIndex = 3
            break
            
        case 104:
            self.currentPresetIndex = 4
            break
            
        case 105:
            self.currentPresetIndex = 5
            break
            
        case 106:
            self.currentPresetIndex = 6
            break
            
        case 107:
            self.currentPresetIndex = 7
            break
            
        case 108:
            self.currentPresetIndex = 8
            break
            
        case 109:
            self.currentPresetIndex = 9
            break
            
        default:
            
            break
        }
        
        self.queueHTTP.async {
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._8_cmd_get_node_info_for_preset)
            }else{
                self.dismissLoadingView()
            }
        }
    }
}
//
extension ControlBoxMappingViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.previewCollectionView {
            var deviceInfo = self.rxList[indexPath.item]
            if(deviceInfo.alive != "n"){
                self.isDialogShowing = true
//                ASpeedRXDialogViewController.deviceIP = deviceInfo.ip
//                ASpeedRXDialogViewController.deviceGroupId = deviceInfo.group_id
//                ASpeedRXDialogViewController.deviceName = deviceInfo.name
                ControlBoxMappingSourceDialogViewController.userSelectSourceIP = deviceInfo.ip
                ControlBoxMappingSourceDialogViewController.userSelectSourceName = deviceInfo.name
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: ControlBoxMappingSourceDialogViewController.typeName) as! ControlBoxMappingSourceDialogViewController
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }else{
                self.showToast(context: "This device is off-line !")
            }
        }else{
            var deviceInfo = ControlBoxMappingViewController.txOnlineList[indexPath.item]
            if(deviceInfo.alive != "n"){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: ASpeedTXDialogViewController.typeName) as! ASpeedTXDialogViewController
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
                ASpeedTXDialogViewController.deviceIP = deviceInfo.ip
                ASpeedTXDialogViewController.deviceGroupId = deviceInfo.group_id
                ASpeedTXDialogViewController.deviceName = deviceInfo.name
            }else{
                self.showToast(context: "This device is off-line !")
            }
        }
    }
}

extension ControlBoxMappingViewController{
    
    func recursiveSwitchAllRX(currentIndex : Int, txGroupId : String){
        
        if(currentIndex <= (self.rxList.count - 1)){
            
            if(self.rxList[currentIndex].alive == "y"){
                self.queueHTTP.async {
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        var data  = ["ip": self.rxList[currentIndex].ip,"switch_id":txGroupId,"switch_type":"z"]
                        AF.upload(multipartFormData: { (multiFormData) in
                            for (key, value) in data {
                                multiFormData.append(Data(value.utf8), withName: key)
                            }
                        }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_switch_group_id).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                print("recursive response is :\(response)")
                                if((currentIndex + 1) > (self.rxList.count - 1 )){
                                    self.showToast(context: "Switch all RX finish !")
                                }else{
                                    self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                }
                            case .failure(_):
                                print("recursive fail")
                                if((currentIndex + 1) > (self.rxList.count - 1 )){
                                    self.showToast(context: "Switch all RX finish !")
                                }else{
                                    self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                }
                            }
                        }
                    }else{
                        
                    }
                }
            }else{
                if((currentIndex + 1) > (self.rxList.count - 1 )){
                    self.showToast(context: "Switch all RX finish !")
                }else{
                    self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                }
            }
        }
    }
}

extension ControlBoxMappingViewController : UICollectionViewDataSource{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        switch scrollView {
        case self.previewCollectionView:
            for cell in self.previewCollectionView.visibleCells as [ControlBoxMappingDisplayCollectionViewCell]{
                var currentCell = cell
                var mac = currentCell.mac.text
                var rxDevice: Device? = nil
                
                for device in self.rxList{
                    if(device.mac != mac ){
                    }else{
                        rxDevice = device
                        break
                    }
                }
                
                if(rxDevice!.alive != "y"){
                    currentCell.preview.image =  UIImage(named: "offline")
                }else{
                    
                    var txMac = "bzb"
                    for txDevice in ControlBoxMappingViewController.txOnlineList{
                        if(txDevice.group_id != rxDevice?.group_id){
                            
                        }else{
                            txMac = txDevice.mac
                        }
                    }
                    
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        self.queueHTTP.async {
                            AF.request("http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_get_mobile_preview + "/" + txMac , method: .get){ urlRequest in
                                urlRequest.timeoutInterval = 5
                                urlRequest.allowsExpensiveNetworkAccess = false
                            }.response{ response in
                                debugPrint(response)
                                switch response.result{
                                
                                case .success(let value):
                                    
                                    do {
                                        let responseDecoded = try JSONDecoder().decode(previewStruct.self, from: value!)
                                        print("on name  = " , currentCell.deviceName.text)
                                        if(responseDecoded.result != "ok"){
                                            DispatchQueue.main.async() {
                                                currentCell.preview.image =  UIImage(named: "nosignal")
                                            }
                                        }else{
                                            //check tx is not plug source
                                            if(responseDecoded.base64.length < 50){
                                                DispatchQueue.main.async() {
                                                    currentCell.preview.image =  UIImage(named: "nosignal")
                                                }
                                            }else{
                                                if let decodedData = Data(base64Encoded: responseDecoded.base64, options: .ignoreUnknownCharacters) {
                                                    let image = UIImage( data: decodedData)
                                                    DispatchQueue.main.async() {
                                                        currentCell.preview.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }catch let error as NSError{
                                        print(error)
                                    }
                                    break
                                    
                                case .failure(let error):
                                    debugPrint("HTTP GET request failed")
                                    break
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            break
            
        case self.sourceCollectionView:
            for cell in self.sourceCollectionView.visibleCells as [ControlBoxSourceCollectionViewCell]{
                var currentCell = cell
                var mac = currentCell.mac.text
                var txDevice: Device? = nil
                
                for device in ControlBoxMappingViewController.txOnlineList{
                    if(device.mac != mac ){
                    }else{
                        txDevice = device
                        break
                    }
                }
                
                if(txDevice!.alive != "y"){
                    currentCell.preview.image =  UIImage(named: "offline")
                }else{
                
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        self.queueHTTP.async {
                            AF.request("http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_get_mobile_preview + "/" + mac! , method: .get){ urlRequest in
                                urlRequest.timeoutInterval = 5
                                urlRequest.allowsExpensiveNetworkAccess = false
                            }.response{ response in
                                debugPrint(response)
                                switch response.result{
                                
                                case .success(let value):
                                    
                                    do {
                                        let responseDecoded = try JSONDecoder().decode(previewStruct.self, from: value!)
                                        print("on name  = " , currentCell.deviceName.text)
                                        if(responseDecoded.result != "ok"){
                                            DispatchQueue.main.async() {
                                                currentCell.preview.image =  UIImage(named: "nosignal")
                                            }
                                        }else{
                                            //check tx is not plug source
                                            if(responseDecoded.base64.length < 50){
                                                DispatchQueue.main.async() {
                                                    currentCell.preview.image =  UIImage(named: "nosignal")
                                                }
                                            }else{
                                                if let decodedData = Data(base64Encoded: responseDecoded.base64, options: .ignoreUnknownCharacters) {
                                                    let image = UIImage( data: decodedData)
                                                    DispatchQueue.main.async() {
                                                        currentCell.preview.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }catch let error as NSError{
                                        print(error)
                                    }
                                    break
                                    
                                case .failure(let error):
                                    debugPrint("HTTP GET request failed")
                                    break
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.previewCollectionView {
            return self.rxList.count
        }else {
            return ControlBoxMappingViewController.txOnlineList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.previewCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxMappingDisplayCollectionViewCell", for: indexPath) as! ControlBoxMappingDisplayCollectionViewCell
            
            cell.preview.image = nil
            cell.deviceName.text = self.rxList[indexPath.item].name
            cell.mac.text = self.rxList[indexPath.item].mac
            if(self.rxList[indexPath.item].alive != "y"){
                cell.preview.image = UIImage(named: "offline")
            }
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxSourceCollectionViewCell", for: indexPath) as! ControlBoxSourceCollectionViewCell
            
            cell.preview.image = nil
            cell.deviceName.text = ControlBoxMappingViewController.txOnlineList[indexPath.item].name
            cell.mac.text = ControlBoxMappingViewController.txOnlineList[indexPath.item].mac
            if(ControlBoxMappingViewController.txOnlineList[indexPath.item].alive != "y"){
                cell.preview.image = UIImage(named: "offline")
            }
            return cell
        }
        
    }
}
//
extension ControlBoxMappingViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.previewCollectionView {
            if(ControlBoxMappingViewController.isPhone){
                return CGSize(width: (self.view.frame.size.width)/2.5 , height: (self.view.frame.size.width) / 3.3)
            }else{
                return CGSize(width: (self.view.frame.size.width) / 3.4 , height: (self.view.frame.size.height) / 6.8)
            }
        }
        else {
            if(ControlBoxMappingViewController.isPhone){
                return CGSize(width: (self.view.frame.size.width)/2.2 , height: (self.view.frame.size.width) / 6)
            }else{
                return CGSize(width: (self.view.frame.size.width) / 3.6 , height: (self.view.frame.size.height) / 10)
            }
        }
        
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxMappingViewController.isPhone){
            return 20
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxMappingViewController.isPhone){
            return 8
        }else{
            return 12
        }
    }
}
//
extension ControlBoxMappingViewController {
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        
        
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd, method: .get){ urlRequest in
            urlRequest.timeoutInterval = 5
            urlRequest.allowsExpensiveNetworkAccess = false
        }.response{ response in
            //debugPrint(response)
            
            switch response.result{
            
            case .success(let value):
                
                let json = JSON(value)
                //print(json.type)
                
                // debugPrint(json)
                switch(cmdNumber){
                
                case HTTPCmdHelper._1_cmd_get_node_info:
                    print("_1_cmd_get_node_info")
                    
                    self.handleGetDevice(json: json)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break
                    
                case HTTPCmdHelper._6_cmd_get_node_info_without_loading:
                    print("_6_cmd_get_node_info_without_loading")
                    self.handleGetDevice(json: json)
                    break
                    
                case HTTPCmdHelper._8_cmd_get_node_info_for_preset:
                    print("_8_cmd_get_node_info_for_preset")
                    self.rxForPreset.removeAll()
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            let ip = deviceObject["ip"].stringValue
                            let name = deviceObject["host_name"].stringValue
                            let pin = deviceObject["pin"].stringValue
                            let alive = deviceObject["alive"].stringValue
                            let group_id = deviceObject["id"].stringValue
                            let mac = deviceObject["mac"].stringValue
                            
                            if(deviceObject["type"].stringValue != "r"){
                            }else{
                                print(ip, name, pin, mac)
                                self.rxForPreset.append(Device(name: name, ip: ip, alive: alive, pin:pin, group_id: group_id, mac: mac))
                            }
                        }
                        self.queueHTTP.async {
                            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                            if(device_ip != nil){
                                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_mapping_preset, cmdNumber: HTTPCmdHelper._9_cmd_get_mapping_preset)
                            }else{
                                self.dismissLoadingView()
                            }
                        }
                    }
                    break
                    
                case HTTPCmdHelper._9_cmd_get_mapping_preset:
                    print("_9_cmd_get_mapping_preset")
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if let presetList = json[0]["preset"].array {
                        for presetObject in presetList{
                            var index = presetObject["index"].stringValue
                            print("index", index)
                            if(self.currentPresetIndex == Int(index)){
                                if let settingList = presetObject["setting"].array{
                                    for settingObject in settingList{
                                        if(settingObject["type"].stringValue != "t"){
                                            for rxDevice in self.rxForPreset{
                                                if(settingObject["mac"].stringValue == rxDevice.mac){
                                                    if(rxDevice.alive != "n"){
                                                        print("ip = ", rxDevice.ip)
                                                        if(device_ip != nil){
                                                            var data  = ["ip": rxDevice.ip,"switch_id": settingObject["id"].stringValue,"switch_type":"z"]
                                                            AF.upload(multipartFormData: { (multiFormData) in
                                                                for (key, value) in data {
                                                                    multiFormData.append(Data(value.utf8), withName: key)
                                                                }
                                                            }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_switch_group_id).responseJSON { response in
                                                                switch response.result {
                                                                case .success(let JSON):
                                                                    print("response is :\(response)")
                                                                    self.refresh()
                                                                case .failure(_):
                                                                    print("fail")
                                                                    self.showToast(context: "Switch channel failed !")
                                                                }
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: false, completion: nil)
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

//Button click event
extension ControlBoxMappingViewController {
    
    // Handle get device json & update UI
    func handleGetDevice(json: JSON){
        
        self.rxList.removeAll()
        //  self.txAllList.removeAll()
        ControlBoxMappingViewController.txOnlineList.removeAll()
        
        if let deviceList = json.array {
            for deviceObject in deviceList {
                let ip = deviceObject["ip"].stringValue
                let name = deviceObject["host_name"].stringValue
                let pin = deviceObject["pin"].stringValue
                let alive = deviceObject["alive"].stringValue
                let group_id = deviceObject["id"].stringValue
                let mac = deviceObject["mac"].stringValue
                
                if(deviceObject["type"].stringValue != "r"){
                    //   self.txAllList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id, mac: mac))
                    if(alive == "y"){
                        ControlBoxMappingViewController.txOnlineList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id, mac: mac))
                        //     self.txNameForUI.append(name)
                    }
                    
                }else{
                    self.rxList.append(Device(name: name, ip: ip, alive: alive, pin:pin, group_id: group_id, mac: mac))
                }
                print(ip, name, pin, mac)
            }
        }
        
        ControlBoxMappingViewController.txOnlineList = ControlBoxMappingViewController.txOnlineList.sorted { (lhs, rhs) -> Bool in
            return (lhs.name, lhs.ip, lhs.alive, lhs.pin, lhs.group_id) < (rhs.name, rhs.ip, rhs.alive, rhs.pin, rhs.group_id)
        }
        
        //        self.txAllList = self.txAllList.sorted { (lhs, rhs) -> Bool in
        //            return (lhs.name, lhs.ip, lhs.alive, lhs.pin, lhs.group_id) < (rhs.name, rhs.ip, rhs.alive, rhs.pin, rhs.group_id)
        //        }
        
        self.rxList = self.rxList.sorted { (lhs, rhs) -> Bool in
            return (lhs.name, lhs.ip, lhs.alive, lhs.pin, lhs.group_id) < (rhs.name, rhs.ip, rhs.alive, rhs.pin, rhs.group_id)
        }
        
        if(self.currentRxDeviceSize != self.rxList.count){
            DispatchQueue.main.async() {
                self.previewCollectionView.reloadData()
            }
            
        }
        
        DispatchQueue.main.async() {
            self.sourceCollectionView.reloadData()
        }
        
        self.currentRxDeviceSize = self.rxList.count
        
        //update device preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            
            //update rx preview
            for cell in self.previewCollectionView.visibleCells as [ControlBoxMappingDisplayCollectionViewCell] {
                
                var currentCell = cell
                var mac = currentCell.mac.text
                var rxDevice: Device? = nil
                
                for device in self.rxList{
                    if(device.mac != mac ){
                    }else{
                        rxDevice = device
                        break
                    }
                }
                
                if(rxDevice!.alive != "y"){
                    currentCell.preview.image =  UIImage(named: "offline")
                }else{
                    
                    var txMac = "bzb"
                    for txDevice in ControlBoxMappingViewController.txOnlineList{
                        if(txDevice.group_id != rxDevice?.group_id){
                            
                        }else{
                            txMac = txDevice.mac
                        }
                    }
                    
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        self.queueHTTP.async {
                            AF.request("http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_get_mobile_preview + "/" + txMac , method: .get){ urlRequest in
                                urlRequest.timeoutInterval = 5
                                urlRequest.allowsExpensiveNetworkAccess = false
                            }.response{ response in
                                //  debugPrint(response)
                                switch response.result{
                                
                                case .success(let value):
                                    
                                    do {
                                        let responseDecoded = try JSONDecoder().decode(previewStruct.self, from: value!)
                                        print("on name  = " , currentCell.deviceName.text)
                                        if(responseDecoded.result != "ok"){
                                            DispatchQueue.main.async() {
                                                currentCell.preview.image =  UIImage(named: "nosignal")
                                            }
                                        }else{
                                            //check tx is not plug source
                                            if(responseDecoded.base64.length < 50){
                                                DispatchQueue.main.async() {
                                                    currentCell.preview.image =  UIImage(named: "nosignal")
                                                }
                                            }else{
                                                if let decodedData = Data(base64Encoded: responseDecoded.base64, options: .ignoreUnknownCharacters) {
                                                    let image = UIImage( data: decodedData)
                                                    DispatchQueue.main.async() {
                                                        currentCell.preview.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }catch let error as NSError{
                                        print(error)
                                    }
                                    break
                                    
                                case .failure(let error):
                                    debugPrint("HTTP GET request failed")
                                    break
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            
            //update TX preview
            for cell in self.sourceCollectionView.visibleCells as [ControlBoxSourceCollectionViewCell]{
                var currentCell = cell
                var mac = currentCell.mac.text
                var txDevice: Device? = nil
                
                for device in ControlBoxMappingViewController.txOnlineList{
                    if(device.mac != mac ){
                    }else{
                        txDevice = device
                        break
                    }
                }
                
                if(txDevice!.alive != "y"){
                    currentCell.preview.image =  UIImage(named: "offline")
                }else{
                
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        self.queueHTTP.async {
                            AF.request("http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_get_mobile_preview + "/" + mac! , method: .get){ urlRequest in
                                urlRequest.timeoutInterval = 5
                                urlRequest.allowsExpensiveNetworkAccess = false
                            }.response{ response in
                                debugPrint(response)
                                switch response.result{
                                
                                case .success(let value):
                                    
                                    do {
                                        let responseDecoded = try JSONDecoder().decode(previewStruct.self, from: value!)
                                        print("on name  = " , currentCell.deviceName.text)
                                        if(responseDecoded.result != "ok"){
                                            DispatchQueue.main.async() {
                                                currentCell.preview.image =  UIImage(named: "nosignal")
                                            }
                                        }else{
                                            //check tx is not plug source
                                            if(responseDecoded.base64.length < 50){
                                                DispatchQueue.main.async() {
                                                    currentCell.preview.image =  UIImage(named: "nosignal")
                                                }
                                            }else{
                                                if let decodedData = Data(base64Encoded: responseDecoded.base64, options: .ignoreUnknownCharacters) {
                                                    let image = UIImage( data: decodedData)
                                                    DispatchQueue.main.async() {
                                                        currentCell.preview.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }catch let error as NSError{
                                        print(error)
                                    }
                                    break
                                    
                                case .failure(let error):
                                    debugPrint("HTTP GET request failed")
                                    break
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func refresh(){
        self.queueHTTP.async {
            
            DispatchQueue.main.async() {
                // self.searchText.text = ""
            }
            
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }else{
                
            }
        }
        
    }
}
