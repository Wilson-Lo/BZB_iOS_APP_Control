//
//  ControlBoxVWCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/10/6.
//

import Foundation
import UIKit

class ControlBoxVWCollectionViewCell: UICollectionViewCell {
    
    var gradientLayer: CAGradientLayer!

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
    }
}
