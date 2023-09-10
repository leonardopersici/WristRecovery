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
    var checkM = true
    var checkP = true
    init(){
        self.db = createDB()
        self.createTableMedici()
        self.createTablePazienti()
        self.createTableEsercizi()
        print(readMedici())
        print(readPazienti())
        print(readEsercizi())
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
        let createTableString = "CREATE TABLE IF NOT EXISTS Medici(Id INTEGER PRIMARY KEY AUTOINCREMENT,username TEXT, password TEXT);";
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
        let createTableString = "CREATE TABLE IF NOT EXISTS Pazienti(Id INTEGER PRIMARY KEY AUTOINCREMENT,username TEXT, password TEXT, medico INTEGER);";
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
        let createTableString = "CREATE TABLE IF NOT EXISTS Esercizi(Id INTEGER PRIMARY KEY AUTOINCREMENT, assegnatoDa INTEGER, assegnatoA INTEGER, flex INTEGER, ext INTEGER, completato INTEGER);";
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
    
    func insertMedico(username:String, password:String) {
        
        for m in readMedici() {
            if (username != m.username){
                checkM = true
            } else {
                checkM = false
                break
            }
        }
        
        if (checkM) {
            let insertStatementString = "INSERT INTO Medici (username, password) VALUES (?, ?);"
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (username as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, (password as NSString).utf8String, -1, nil)
                  
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted Medico row.")
                } else {
                    print("Could not insert Medico row.")
                }
            } else {
                print("INSERT Medico statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
            
        } else {
            print("Username già presente, impossibile inserire Medico")
        }
    }
    
    func insertPaziente(username:String, password:String, medico:Int) {
        
        for p in readPazienti() {
            if (username != p.username){
                checkP = true
            } else {
                checkP = false
                break
            }
            print("\(checkP)   \(p.username)")
        }
        
        if (checkP) {
            let insertStatementString = "INSERT INTO Pazienti (username, password, medico) VALUES (?, ?, ?);"
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (username as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, (password as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 3, Int32(medico))
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted Paziente row.")
                } else {
                    print("Could not insert Paziente row.")
                }
            } else {
                print("INSERT Paziente statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
        } else {
            print("Username già presente, impossibile inserire Paziente")
        }
    }
    
    func insertEsercizio(assegnatoDa:Int, assegnatoA:Int, flex:Int, ext:Int, completato:Int) {
           let insertStatementString = "INSERT INTO Esercizi (assegnatoDa, assegnatoA, flex, ext, completato) VALUES (?, ?, ?, ?, ?);"
           var insertStatement: OpaquePointer? = nil
           if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
               sqlite3_bind_int(insertStatement, 1, Int32(assegnatoDa))
               sqlite3_bind_int(insertStatement, 2, Int32(assegnatoA))
               sqlite3_bind_int(insertStatement, 3, Int32(flex))
               sqlite3_bind_int(insertStatement, 4, Int32(ext))
               sqlite3_bind_int(insertStatement, 5, Int32(completato))
                 
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
    
    func readMedici() -> [Medico] {
            var mainList = [Medico]()
            
            let query = "SELECT * FROM Medici;"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let username = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                    let password = String(describing: String(cString: sqlite3_column_text(statement, 2)))

                    let model = Medico()
                    model.id = id
                    model.username = username
                    model.password = password
                    
                    mainList.append(model)
                    print("Query Medici Result:")
                    print("\(id) | \(username) | \(password)")
                }
            }
        return mainList
    }
    
    func readPazienti() -> [Paziente] {
            var mainList = [Paziente]()
            
            let query = "SELECT * FROM Pazienti;"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let username = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                    let password = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                    let medico = Int(sqlite3_column_int(statement, 3))

                    let model = Paziente()
                    model.id = id
                    model.username = username
                    model.password = password
                    model.medico = medico
                    
                    mainList.append(model)
                    print("Query Pazienti Result:")
                    print("\(id) | \(username) | \(password) | \(medico)")
                }
            }
        return mainList
    }
    
    func readEsercizi() -> [Esercizio] {
            var mainList = [Esercizio]()
            
            let query = "SELECT * FROM Esercizi;"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let assegnatoDa = Int(sqlite3_column_int(statement, 1))
                    let assegnatoA = Int(sqlite3_column_int(statement, 2))
                    let flex = Int(sqlite3_column_int(statement,3))
                    let ext = Int(sqlite3_column_int(statement, 4))
                    let completato = Int(sqlite3_column_int(statement, 5))

                    let model = Esercizio()
                    model.id = id
                    model.assegnatoDa = assegnatoDa
                    model.assegnatoA = assegnatoA
                    model.flex = flex
                    model.ext = ext
                    model.completato = completato
                    
                    mainList.append(model)
                    print("Query Esercizi Result:")
                    print("\(id) | \(assegnatoDa) | \(assegnatoA) | \(flex) | \(ext) | \(completato)")
                }
            }
        return mainList
    }
    
    func deleteMedico(id : Int) {
        let query = "DELETE FROM Medici where id = \(id)"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Medico \(id) delete success")
            }else {
                print("Medico \(id) is not deleted in table")
            }
        }
    }
    
    func deletePaziente(id : Int) {
        let query = "DELETE FROM Pazienti where id = \(id)"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Paziente \(id) delete success")
            }else {
                print("Paziente \(id) is not deleted in table")
            }
        }
    }
    
    func deleteEsercizio(id : Int) {
        let query = "DELETE FROM Esercizi where id = \(id)"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Esercizio \(id) delete success")
            }else {
                print("Esercizio \(id) is not deleted in table")
            }
        }
    }
    
    func updateMedico(id : Int, attributo:String, valore:String) {
        let query = "UPDATE Medici SET \(attributo) = \(valore) WHERE id = \(id);"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Medico \(id) updated success")
            }else {
                print("Medico \(id) is not updated in table")
            }
        }
    }
    
    func updatePaziente(id : Int, attributo:String, valore:String) {
        let query = "UPDATE Pazienti SET \(attributo) = \(valore) WHERE id = \(id);"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Paziente \(id) updated success")
            }else {
                print("Paziente \(id) is not updated in table")
            }
        }
    }
    
    func updateEsercizio(id : Int) {
        let query = "UPDATE Esercizi SET completato = 1 WHERE id = \(id);"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Esercizio \(id) updated success")
            }else {
                print("Esercizio \(id) is not updated in table")
            }
        }
    }
}
