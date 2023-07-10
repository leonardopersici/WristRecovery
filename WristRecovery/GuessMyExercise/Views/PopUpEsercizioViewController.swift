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
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet var bgView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PopUpEsercizioViewController.tapCloseFunction))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tap)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let firstVC = presentingViewController as? EserciziPazienteViewController {
            DispatchQueue.main.async {
                firstVC.viewDidLoad()
            }
        }
    }

    @IBAction func OnConfermaButtonTapped(_ sender: Any) {
        db.insertEsercizio(id: esercizioID, assegnatoDa: medicoID, assegnatoA: pazienteID, flex: Int(flexField.text ?? "") ?? 1, ext: Int(extField.text ?? "") ?? 1, completato: 0)
        
        dismiss(animated: true)
    }
    @objc func tapCloseFunction(sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
