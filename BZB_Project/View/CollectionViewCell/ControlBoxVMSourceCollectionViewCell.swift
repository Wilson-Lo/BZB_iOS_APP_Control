//
//  ControlBoxVMSourceCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/27.
//

import Foundation
import UIKit

class ControlBoxVMSourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sourceName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderWidth = 0.4
        self.contentView.layer.borderColor = UIColor.white.cgColor
    }
}
