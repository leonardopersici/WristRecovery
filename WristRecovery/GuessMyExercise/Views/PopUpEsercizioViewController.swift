//
//  PopUpEsercizioViewController.swift
//  WristRecovery
//
//  Created by Leonardopersici on 01/07/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class PopUpEsercizioViewController: UIViewController {

    let db = DBManager()
    
    var medicoID = Int()
    var pazienteID = Int()
    var esercizioID = Int()
    
    @IBOutlet weak var flexField: UITextField!
    @IBOutlet weak var extField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Valori passati \(medicoID) \(pazienteID) \(esercizioID)")
    }

    @IBAction func OnConfermaButtonTapped(_ sender: Any) {
        
        db.insertEsercizio(id: esercizioID, assegnatoDa: medicoID, assegnatoA: pazienteID, flex: Int(flexField.text ?? "") ?? 0, ext: Int(extField.text ?? "") ?? 0, completato: 0)
        
        dismiss(animated: true)
    }
}
