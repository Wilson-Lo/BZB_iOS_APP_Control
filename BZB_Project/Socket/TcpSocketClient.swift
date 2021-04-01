//
//  TcpSocketClient.swift
//
//  Created by Wilson Lo on 2021/03/31.
//  Copyright © 2021 GoMax-Electronics. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol TcpSocketClientDeleage: class {
    func onConnect()
    func disConnect(err: String)
    func onReadData(data: Data,tag:Int)
}

class TcpSocketClient: NSObject {
    fileprivate var clientSocket: GCDAsyncSocket!
    
    //重連時間間隔
    fileprivate var timeInterval = 1;
    
    //設定Timeout  -1為持續等待
    fileprivate let socketTimeout = 10.0
    
    static let sharedInstance=TcpSocketClient();
    weak var delegate: TcpSocketClientDeleage?
    private override init() {
        super.init();
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
}

extension TcpSocketClient {
    // 開啟連接
    func startConnect(){
        startReConnectTimer();
    }
    
    // 斷開連接
    func stopConnect(){
        if(clientSocket.isConnected){
            clientSocket.disconnect()
        }
    }
    
    
    // 啟動連接
    func startReConnectTimer(){
        
        if(self.clientSocket.isDisconnected){
            GCDTimer.shared.scheduledDispatchTimer(WithTimerName: "reconnect", timeInterval: Double(timeInterval), queue: .main, repeats: false) {
                print("連接中...")
                
                do {
                    let ip = UserDefaults.standard.string(forKey: "IP_ADDRESS")
                    try self.clientSocket.connect(toHost: ip ?? "127.0.0.1", onPort: 6970, withTimeout: 5)
                } catch {
                    print(error)
                }
            }
            
        } else {
            self.delegate?.onConnect()
        }
        
    }
    
    func stopReConnectTimer(){
        GCDTimer.shared.cancleTimer(WithTimerName: "reconnect")
    }
    
}

extension TcpSocketClient {
    // 發送消息
//    func sendMessage(cid:CommendID){
//        var cmd = ""
//        switch cid {
////        case .requireBlueriverAPI:
////            cmd = "require blueriver_api 2.19.0\n"
////        case .modeHuman:
////            cmd = "mode human\n"
////        case .getAllIdentity:
////            cmd = "get all identity\n"
////        case .requireMultiview:
////            cmd = "require multiview 1.1.0\n"
////        case .listLayout:
////            cmd = "list layout\n"
//        default:
//            cmd = ""
//        }
//        if clientSocket.isConnected {
//            print(cmd)
//            clientSocket.write(cmd.data(using: .utf8), withTimeout: socketTimeout, tag: cid.rawValue)
//            clientSocket.readData(to: GCDAsyncSocket.lfData(), withTimeout: socketTimeout, tag: cid.rawValue)
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                self.delegate?.disConnect(err: "Timeout")
//            }
//        }
//
//    }
    
//    func sendMsg(cmd:String){
//        if clientSocket.isConnected {
//            print(cmd)
//            clientSocket.write(cmd.data(using: .utf8), withTimeout: socketTimeout, tag: 111)
//            clientSocket.readData(to: GCDAsyncSocket.lfData(), withTimeout: socketTimeout, tag: 111)
//        }
//    }
//
//    func sendMessageWithParams(cid:CommendID , params:[String:String]){
//        var cmd = ""
//        switch cid {
////        case .startHDMI:
////            let deviceID = params[Constants.PARAMS_DEVICE_ID]!
//////            cmd = "start \(deviceID):HDMI:0\n"
//        default:
//            cmd = ""
//        }
//        if clientSocket.isConnected {
//            print(cmd)
//            clientSocket.write(cmd.data(using: .utf8), withTimeout: socketTimeout, tag: cid.rawValue)
//            clientSocket.readData(to: GCDAsyncSocket.lfData(), withTimeout: socketTimeout, tag: cid.rawValue)
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                self.delegate?.disConnect(err: "Timeout")
//            }
//        }
//    }
}

extension TcpSocketClient: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return elapsed
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return elapsed
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let strNowTime = timeFormatter.string(from: date) as String
        print(strNowTime)
        if let e = err{
            self.delegate?.disConnect(err: e.localizedDescription)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        let address = "Server IP：" + "\(host)"
        print(address)
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let strNowTime = timeFormatter.string(from: date) as String
        print(strNowTime)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.sendMessage(cid: .requireBlueriverAPI)
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.sendMessage(cid: .requireMultiview)
//        }

//        sock.readData(withTimeout: -1, tag: 0)
    }
    
    
    
    // 接收到消息
//    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//        if (tag == CommendID.requireBlueriverAPI.rawValue){
//            self.delegate?.onConnect()
//        }
//        
////        if (tag == CommendID.getDeviceSetting.rawValue){
////            print(data.count)
////        }
//        
//        self.delegate?.onReadData(data: data, tag: tag)
////        sock.readData(withTimeout: -1, tag: 0);
//    }
}
