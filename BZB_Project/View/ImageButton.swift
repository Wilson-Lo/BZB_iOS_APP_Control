//
//  ass.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/1.
//

import UIKit

class ImageButton: UIButton {
   
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.contentMode = .scaleAspectFit
    }
}
