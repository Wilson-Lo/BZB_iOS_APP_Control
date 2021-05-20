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
    
    override func viewDidLoad() {
        print("ControlBoxVideoWallViewController-viewDidLoad")
        initialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ControlBoxVideoWallViewController-viewWillAppear")
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
                    
                    if let deviceList = json.array {
                        for deviceObject in deviceList {
                            
                            let tx_mac = deviceObject["tx_mac"].stringValue
                            let row = deviceObject["row"].stringValue
                            let col = deviceObject["col"].stringValue
                            let index = deviceObject["index"].stringValue
                            let name = deviceObject["name"].stringValue
                            
                            if(index == "1"){
                                self.labelRow.text = row
                                self.labelCol.text = col
                                self.btPreset.setTitle(name, for: .normal)
                            }
                            
                            if let rxList = deviceObject["rx_list"].array {
                                for rxObject in rxList {
                                    let mac = rxObject["mac"].stringValue
                                    debugPrint("mac = " + mac)
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
