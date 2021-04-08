//
//  BaseViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/1.
//

import UIKit

class BaseViewController: UIViewController{
    
    var alert: UIAlertController!
    static var isPhone: Bool!
    static var textSizeForPhone = 16
    static var textSizeForPad = 32

    override func viewDidLoad() {
        self.alert = UIAlertController(title: nil, message: "Please wait ...", preferredStyle: .alert)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            print("it is iphone")
            BaseViewController.isPhone = true
            break
            
        case .pad:
            print("it is ipad")
            BaseViewController.isPhone = false
            break
            
        @unknown default:
            BaseViewController.isPhone = false
            break
        // Uh, oh! What could it be?
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
            
    }

}


extension BaseViewController  {
    
    public func hexStringToStringArray(_ data: String) -> [String]?{
        let length = data.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [String]()
        bytes.reserveCapacity(length/2)
        var index = data.startIndex
        for _ in 0..<length/2 {
            let nextIndex = data.index(index, offsetBy: 2)
            var b = data[index..<nextIndex]
            bytes.append(String(b))
            index = nextIndex
        }
        return bytes
    }
    
    enum UIUserInterfaceIdiom : Int {
        case unspecified
        
        case phone // iPhone and iPod touch style UI
        case pad   // iPad style UI (also includes macOS Catalyst)
    }
    
    //show waiting dialog
    public func showLoadingView() {
        DispatchQueue.main.async() {
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            self.alert.view.addSubview(loadingIndicator)
            self.present(self.alert, animated: true, completion: nil)
        }
    }
    
    //close waiting dailog
    public func dismissLoadingView() {
        DispatchQueue.main.async() {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
    //show alert
    public func showAlert(message: String) {
        if(!message.isEmpty){
            
            if(BaseViewController.isPhone){
                let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                })
                present(alert, animated: true)
            }else{
                
                let attributedStringTitle = NSAttributedString(string: "Warning", attributes: [
                                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28), //your font here,
                                                                NSAttributedString.Key.foregroundColor : UIColor.black])
                
                let attributedStringMSG = NSAttributedString(string: "\n" + message, attributes: [
                                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22), //your font here,
                                                                NSAttributedString.Key.foregroundColor : UIColor.black])
                
                let alert = UIAlertController(title: "Warning", message: message,  preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                })
                alert.setValue(attributedStringTitle, forKey: "attributedTitle")
                alert.setValue(attributedStringMSG, forKey: "attributedMessage")
                var height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.13)
                var width:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.width * 0.8)
                alert.view.addConstraint(height);
                alert.view.addConstraint(width);
                present(alert, animated: true, completion: nil)
                
            }
            
        }
    }
}
