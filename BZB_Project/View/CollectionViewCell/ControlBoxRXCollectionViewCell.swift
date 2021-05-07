//
//  ControlBoxRXCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/13.
//

import Foundation
import UIKit

class ControlBoxRXCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var groupIDText: UITextField!

    @IBOutlet weak var ipText: UITextField!
    @IBOutlet weak var txNameText: UITextField!
    //    @IBOutlet weak var ipText: UITextField!
//    @IBOutlet weak var groupIDText: UITextField!
    @IBOutlet weak var deviceName: UILabel!
    // @IBOutlet weak var deviceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 10
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}


