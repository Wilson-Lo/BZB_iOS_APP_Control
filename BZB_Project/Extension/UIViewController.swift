//
//  UIViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/8.
//

import UIKit

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension UIViewController {
    
    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}
