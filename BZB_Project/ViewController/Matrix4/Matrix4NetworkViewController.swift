//
//  Matrix4NetworkViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/8.
//

import UIKit

class Matrix4NetworkViewController: BaseSocketViewController{
    
    @IBOutlet weak var ip1: UITextField!
    @IBOutlet weak var ip2: UITextField!
    @IBOutlet weak var ip3: UITextField!
    @IBOutlet weak var ip4: UITextField!
    
    @IBOutlet weak var mask1: UITextField!
    @IBOutlet weak var mask2: UITextField!
    @IBOutlet weak var mask3: UITextField!
    @IBOutlet weak var mask4: UITextField!
    
    @IBOutlet weak var gateway1: UITextField!
    @IBOutlet weak var gateway2: UITextField!
    @IBOutlet weak var gateway3: UITextField!
    @IBOutlet weak var gateway4: UITextField!
    
    
    override func viewDidLoad() {
        print("Matrix4NetworkViewController-viewDidLoad")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4NetworkViewController-viewWillAppear")
        super.viewWillAppear(true)
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4NetworkViewController-viewDidDisappear")
    }

}

//TCP Deleage
extension Matrix4NetworkViewController : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4NetworkViewController-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_8_x_8_get_network, number: UInt8(CmdHelper._3_cmd_get_network_status))
    }
    
    func disConnect(err: String) {
        print("Matrix4NetworkViewController-disConnect")
        self.dismissLoadingView()
        self.view.makeToast(err)
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4NetworkViewController-onReadData")
        switch tag{
        
        case CmdHelper._3_cmd_get_network_status:
            print("Matrix4NetworkViewController-_3_cmd_get_network_status")
            var inputdata = self.stringToBytes(data.hexEncodedString())
            //check data checksum
            if(inputdata?.count == 23){
                DispatchQueue.main.async() {
                    self.ip1.text = String(Int(String(format: "%02X", inputdata![2]), radix: 16)!)
                    self.ip2.text = String(Int(String(format: "%02X", inputdata![3]), radix: 16)!)
                    self.ip3.text = String(Int(String(format: "%02X", inputdata![4]), radix: 16)!)
                    self.ip4.text = String(Int(String(format: "%02X", inputdata![5]), radix: 16)!)
                    
                    self.mask1.text = String(Int(String(format: "%02X", inputdata![6]), radix: 16)!)
                    self.mask2.text = String(Int(String(format: "%02X", inputdata![7]), radix: 16)!)
                    self.mask3.text = String(Int(String(format: "%02X", inputdata![8]), radix: 16)!)
                    self.mask4.text = String(Int(String(format: "%02X", inputdata![9]), radix: 16)!)
                    
                    self.gateway1.text = String(Int(String(format: "%02X", inputdata![10]), radix: 16)!)
                    self.gateway2.text = String(Int(String(format: "%02X", inputdata![11]), radix: 16)!)
                    self.gateway3.text = String(Int(String(format: "%02X", inputdata![12]), radix: 16)!)
                    self.gateway4.text = String(Int(String(format: "%02X", inputdata![13]), radix: 16)!)
                }
            }else{
                self.view.makeToast("Get data occur error !")
            }
            break
            
        default:
            
            break
        }
    }
}
