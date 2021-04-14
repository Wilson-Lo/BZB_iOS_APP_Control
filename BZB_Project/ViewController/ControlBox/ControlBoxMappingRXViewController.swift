//
//  ControlBoxMappingViewController.swift
//  BZB_Project
//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 GoMax. All rights reserved.
//

import UIKit
import Network
import RSSelectionMenu
import Toast_Swift
import SwiftSocket
import SwiftyJSON
import Alamofire
import PopupDialog

class ControlBoxMappingRXViewController : BaseViewController{
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    var queueHTTP: DispatchQueue!
    var rxList: Array<Device> = []
    var txList: Array<Device> = []
    
    @IBOutlet weak var btRefresh: UIButton!
    @IBOutlet weak var btSearch: UIButton!
    
    //device info structure
    struct Device {
        let name: String
        let ip: String
        let alive: Bool
        let pin: String
        let group_id: String
    }
    
    override func viewDidLoad() {
        print("ControlBoxMappingRXViewController-viewDidLoad")
        super.viewDidLoad()
        initialUI()
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("ControlBoxMappingRXViewController-viewWillAppear")
        self.queueHTTP.async {
            self.showLoadingView()
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }else{
                
            }
        }
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("ControlBoxMappingRXViewController-viewDidDisappear")
        
    }

}

extension ControlBoxMappingRXViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        let title = "\n"+self.rxList[indexPath.item].name
        let message = ""
        
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
        
        btArray.append(CancelButton(title: "On") {
          
        })
        
        btArray.append(CancelButton(title: "Off") {
          
        })
        
        btArray.append(CancelButton(title: "Switch Channel") {
          
        })
        
        btArray.append(CancelButton(title: "Blink Red Light") {
          
        })

        popup.addButtons(btArray)
        
        self.present(popup, animated: true, completion: nil)
    }
}

extension ControlBoxMappingRXViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.rxList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxRXCollectionViewCell", for: indexPath) as! ControlBoxRXCollectionViewCell
        //        if(self.mappingName.count > 3){
        cell.deviceName.text = self.rxList[indexPath.item].name
        cell.pinText.text = self.rxList[indexPath.item].group_id
        cell.ipText.text = self.rxList[indexPath.item].ip
        cell.deviceName.backgroundColor = UIColor.red
        //        }
        //        cell.index.text = "Mapping \(indexPath.item+1)"
        return cell
    }
}

extension ControlBoxMappingRXViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(ControlBoxMappingRXViewController.isPhone){
            return CGSize(width: (self.view.frame.size.width - 30) , height: (self.view.frame.size.width - 30) / 2)
        }else{
            return CGSize(width: (self.view.frame.size.width - 60) / 2 , height: (self.view.frame.size.width - 170) / 2)
        }
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxMappingRXViewController.isPhone){
            return 10
        }else{
            return 30
        }
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(ControlBoxMappingRXViewController.isPhone){
            return 10
        }else{
            return 12
        }
    }
}

extension ControlBoxMappingRXViewController{
    
    func initialUI(){
        if(ControlBoxMappingRXViewController.isPhone){
            print("is phone")
            //Refresh button
            let widthBtRefresh = btRefresh.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtRefresh = btRefresh.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtRefresh, heightBtRefresh])
            widthBtRefresh.constant = 40
            heightBtRefresh.constant = 40
            
            //Search button
            let widthBtSearch = btSearch.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtSearch = btSearch.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtSearch, heightBtSearch])
            widthBtSearch.constant = 40
            heightBtSearch.constant = 40
    
        }else{
            print("is pad")
            //Refresh button
            let widthBtRefresh = btRefresh.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtRefresh = btRefresh.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtRefresh, heightBtRefresh])
            //change button size to 50x50
            widthBtRefresh.constant = 80
            heightBtRefresh.constant = 80
            
            //Search button
            let widthBtSearch = btSearch.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtSearch = btSearch.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtSearch, heightBtSearch])
            widthBtSearch.constant = 80
            heightBtSearch.constant = 80
        }
    }
    
    
}

extension ControlBoxMappingRXViewController {
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd, method: .get).response{ response in
            debugPrint(response)
            
            switch response.result{
            
            case .success(let value):
                let json = JSON(value)
                
                debugPrint(json)
                switch(cmdNumber){
                
                case HTTPCmdHelper._1_cmd_get_node_info:
                    print("_1_cmd_get_node_info")
                    self.rxList.removeAll()
                    self.txList.removeAll()
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            let ip = deviceObject["ip"].stringValue
                            let name = deviceObject["host_name"].stringValue
                            let pin = deviceObject["pin"].stringValue
                            let alive = deviceObject["alive"].boolValue
                            let group_id = deviceObject["id"].stringValue
                            if(deviceObject["type"].stringValue != "r"){
                                print("t")
                                self.txList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id))
                            }else{
                                print("r")
                                self.rxList.append(Device(name: name, ip: ip, alive: alive, pin:pin, group_id: group_id))
                            }
                            print(ip, name, pin)
                        }
                    }
                    self.collectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break
                    
                case HTTPCmdHelper._2_cmd_search_get_node_info:
                    print("_2_cmd_search_get_node_info")
                    print(self.searchText.text)
                    if(self.searchText.text!.length > 0){
                        self.rxList.removeAll()
                        self.txList.removeAll()
                        if let deviceList = json.array {
                            for deviceObject in deviceList {
                                let ip = deviceObject["ip"].stringValue
                                let name = deviceObject["host_name"].stringValue
                                let pin = deviceObject["pin"].stringValue
                                let alive = deviceObject["alive"].boolValue
                                let group_id = deviceObject["id"].stringValue
                                if(deviceObject["type"].stringValue != "r"){
                                    self.txList.append(Device(name: name, ip: ip, alive: alive, pin: pin, group_id: group_id))
                                }else{
                                    if(name.contains(self.searchText.text!)){
                                        self.rxList.append(Device(name: name, ip: ip, alive: alive, pin:pin, group_id: group_id))
                                    }
                                }
                                print(ip, name, pin)
                            }
                        }
                        self.collectionView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break
                    
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break
                }
                
                break
                
            case .failure(let error):
                debugPrint("HTTP GET request failed")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.dismiss(animated: false, completion: nil)
                }
                break
            }
        }
    }
}

//Button click event
extension ControlBoxMappingRXViewController {
    
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
            self.showLoadingView()
            DispatchQueue.main.async() {
                self.searchText.text = ""
            }
      
            var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
            if(device_ip != nil){
                self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_get_node_info, cmdNumber: HTTPCmdHelper._1_cmd_get_node_info)
            }else{
                
            }
        }
    }
    
}
