//
//  ListCollectionViewCell.swift
//  BZB_Project
//
//  Created by GoMax on 2021/6/2.
//

import Foundation
import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelIP: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 10
      
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
//        self.addGradientBackground(firstColor: UIColor(red: CGFloat(51/255.0), green: CGFloat(63/255.0), blue: CGFloat(82 / 255.0), alpha: 1), secondColor: UIColor(red: CGFloat(42/255.0), green: CGFloat(53/255.0), blue: CGFloat(69 / 255.0), alpha: 0.8))
    }
    
    func colorWithHexString(hexString: String) -> UIColor {
        var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()

        print(colorString)
        let alpha: CGFloat = 1.0
        let red: CGFloat = self.colorComponentFrom(colorString: colorString, start: 0, length: 2)
        let green: CGFloat = self.colorComponentFrom(colorString: colorString, start: 2, length: 2)
        let blue: CGFloat = self.colorComponentFrom(colorString: colorString, start: 4, length: 2)

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {

        let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
        let endIndex = colorString.index(startIndex, offsetBy: length)
        let subString = colorString[startIndex..<endIndex]
        let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt32 = 0

        guard Scanner(string: String(fullHexString)).scanHexInt32(&hexComponent) else {
            return 0
        }
        let hexFloat: CGFloat = CGFloat(hexComponent)
        let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
        print(floatValue)
        return floatValue
    }

}
