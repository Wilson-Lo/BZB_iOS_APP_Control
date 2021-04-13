//
//  ControlBoxMappingViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/13.
//

import UIKit
import Network
import RSSelectionMenu
import Toast_Swift
import SwiftSocket
import SwiftyJSON
import Alamofire

class ControlBoxMappingRXViewController : BaseViewController{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var queueHTTP: DispatchQueue!
    var rxList: Array<Device> = []
    var txList: Array<Device> = []
    
    //device info structure (mac & ip)
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
        self.queueHTTP = DispatchQueue(label: "com.bzb.http", qos: DispatchQoS.userInitiated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("ControlBoxMappingRXViewController-viewWillAppear")
        self.queueHTTP.async {
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
                    break
                    
                default:
                    
                    break
                }
                
                break
                
            case .failure(let error):
                debugPrint("HTTP GET request failed")
                
                break
            }
        }
    }
}
