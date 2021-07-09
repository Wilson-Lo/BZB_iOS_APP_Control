//
//  BaseSocketViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/3/31.
//


import UIKit

class BaseSocketViewController: BaseViewController{
    
    static var inputName: Array<String> = []
    static var outputName: Array<String> = []
     var mappingName: Array<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.168627451, green: 0.2078431373, blue: 0.2941176471, alpha: 1)
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.168627451, green: 0.2078431373, blue: 0.2941176471, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
            
    }

}

/**
 * Tool Functions
 */
extension BaseSocketViewController{
    
    public func stringToBytes(_ data: String) -> [UInt8]?{
        let length = data.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = data.startIndex
        for _ in 0..<length/2 {
            let nextIndex = data.index(index, offsetBy: 2)
            if let b = UInt8(data[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    /**
     * Calculate command check sum
     */
    public func calCheckSum(data: String) -> String{
        var sum = 0;
        var hexData = self.hexStringToStringArray(data)
        if(hexData != nil){
            for i in 0...(hexData!.count-1){
                sum = sum + Int(hexData![i], radix: 16)!
            }
            return String(String(sum, radix: 16).suffix(2))
        }else{
            return "00"
        }
        
    }
    
    public func hexStringtoAscii(hexString : String) -> String {
        
        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = hexString as NSString
        let matches = regex.matches(in: hexString, options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
    }
}

/**
 * JSON Parser
 */
extension BaseSocketViewController{
    
    /**
     * Parser I/O Name ( 4 * 4 )
     */
    public func parser4IOName(data: Data){
        print("BaseViewController-parserIOName")
        BaseSocketViewController.inputName.removeAll()
        BaseSocketViewController.outputName.removeAll()
        
        var feedbackData = self.hexStringToStringArray(data.hexEncodedString())
        print("data = " + data.hexEncodedString())
        var tempArray: Array<String> = []
        var nextEndIndex = 2 + Int(feedbackData![2], radix: 16)!
        var tempName = ""
        for i in 3...(feedbackData!.count-1){
            if(i == nextEndIndex){
                tempArray.append(self.hexStringtoAscii(hexString: tempName))
                tempName = ""
                nextEndIndex = nextEndIndex + Int(feedbackData![i], radix: 16)!
            }else{
                tempName = tempName + feedbackData![i]
                if(i == (feedbackData!.count-1)){
                    tempArray.append(self.hexStringtoAscii(hexString: tempName))
                }
            }
        }
        
        if(tempArray.count == 8){
            print("temp size == 8")
            for i in 0...7{
                if(i<4){
                    BaseSocketViewController.outputName.append(tempArray[i])
                }else{
                    BaseSocketViewController.inputName.append(tempArray[i])
                }
            }
        }else{
            print("temp size != 8 , size = \(tempArray.count)")
        }
    
        tempArray.removeAll()
    }
    
    public func parserMappingName(data: Data){
        self.mappingName.removeAll()
        var feedbackData = self.hexStringToStringArray(data.hexEncodedString())
        var nextEndIndex = 2 + Int(feedbackData![2], radix: 16)!
        var tempName = ""
        
        for i in 3...(feedbackData!.count-1){
            if(i == nextEndIndex){
                self.mappingName.append(self.hexStringtoAscii(hexString: tempName))
                tempName = ""
                nextEndIndex = nextEndIndex + Int(feedbackData![i], radix: 16)!
            }else{
                tempName = tempName + feedbackData![i]
                if(i == (feedbackData!.count-1)){
                    self.mappingName.append(self.hexStringtoAscii(hexString: tempName))
                }
            }
        }
    }
}
