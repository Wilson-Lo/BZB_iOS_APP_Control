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
    
    @IBOutlet weak var btRefresh: UIButton!
    @IBOutlet weak var collectionRX: UICollectionView!
    @IBOutlet weak var collectionTX: UICollectionView!
    var queueHTTP: DispatchQueue!
    var rxList: Array<Device> = []
    var txAllList: Array<Device> = []
    var txOnlineList: Array<Device> = []
    var txMenu: RSSelectionMenu<String>!
    var txNameForUI: Array<String> = []
    
    //device info structure
    struct Device {
        let name: String
        let ip: String
        let alive: String
        let pin: String
        let group_id: String
    }
    
    override func viewDidLoad() {
        print("ControlBoxMappingViewController-viewDidLoad")
        super.viewDidLoad()
        setupUI()
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("ControlBoxMappingViewController-viewWillAppear")
        
        self.queueHTTP.async {
            self.showLoadingView()
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }else{
                self.dismissLoadingView()
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ControlBoxMappingViewController-viewWillDisappear")
    }
    
}

extension ControlBoxMappingViewController{
    
    func setupUI(){
        UINavigationBar.appearance().barTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        
        self.btRefresh.layer.cornerRadius = 5
        self.btRefresh.layer.borderWidth = 1
        self.btRefresh.layer.borderColor = UIColor.black.cgColor
    }
}

extension ControlBoxMappingViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionRX {
            let title = "\n" + self.rxList[indexPath.item].name
            let message = ""
            
            // Create the dialog,
            let popup = PopupDialog(title: title, message: message, image: nil)
            
            var btArray: Array<CancelButton> = []
            if(!ControlBoxMappingViewController.isPhone){
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
            
            btArray.append(CancelButton(title: "On") {
                self.queueHTTP.async {
                    self.showLoadingView()
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        
                        var data  = ["ip": self.rxList[indexPath.item].ip,"value":"echo 0 > /sys/devices/platform/display/screen_off"]
                        
                        AF.upload(multipartFormData: { (multiFormData) in
                            for (key, value) in data {
                                multiFormData.append(Data(value.utf8), withName: key)
                            }
                        }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_send_cmd).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                print("response is :\(response)")
                                DispatchQueue.main.async {
                                    self.showToast(context: "Turn on successful !")
                                }
                            case .failure(_):
                                print("fail")
                                self.showToast(context: "Turn on failed !")
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.dismiss(animated: false, completion: nil)
                        }
                    }else{
                        
                    }
                }
            })
            
            btArray.append(CancelButton(title: "Off") {
                self.queueHTTP.async {
                    self.showLoadingView()
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        
                        var data  = ["ip": self.rxList[indexPath.item].ip,"value":"echo 1 > /sys/devices/platform/display/screen_off"]
                        
                        AF.upload(multipartFormData: { (multiFormData) in
                            for (key, value) in data {
                                multiFormData.append(Data(value.utf8), withName: key)
                            }
                        }, to: "http://" + device_ip! + ":" + self.SERVER_PORT + HTTPCmdHelper.cmd_send_cmd).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                print("response is :\(response)")
                                self.showToast(context: "Turn off successful !")
                            case .failure(_):
                                print("fail")
                                self.showToast(context: "Turn off failed !")
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.dismiss(animated: false, completion: nil)
                        }
                    }else{
                        
                    }
                }
            })
            
            btArray.append(CancelButton(title: "Switch Channel") {
                
                DispatchQueue.main.async() {
                    
                    self.txMenu = RSSelectionMenu(dataSource: self.txNameForUI) { (cell, name, indexPath) in
                        cell.textLabel?.text = name
                    }
                    
                    self.txMenu.title = "Select TX"
                    
                    // provide selected items
                    var selectedNames: [String] = []
                    
                    self.txMenu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                        
                        self.queueHTTP.async {
                            self.showLoadingView()
                            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                            if(device_ip != nil){
                                print(self.txAllList[index].group_id + "-" + self.rxList[indexPath.item].ip)
                                var data  = ["ip": self.rxList[indexPath.item].ip,"switch_id":self.txOnlineList[index].group_id,"switch_type":"z"]
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
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.dismiss(animated: false, completion: nil)
                                }
                            }else{
                                
                            }
                        }
                    }
                    self.txMenu.show(from: self)
                }
            })
            
            btArray.append(CancelButton(title: "Blink Red Light") {
                self.queueHTTP.async {
                    self.showLoadingView()
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        
                        var data  = ["ip": self.rxList[indexPath.item].ip,"value":"echo 2 > /sys/devices/platform/ast1500_led.2/leds:button_link/N_Led"]
                        
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
                    }else{
                        
                    }
                }
            })
            
            popup.addButtons(btArray)
            
            self.present(popup, animated: true, completion: nil)
        }
        else {
            let title = "\n" + self.txAllList[indexPath.item].name
            let message = ""
            
            // Create the dialog,
            let popup = PopupDialog(title: title, message: message, image: nil)
            
            var btArray: Array<CancelButton> = []
            if(!ControlBoxMappingViewController.isPhone){
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
            
            btArray.append(CancelButton(title: "Switch for All RX") {
                self.showLoadingView()
                self.recursiveSwitchAllRX(currentIndex: 0, txGroupId: self.txAllList[indexPath.item].group_id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: false, completion: nil)
                    self.showToast(context: "Switch for All RX finish!")
                    self.queueHTTP.async {
                        self.refresh()
                    }
                }
            })
            
            btArray.append(CancelButton(title: "Blink Red Light") {
                self.queueHTTP.async {
                    self.showLoadingView()
                    var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                    if(device_ip != nil){
                        
                        var data  = ["ip": self.txAllList[indexPath.item].ip,"value":"cat /sys/devices/platform/ast1500_led.2/leds:button_link/N_Led"]
                        
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
                    }else{
                        
                    }
                }
            })
            popup.addButtons(btArray)
            self.present(popup, animated: true, completion: nil)
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
                                    //  self.refresh()
                                }else{
                                    self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                }
                            case .failure(_):
                                print("recursive fail")
                                if((currentIndex + 1) > (self.rxList.count - 1 )){
                                    self.showToast(context: "Switch all RX finish !")
                                    // self.refresh()
                                }else{
                                    self.recursiveSwitchAllRX(currentIndex: (currentIndex + 1), txGroupId: txGroupId)
                                }
                            }
                        }
                    }else{
                        
                    }
                }
            }
            
            
        }
    }
}

extension ControlBoxMappingViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionTX {
            return self.txAllList.count
        }
        
        else {
            return self.rxList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionTX {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxTXCollectionViewCell", for: indexPath) as! ControlBoxTXCollectionViewCell
            
            cell.labelName.text = self.txAllList[indexPath.item].name
            
            if(self.txAllList[indexPath.item].alive != "y"){
                cell.labelStatus.text = "Off-line"
                //cell.labelStatus.tintColor = UIColor.red
            }else{
                cell.labelStatus.text = "On-line"
                // cell.labelStatus.tintColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
            }
            //            cell.groupIDText.text = self.rxList[indexPath.item].group_id
            //            cell.ipText.text = self.rxList[indexPath.item].ip
            
            //            var isHasTX:Bool = false
            //
            //            for txObject in self.txAllList {
            //                if(self.rxList[indexPath.item].group_id == txObject.group_id){
            //                    cell.txNameText.text = txObject.name
            //                    isHasTX = true
            //                    break
            //                }
            //            }
            //
            //            if(!isHasTX){
            //                cell.txNameText.text = "N/A"
            //            }
            //
            //            if(self.rxList[indexPath.item].alive != "y"){
            //                cell.deviceName.backgroundColor = UIColor.red
            //            }else{
            //                cell.deviceName.backgroundColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
            //            }
            return cell
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxRXCollectionViewCell", for: indexPath) as! ControlBoxRXCollectionViewCell
            
            cell.labelName.text = self.rxList[indexPath.item].name
            
            var isHasTX:Bool = false
            
            for txObject in self.txAllList {
                if(self.rxList[indexPath.item].group_id == txObject.group_id){
                    cell.labelTXName.text = txObject.name
                    isHasTX = true
                    break
                }
            }
            
            if(!isHasTX){
                cell.labelTXName.text = "N/A"
            }
            
            if(self.rxList[indexPath.item].alive != "y"){
                cell.labelStatus.text = "Off-line"
                //cell.labelStatus.tintColor = UIColor.red
            }else{
                cell.labelStatus.text = "On-line"
                // cell.labelStatus.tintColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
            }
            //            print(indexPath.item)
            //            if(self.txAllList.count > 0){
            //                cell.deviceName.text = self.txAllList[indexPath.item].name
            //                cell.groupIDText.text = self.txAllList[indexPath.item].group_id
            //                cell.ipText.text = self.txAllList[indexPath.item].ip
            //                if(self.txAllList[indexPath.item].alive != "y"){
            //                    cell.deviceName.backgroundColor = UIColor.red
            //                }else{
            //                    cell.deviceName.backgroundColor = UIColor(red: 55/255, green: 142/255, blue: 87/255, alpha: 1)
            //                }
            //            }
            return cell
        }
        
    }
}

extension ControlBoxMappingViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionTX {
            if(ControlBoxMappingViewController.isPhone){
                return CGSize(width: (self.view.frame.size.width)/4 , height: (self.view.frame.size.width) / 4)
            }else{
                return CGSize(width: (self.view.frame.size.width - 60) / 2 , height: (self.view.frame.size.width - 170) / 2)
            }
        }
        else {
            if(ControlBoxMappingViewController.isPhone){
                return CGSize(width: (self.view.frame.size.width)/4 , height: (self.view.frame.size.width) / 4)
            }else{
                return CGSize(width: (self.view.frame.size.width - 60) / 2 , height: (self.view.frame.size.width - 170) / 2)
            }
        }
        
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVideoWallViewController.isPhone){
            return 20
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxVideoWallViewController.isPhone){
            return 10
        }else{
            return 12
        }
    }
}

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
                
               // debugPrint(json)
                switch(cmdNumber){
                
                case HTTPCmdHelper._1_cmd_get_node_info:
                    print("_1_cmd_get_node_info")
                    self.rxList.removeAll()
                    self.txAllList.removeAll()
                    self.txNameForUI.removeAll()
                    self.txOnlineList.removeAll()
                    
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            let ip = deviceObject["ip"].stringValue
                            let name = deviceObject["host_name"].stringValue
                            let pin = deviceObject["pin"].stringValue
                            let alive = deviceObject["alive"].stringValue
                            let group_id = deviceObject["id"].stringValue
                            if(deviceObject["type"].stringValue != "r"){
                                self.txAllList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id))
                                if(alive == "y"){
                                    self.txOnlineList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id))
                                    self.txNameForUI.append(name)
                                }
                                
                            }else{
                                self.rxList.append(Device(name: name, ip: ip, alive: alive, pin:pin, group_id: group_id))
                            }
                            print(ip, name, pin)
                        }
                    }
                    
                    self.collectionTX.reloadData()
                    self.collectionRX.reloadData()
                    //                    self.collectionRX.reloadData()
                    //                    self.collectionTX.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break
                    
                case HTTPCmdHelper._2_cmd_search_get_node_info:
                    print("_2_cmd_search_get_node_info")
                    //    print(self.searchText.text)
                    //if(self.searchText.text!.length > 0){
                    self.rxList.removeAll()
                    self.txAllList.removeAll()
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            let ip = deviceObject["ip"].stringValue
                            let name = deviceObject["host_name"].stringValue
                            let pin = deviceObject["pin"].stringValue
                            let alive = deviceObject["alive"].stringValue
                            let group_id = deviceObject["id"].stringValue
                            if(deviceObject["type"].stringValue != "r"){
                                //                                    if(name.contains(self.searchText.text!)){
                                //                                        self.txAllList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id))
                                //                                    }
                                
                                if(alive == "y"){
                                    self.txOnlineList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id))
                                    self.txNameForUI.append(name)
                                }
                            }else{
                                //                                    if(name.contains(self.searchText.text!)){
                                //                                        self.rxList.append(Device(name: name, ip: ip, alive: alive, pin:pin, group_id: group_id))
                                //                                    }
                            }
                            print(ip, name, pin)
                        }
                    }
                    
                    // self.collectionRX.reloadData()
                    // self.collectionTX.reloadData()
                    //    }
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
    
    
    @IBAction func btSearch(sender: UIButton) {
        self.queueHTTP.async {
            self.showLoadingView()
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._2_cmd_search_get_node_info)
            }else{
                
            }
        }
    }
    
    @IBAction func btRefresh(sender: UIButton) {
        self.queueHTTP.async {
            
            DispatchQueue.main.async() {
                self.showLoadingView()
                //self.searchText.text = ""
            }
            
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }else{
                
            }
        }
    }
}
