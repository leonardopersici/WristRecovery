//
//  PopUpPazienteViewController.swift
//  WristRecovery
//
//  Created by Leonardopersici on 07/07/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class PopUpPazienteViewController: UIViewController {

    @IBOutlet var bgView: UIView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    
    let db = DBManager()
    
    var medicoID = Int()
    var pazienteID = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PopUpEsercizioViewController.tapCloseFunction))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let firstVC = presentingViewController as? MedicoViewController {
            DispatchQueue.main.async {
                firstVC.viewDidLoad()
            }
        }
    }
    
    @IBAction func OnConfermaButtonTapped(_ sender: Any) {
        if(usernameField.text != ""){
            db.insertPaziente(id: pazienteID, username: usernameField.text!, password: "0000", medico: medicoID)
            dismiss(animated: true)
        } else {
            // create the alert
            let alert = UIAlertController(title: "Inserire Username", message: "E' necessario inserire uno username per il paziente che si vuole creare. Per favore inserire lo username del paziente e cliccare su Conferma.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func tapCloseFunction(sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
