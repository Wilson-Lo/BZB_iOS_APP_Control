//
//  BaseViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/1.
//

import UIKit

class BaseViewController : UIViewController{
    
    var alert: UIAlertController!
    static var isPhone: Bool!
    static var textSizeForPhone = 16
    static var textSizeForPad = 32
    final let SERVER_PORT = "8080" //Server listening port ( Control Box )
    static var loadingIndicator :UIActivityIndicatorView!
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
        
        if(!BaseViewController.isPhone){
            BaseViewController.loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: -32, y: -12, width: 120, height: 80))
            let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let messageString = NSAttributedString(string: "Please wait ...", attributes: messageAttributes)
            self.alert.setValue(messageString, forKey: "attributedMessage")
        }else{
            BaseViewController.loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
            BaseViewController.loadingIndicator.hidesWhenStopped = true
            BaseViewController.loadingIndicator.style = UIActivityIndicatorView.Style.gray
            BaseViewController.loadingIndicator.startAnimating();
            self.alert.view.addSubview(BaseViewController.loadingIndicator)
            self.present(self.alert, animated: true, completion: nil)
        }
    }
    
    //close waiting dailog
    public func dismissLoadingView() {
        DispatchQueue.main.async() {
            if(BaseViewController.loadingIndicator.isAnimating){
                BaseViewController.loadingIndicator.stopAnimating()
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    public func isLoadingShowing() -> Bool{
        return BaseViewController.loadingIndicator.isAnimating
    }
    
    //show toast
    public func showToast(context: String){
        
        if(BaseViewController.isPhone){
            self.view.showToast(text: context, font_size: CGFloat(BaseViewController.textSizeForPhone), isMenu: true)
        }else{
            self.view.showToast(text: context, font_size: CGFloat(BaseViewController.textSizeForPad), isMenu: true)
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
                                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24), //your font here,
                                                                NSAttributedString.Key.foregroundColor : UIColor.black])
                
                let attributedStringMSG = NSAttributedString(string: "\n" + message, attributes: [
                                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20), //your font here,
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
    
    /**
     *  Get Device Type Number By Name
     */
    func getDeviceTypeNumberByName(deviceName: String) -> Int{
        
        var type = 0
        
        switch(deviceName){
        
        case "Control-Box":
            type = DBHelper.DEVICE_CONTROL_BOX
            break
            
        case "Matrix 4x4 HDR  ":
            type = DBHelper.DEVICE_MATRIX_4_X_4_HDR
            break
            
        default:
            type = DBHelper.DEVICE_CUSTOMER
            break
        }
        return type
    }
    
    /**
        Add BZB logo in the navigation bar
     */
    func addNavBarLogoImage(isTabViewController : Bool) {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bzb_logo_white"))
        let titleView: UIView
        if(BaseViewController.isPhone){
           imageView.frame = CGRect(x: 0, y: -20, width: 170, height:80)
           imageView.contentMode = .scaleAspectFit
           titleView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 80))
        }else{
            imageView.frame = CGRect(x: 0, y: -40, width: 230, height:120)
            imageView.contentMode = .scaleAspectFit
            titleView = UIView(frame: CGRect(x: 0, y: 0, width: 230, height: 120))
        }

        titleView.addSubview(imageView)
        titleView.backgroundColor = .clear
        if(isTabViewController){
            self.tabBarController?.navigationItem.titleView = titleView
            self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor(cgColor: #colorLiteral(red: 0.08523575506, green: 0.1426764978, blue: 0.2388794571, alpha: 1).cgColor )
        }else{
            self.navigationItem.titleView = titleView
            self.navigationController?.navigationBar.barTintColor = UIColor(cgColor: #colorLiteral(red: 0.08523575506, green: 0.1426764978, blue: 0.2388794571, alpha: 1).cgColor )
        }
    }
    
    func setupBackButton(isTabViewController : Bool){
        let backBt = UIButton(type: .custom)
        //set image for button
        backBt.setImage(UIImage(named: "back.png"), for: .normal)
        //add function for button
        backBt.addTarget(self, action: #selector(BackButtonTapped), for: .touchUpInside)
        
        let yourBackImage = UIImage(named: "back")
        if(BaseViewController.isPhone){
            backBt.widthAnchor.constraint(equalToConstant: 30).isActive = true
            backBt.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }else{
            backBt.widthAnchor.constraint(equalToConstant: 40).isActive = true
            backBt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        let barButton = UIBarButtonItem(customView: backBt)
        if(isTabViewController){
            self.tabBarController?.navigationItem.leftBarButtonItem = barButton
        }else{
            self.navigationItem.leftBarButtonItem = barButton
        }
    }
    
    
    @objc func BackButtonTapped(isTabViewController : Bool){
        print("BackButton Tapped")
        self.navigationController?.popToRootViewController(animated: true)
        if(isTabViewController){
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
