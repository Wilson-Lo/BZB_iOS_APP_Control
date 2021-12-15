//
//  ControlBoxMappingDisplayCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/13.
//

import Foundation
import UIKit

class ControlBoxMappingRXCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var mac: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
    }
}
