//
//  NSLayoutConstraint.swift
//  BZB_Project
//
//  Created by GoMax on 2021/6/21.
//

import Foundation
import UIKit
extension NSLayoutConstraint{
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
           return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
       }
}
