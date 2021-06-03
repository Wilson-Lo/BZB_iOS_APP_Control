//
//  DBHelper.swift
//  BZB_Project
//
//  Created by Wilson on 2021/06/03.
//  Copyright © 2021 gomax. All rights reserved.
//


import Foundation
import SQLite3

class DBHelper{
    
    var db : OpaquePointer?
    var path : String = "BZBDevicesDataBase.sqlite"
    var tableName = "BZBDevices"
    
    init() {
        self.db = createDB()
        self.createTable()
    }
    
    func createDB() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathExtension(path)
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
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
    }
    
    func insert(type : Int, ip : String, name : String) -> Bool {
        let query = "INSERT INTO " + self.tableName + " (id, type, ip, name) VALUES (?, ?, ?, ?);"
        
        var statement : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            //  sqlite3_bind_int(statement, 1, 1)
            sqlite3_bind_int(statement, 2, Int32(type))
            sqlite3_bind_text(statement, 3, (ip as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data inserted success")
                return true
            }else {
                print("Data is not inserted in table")
                return false
            }
        } else {
            print("Query is not as per requirement")
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
            }
        }
        
        return deviceList
    }
    
    func delete(id : Int) -> Bool{
        let query = "DELETE FROM " + self.tableName + " where id = \(id)"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data delete success")
                return true
            }else {
                print("Data is not deleted in table")
                return false
            }
        }else{
            return false
        }
    }
}
