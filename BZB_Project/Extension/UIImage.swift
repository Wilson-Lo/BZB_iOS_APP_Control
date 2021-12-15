//
//  UIImage.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/8.
//

import UIKit

extension UIImage {
    func trim(trimRect :CGRect) -> UIImage {
        if CGRect(origin: CGPoint.zero, size: self.size).contains(trimRect) {
            if let imageRef = self.cgImage?.cropping(to: trimRect) {
                return UIImage(cgImage: imageRef)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(trimRect.size, true, self.scale)
        self.draw(in: CGRect(x: -trimRect.minX, y: -trimRect.minY, width: self.size.width, height: self.size.height))
        let trimmedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = trimmedImage else { return self }
        
        return image
    }
    
    convenience init(view: UIView) {

       UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
       view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       self.init(cgImage: (image?.cgImage)!)

     }
    
    func imageResized(to size: CGSize) -> UIImage {
           return UIGraphicsImageRenderer(size: size).image { _ in
               draw(in: CGRect(origin: .zero, size: size))
           }
       }
}


