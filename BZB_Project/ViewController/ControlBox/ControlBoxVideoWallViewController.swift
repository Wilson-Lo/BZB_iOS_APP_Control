//
//  ControllerBoxVideoWallViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/5/20.
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
    
    
    @IBOutlet weak var btPreset: UIButton!
    @IBOutlet weak var labelRow: UITextField!
    @IBOutlet weak var labelCol: UITextField!
    @IBOutlet weak var btApply: UIButton!
    @IBOutlet weak var btReset: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var presetNameForUI: Array<String> = []
    var presetDataList: Array<Device> = []
    
    //preset rx device structure
    struct Device {
        let name: String
        let pos: String
        let mac: String
        let he_shift: String
        let ve_shift: String
        let vs_shift: String
        let hs_shift: String
    }
    
    override func viewDidLoad() {
        print("ControlBoxVideoWallViewController-viewDidLoad")
        super.viewDidLoad()
        initialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ControlBoxVideoWallViewController-viewWillAppear")
        super.viewWillAppear(true)
        var device_ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
        if(device_ip != nil){
            self.sendHTTPGET(ip: device_ip!, cmd: HTTPCmdHelper.cmd_video_wall_preset, cmdNumber: HTTPCmdHelper._4_cmd_video_wall_preset)
        }else{
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ControlBoxVideoWallViewController-viewWillDisappear")
       
    }
    
}

extension ControlBoxVideoWallViewController{
    
    func initialUI(){
        
        self.btPreset.layer.cornerRadius = 5
        self.btPreset.layer.borderWidth = 1
        self.btPreset.layer.borderColor = UIColor.black.cgColor
        
        self.btApply.layer.cornerRadius = 5
        self.btApply.layer.borderWidth = 1
        self.btApply.layer.borderColor = UIColor.black.cgColor
        
        self.btReset.layer.cornerRadius = 5
        self.btReset.layer.borderWidth = 1
        self.btReset.layer.borderColor = UIColor.black.cgColor
        
        if(ControlBoxMappingRXViewController.isPhone){
            print("is phone")
            
            
            
        }else{
            print("is pad")
            
            
        }
    }
    
}

extension ControlBoxVideoWallViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
      
       
    }
}


extension ControlBoxVideoWallViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presetDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControlBoxPresetCollectionViewCell", for: indexPath) as! ControlBoxPresetCollectionViewCell
        
        cell.indexLable.text = self.presetDataList[indexPath.item].pos
        cell.nameLabel.text = self.presetDataList[indexPath.item].mac
        
        return cell
    }
}

extension ControlBoxVideoWallViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //setup CollectionViewCell width, height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(ControlBoxMappingTXViewController.isPhone){
            return CGSize(width: (self.view.frame.size.width - 50) , height: (self.view.frame.size.width) / 5)
        }else{
            return CGSize(width: (self.view.frame.size.width - 60) / 2 , height: (self.view.frame.size.width - 170) / 2)
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

//Button click event
extension ControlBoxVideoWallViewController {
    
    @IBAction func btPreset(sender: UIButton) {
        DispatchQueue.main.async() {
            
            var presetMenu = RSSelectionMenu(dataSource: self.presetNameForUI) { (cell, name, indexPath) in
                cell.textLabel?.text = name
            }
            
            presetMenu.title = "Select Preset"
            
            // provide selected items
            var selectedNames: [String] = []
            
            presetMenu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                
            }
            
            presetMenu.show(from: self)
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
                            
                            if(index == "1"){
                                self.labelRow.text = row
                                self.labelCol.text = col
                                self.btPreset.setTitle(name, for: .normal)
                            
                                if let rxList = deviceObject["rx_list"].array {
                                    for rxObject in rxList {
                                        let mac = rxObject["mac"].stringValue
                                        debugPrint("mac = " + mac)
                                        self.presetDataList.append(Device(name: "",pos: rxObject["pos"].stringValue, mac: rxObject["mac"].stringValue, he_shift: rxObject["mac"].stringValue, ve_shift: rxObject["ve_shift"].stringValue, vs_shift: rxObject["vs_shift"].stringValue, hs_shift: rxObject["hs_shift"].stringValue))
                                    }
                                }
                                self.collectionView.reloadData()
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
