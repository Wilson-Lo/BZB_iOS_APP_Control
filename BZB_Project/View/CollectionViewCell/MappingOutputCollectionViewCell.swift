//
//  MappingCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/7.
//


import Foundation
import UIKit

class MappingOutputCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var labelOutputName: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelIndex: UILabel!
    
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
