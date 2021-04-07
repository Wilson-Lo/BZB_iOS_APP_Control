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
    
    static var currentCmdNumber = 0
    
    fileprivate var clientSocket: GCDAsyncSocket!
    fileprivate var queueTCP: DispatchQueue!
    //reconnect time interval
    fileprivate var timeInterval = 1
    
    //設定Timeout  -1為持續等待
    fileprivate let socketTimeout = 10.0
    
    static let sharedInstance=TcpSocketClient();
    weak var delegate: TcpSocketClientDeleage?
    private override init() {
        super.init();
        self.queueTCP = DispatchQueue(label: "com.bzb.tcp", qos: DispatchQoS.userInitiated)
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
}

extension TcpSocketClient {
    
    //start to connect to device (tcp)
    func startConnect(){
        if(self.clientSocket.isDisconnected){
            GCDTimer.shared.scheduledDispatchTimer(WithTimerName: "reconnect", timeInterval: Double(timeInterval), queue: .main, repeats: false) {
                print("connect...")
                
                do {
                    if(UserDefaults.standard.string(forKey: CmdHelper.key_server_ip) != nil){
                        let ip = UserDefaults.standard.string(forKey: CmdHelper.key_server_ip)
                        print("device ip = " + ip!)
                        try self.clientSocket.connect(toHost: ip ?? "127.0.0.1", onPort: 9760, withTimeout: 5)
                    }else{
                        self.delegate?.disConnect(err: "ip empty")
                    }
                } catch {
                    print(error)
                }
            }
            
        } else {
            self.delegate?.onConnect()
        }
    }
    
    //disconnect tcp
    func stopConnect(){
        if(clientSocket.isConnected){
            clientSocket.disconnect()
        }
    }
    
    func stopReConnectTimer(){
        GCDTimer.shared.cancleTimer(WithTimerName: "reconnect")
    }
    
}

extension TcpSocketClient {

    //send cmd
    func sendCmd(cmd:String, number:UInt8){
        if clientSocket.isConnected {
            let data = Data(hexString: cmd)
            TcpSocketClient.currentCmdNumber = Int(number)
            clientSocket.write(data, withTimeout: socketTimeout, tag: 111)
            clientSocket.readData(withTimeout: -1, tag: 0)
        //    clientSocket.readData(to: GCDAsyncSocket.lfData(), withTimeout: socketTimeout, tag: 111)
        }
    }
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
        print(err)
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
        print("Socket-Connect")
        self.delegate?.onConnect()
    }
    
    // receive message
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("Socket-Read")
        self.delegate?.onReadData(data: data, tag: TcpSocketClient.currentCmdNumber)
    }
}
