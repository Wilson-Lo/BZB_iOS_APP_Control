//
//
//  Created by Wilson on 2021/03/31.
//  Copyright © 2020 gomax. All rights reserved.
//

import UIKit
import Network
import CryptoKit
import CocoaAsyncSocket
import CryptoSwift
import RSSelectionMenu
import Toast_Swift
import PopupDialog

class MainViewController: BaseViewController{
    
    @IBOutlet weak var btHDMIOverIP: UIButton!
    @IBOutlet weak var btMatrix4: UIButton!
  //  @IBOutlet weak var btMatrix8: UIButton!
    @IBOutlet weak var btSetting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController-viewDidLoad")
        initialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("MainViewController-viewDidAppear")
        TcpSocketClient.sharedInstance.stopConnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("MainViewController-viewDidDisappear")
            
            
    }
    
    
    
}


extension MainViewController{
    
    //initial UI
    func initialUI(){
        self.btHDMIOverIP.layer.cornerRadius = 5
        self.btHDMIOverIP.layer.borderWidth = 1
        self.btHDMIOverIP.layer.borderColor = UIColor.black.cgColor
        
        self.btMatrix4.layer.cornerRadius = 5
        self.btMatrix4.layer.borderWidth = 1
        self.btMatrix4.layer.borderColor = UIColor.black.cgColor
        
//        self.btMatrix8.layer.cornerRadius = 5
//        self.btMatrix8.layer.borderWidth = 1
//        self.btMatrix8.layer.borderColor = UIColor.black.cgColor
        
        self.btSetting.layer.cornerRadius = 5
        self.btSetting.layer.borderWidth = 1
        self.btSetting.layer.borderColor = UIColor.black.cgColor
    }
    
    
}



