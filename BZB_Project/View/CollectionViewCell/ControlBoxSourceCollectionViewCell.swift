//
//  ControlBoxSourceCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/14.
//

import Foundation
import UIKit

class ControlBoxSourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var mac: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
    }
}
