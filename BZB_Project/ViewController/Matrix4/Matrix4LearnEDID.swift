//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2021 GoMax. All rights reserved.
//

import UIKit

class Matrix4LearnEDID: BaseSocketViewController{
    
    @IBOutlet weak var segmentedType: UISegmentedControl!
    @IBOutlet weak var btEDID: UIButton!
    @IBOutlet weak var btDevice: UIButton!
    @IBOutlet weak var btApply: UIButton!
    
    override func viewDidLoad() {
        print("Matrix4LearnEDID-viewDidLoad")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Matrix4LearnEDID-viewWillAppear")
        super.viewWillAppear(true)
        initialUI()
        TcpSocketClient.sharedInstance.delegate = self
        TcpSocketClient.sharedInstance.startConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Matrix4LearnEDID-viewDidDisappear")
        TcpSocketClient.sharedInstance.stopConnect()
    }
}

extension Matrix4LearnEDID{
    
    func initialUI(){
        if(Matrix4MappingViewController.isPhone){
            print("is phone")
            let widthBtApply = btApply.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtApply = btApply.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtApply, heightBtApply])
            widthBtApply.constant = 80
            heightBtApply.constant = 40
            self.btApply.layer.cornerRadius = 5
            self.btApply.layer.borderWidth = 1
            self.btApply.layer.borderColor = UIColor.black.cgColor
            
        }else{
            print("is pad")
            let widthBtApply = btApply.widthAnchor.constraint(equalToConstant: 30.0)
            let heightBtApply = btApply.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([widthBtApply, heightBtApply])
            widthBtApply.constant = 140
            heightBtApply.constant = 80
            self.btApply.layer.cornerRadius = 5
            self.btApply.layer.borderWidth = 1
            self.btApply.layer.borderColor = UIColor.black.cgColor
            self.segmentedType.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 32) ], for: .normal)
        }
    }
}


extension Matrix4LearnEDID : TcpSocketClientDeleage{
    
    func onConnect() {
        print("Matrix4LearnEDID-onConnect")
        TcpSocketClient.sharedInstance.sendCmd(cmd: CmdHelper.cmd_4_x_4_get_io_name, number: UInt8(CmdHelper._5_cmd_get_io_name))
    }
    
    func disConnect(err: String) {
        print("Matrix4LearnEDID-disConnect ")
        
        self.dismissLoadingView()
    }
    
    func onReadData(data: Data, tag: Int) {
        print("Matrix4LearnEDID-onReadData - \(tag)")
        
        switch tag{
        
        
        default:
            
            break
        }
        self.dismissLoadingView()
    }
    
}
