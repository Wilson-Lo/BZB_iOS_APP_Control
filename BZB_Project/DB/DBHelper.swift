//
//  DBHelper.swift
//  BZB_Project
//
//  Created by Wilson on 2021/06/03.
//  Copyright © 2021 gomax. All rights reserved.
//


import Foundation
import sqlite3

class DBHelper{
    
    var db : OpaquePointer?
    var path : String = "BZBDevicesDataBase.sqlite"
    var tableName = "BZBDevices"
    
    init() {
        self.db = createDB()
        self.createTable()
    }
    
    func createDB() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("There is error in creating DB")
            return nil
        }else {
            print("Database has been created with path \(path)")
            return db
        }
    }
    
    func createTable()  {
        let query = "CREATE TABLE IF NOT EXISTS " + self.tableName + "(id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER, ip TEXT, name TEXT);"
        var statement : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Table creation success")
            }else {
                print("Table creation fail")
            }
        } else {
            print("Prepration fail")
        }
        sqlite3_finalize(statement)
    }
    
    func insert(type : Int, ip : String, name : String) -> Bool {
        let query = "INSERT INTO " + self.tableName + " (id, type, ip, name) VALUES (?, ?, ?, ?);"
        
        var statement : OpaquePointer? = nil
       
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            //  sqlite3_bind_int(statement, 1, 1)
            sqlite3_bind_int(statement, 2, Int32(type))
            sqlite3_bind_text(statement, 3, (ip as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (name as NSString).utf8String, -1, nil)
            let feedback = sqlite3_step(statement)
            print("feedback = \(feedback)")
            if feedback == SQLITE_DONE {
                print("Data inserted success")
                sqlite3_finalize(statement)
                return true
            }else {
                print("Data is not inserted in table")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Query is not as per requirement")
            sqlite3_finalize(statement)
            return false
        }
        
    }
    
    func read() -> [DeviceDataObject]{
        
        var deviceList = [DeviceDataObject]()
        let query = "SELECT * FROM " + self.tableName + ";"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                
                let device = DeviceDataObject()
                device.id = Int(sqlite3_column_int(statement, 0))
                device.type = Int(sqlite3_column_int(statement, 1))
                device.ip = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                device.name = String(describing: String(cString: sqlite3_column_text(statement, 3)))
                deviceList.append(device)
                print("id = \(device.id) name = \(device.name)")
            }
        }
        sqlite3_finalize(statement)
        return deviceList
    }
    
    /**Check this IP is exist or not
     */
    func queryByIP(ip : String) -> Bool{
      
        let query = "SELECT * FROM " + self.tableName + ";"
        var statement : OpaquePointer? = nil
        var feedback = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                if(ip == String(describing: String(cString: sqlite3_column_text(statement, 2)))){
                    feedback = true
                    break
                }
            }
        }
        sqlite3_finalize(statement)
        return feedback
    }
    
    /** Get DB Size
     */
    func getDBSize() -> Int{
        let query = "SELECT * FROM " + self.tableName + ";"
        var statement : OpaquePointer? = nil
        var size = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                  size+=1
            }
        }
        sqlite3_finalize(statement)
        return size
    }
    
    func delete(id : Int) -> Bool{
        let query = "DELETE FROM " + self.tableName + " where id = \(id)"
        var statement : OpaquePointer? = nil
    
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            let feedback = sqlite3_step(statement)
            print("feedback = \(feedback)")
            if feedback == SQLITE_DONE {
                print("Data delete success")
                sqlite3_finalize(statement)
                return true
            }else {
                print("Data is not deleted in table")
                sqlite3_finalize(statement)
                return false
            }
        }else{
            sqlite3_finalize(statement)
            return false
        }
    }
    

}
