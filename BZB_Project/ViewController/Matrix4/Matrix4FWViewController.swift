//
//  Matrix4FWViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/12.
//

import UIKit


class Matrix4FWViewController :BaseSocketViewController{
    
    @IBOutlet weak var btFW: UIButton!
    
    override func viewDidLoad() {
        print("Matrix4FWViewController-viewDidLoad")
        super.viewDidLoad()
        initialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("Matrix4FWViewController-viewWillAppear")
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4FWViewController-viewDidDisappear")
            
    }
}

extension Matrix4FWViewController{
    
    func initialUI(){
        let widthBtRefresh = btFW.widthAnchor.constraint(equalToConstant: 30.0)
        let heightBtRefresh = btFW.heightAnchor.constraint(equalToConstant: 30.0)
        NSLayoutConstraint.activate([widthBtRefresh, heightBtRefresh])
        widthBtRefresh.constant = 120
        heightBtRefresh.constant = 60
        self.btFW.layer.cornerRadius = 5
        self.btFW.layer.borderWidth = 1
        self.btFW.layer.borderColor = UIColor.black.cgColor
    }
        
}

//TCP Deleage
extension Matrix4FWViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4FWViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_fw_version, number:UInt8(CmdHelper._4_cmd_fw_version))
    }
    
    func disConnect(err: String) {
        print("Matrix4FWViewController-disConnect")
        
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4FWViewController-onReadData")
        switch tag{
        
        case CmdHelper._4_cmd_fw_version:
            print("Matrix4FWViewController-_4_cmd_fw_version")
            self.btFW.setTitle("FW - " + self.hexStringtoAscii(hexString: data.hexEncodedString()), for: .init())
            break
            
        default:
            
            break
        }
        self.dismissLoadingView()
    }
}
