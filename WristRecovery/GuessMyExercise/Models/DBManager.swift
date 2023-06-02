//
//  DBManager.swift
//  WristRecovery
//
//  Created by Leonardopersici on 02/06/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import SQLite3

class DBManager {
    var db : OpaquePointer?
    var path : String = "myDb.sqlite"
    init(){
        self.db = createDB()
        self.createTableMedici()
        self.createTablePazienti()
        self.createTableEsercizi()
    }
    
    func createDB() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
        var db : OpaquePointer? = nil
        if sqlite3_open(filePath.path, &db) != SQLITE_OK{
                    print("can't open database")
                    return nil
        } else
        {
            print("Successfully created connection to database at \(path)")
            return db
        }
    }
    
    func createTableMedici() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Medici(Id INTEGER PRIMARY KEY,username TEXT, password TEXT, pazienti TEXT);";
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("table Medici created.")
            } else {
                print("table Medici could not be created.")
            }
        } else {
            print("CREATE TABLE Medici statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func createTablePazienti() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Pazienti(Id INTEGER PRIMARY KEY,username TEXT, password TEXT, medico INTEGER);";
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("table Pazienti created.")
            } else {
                print("table Pazienti could not be created.")
            }
        } else {
            print("CREATE TABLE Pazienti statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func createTableEsercizi() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Esercizi(Id INTEGER PRIMARY KEY,assegnatoDa INTEGER, assegnatoA INTEGER, completato INTEGER);";
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("table Esercizi created.")
            } else {
                print("table Esercizi could not be created.")
            }
        } else {
            print("CREATE TABLE Esercizi statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertMedico(id:Int, username:String, password:String, pazienti:[Int]) {
       let insertStatementString = "INSERT INTO Medici (Id, username, password, pazienti) VALUES (?, ?, ?, ?);"
       var insertStatement: OpaquePointer? = nil
       if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
           sqlite3_bind_int(insertStatement, 1, Int32(id))
           sqlite3_bind_text(insertStatement, 2, (username as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 3, (password as NSString).utf8String, -1, nil)
           
           let data = try! JSONEncoder().encode(pazienti)
           let pazientiString = String(data: data, encoding: .utf8)
           sqlite3_bind_text(insertStatement, 4, (pazientiString as! NSString).utf8String, -1, nil)
             
           if sqlite3_step(insertStatement) == SQLITE_DONE {
               print("Successfully inserted Medico row.")
           } else {
               print("Could not insert Medico row.")
           }
       } else {
           print("INSERT Medico statement could not be prepared.")
       }
       sqlite3_finalize(insertStatement)
    }
    
    func insertPaziente(id:Int, username:String, password:String, medico:Int) {
       let insertStatementString = "INSERT INTO Pazienti (Id, username, password, medico) VALUES (?, ?, ?, ?);"
       var insertStatement: OpaquePointer? = nil
       if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
           sqlite3_bind_int(insertStatement, 1, Int32(id))
           sqlite3_bind_text(insertStatement, 2, (username as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 3, (password as NSString).utf8String, -1, nil)
           sqlite3_bind_int(insertStatement, 4, Int32(medico))
             
           if sqlite3_step(insertStatement) == SQLITE_DONE {
               print("Successfully inserted Paziente row.")
           } else {
               print("Could not insert Paziente row.")
           }
       } else {
           print("INSERT Paziente statement could not be prepared.")
       }
       sqlite3_finalize(insertStatement)
    }
    
    func insertEsercizio(id:Int, assegnatoDa:String, assegnatoA:String, completato:Int) {
       let insertStatementString = "INSERT INTO Esercizi (Id, assegnatoDa, assegnatoA, completato) VALUES (?, ?, ?, ?);"
       var insertStatement: OpaquePointer? = nil
       if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
           sqlite3_bind_int(insertStatement, 1, Int32(id))
           sqlite3_bind_int(insertStatement, 2, Int32(assegnatoDa)!)
           sqlite3_bind_int(insertStatement, 3, Int32(assegnatoA)!)
           sqlite3_bind_int(insertStatement, 4, Int32(completato))
             
           if sqlite3_step(insertStatement) == SQLITE_DONE {
               print("Successfully inserted Esercizio row.")
           } else {
               print("Could not insert Esercizio row.")
           }
       } else {
           print("INSERT Esercizio statement could not be prepared.")
       }
       sqlite3_finalize(insertStatement)
    }
    
    func read() -> [Medico] {
            var mainList = [Medico]()
            
            let query = "SELECT * FROM Medici;"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let username = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                    let password = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                    let pazienti = String(describing: String(cString: sqlite3_column_text(statement, 3)))

                    let model = Medico()
                    model.id = id
                    model.username = username
                    model.password = password
                    
                    let data = try! JSONDecoder().decode([Int].self, from: pazienti.data(using: .utf8)!)
                    
                    model.pazienti = data
                    
                    mainList.append(model)
                    print("Query Result:")
                    print("\(id) | \(username) | \(password) | \(pazienti)")
                }
            }
        return mainList
        }
}
