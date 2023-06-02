//
//  Medico.swift
//  WristRecovery
//
//  Created by Leonardopersici on 02/06/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class Medico : Decodable{
    var id : Int = 0
    var username : String = ""
    var password : String = ""
    var pazienti : [Int]?
}

class Paziente {
    var id : Int = 0
    var username : String = ""
    var password : String = ""
    var medico : Int?
}

class Esercizio {
    var id : Int = 0
    var assegnatoDa : Int?
    var assegnatoA : Int?
    var completato : Int = 0
}
