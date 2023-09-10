//
//  LoginViewController.swift
//  WristRecovery
//
//  Created by Leonardopersici on 03/06/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let db = DBManager()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var closeButton: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapClose = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapCloseFunction))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapClose)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let firstVC = presentingViewController as? StartViewController {
            DispatchQueue.main.async {
                firstVC.viewDidLoad()
            }
        }
    }
    
    @IBAction func OnAccediButtonTapped(_ sender: Any) {
        let medici = self.db.readMedici()
        let pazienti = self.db.readPazienti()
        let esercizi = self.db.readEsercizi()
        var login = false
        
        if (usernameField.text == "" || passwordField.text == ""){
                print("CREDENZIALI ERRATE")
                // create the alert
                let alert = UIAlertController(title: "Credenziali mancanti", message: "Lo username e/o la passsword non sono state inserite, si prega di inserire le credenziali mancanti e riprovare.", preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
        }
        
        for m in medici {
            if (usernameField.text == m.username && passwordField.text == m.password){
                print("CREDENZIALI CORRETTE M")
                let main = UIStoryboard(name: "Main", bundle: nil)

                // Get the view controller based on its name.
                let vcName = "MedicoViewController"
                let viewController = main.instantiateViewController(identifier: vcName)

                // Cast it as a `MedicoViewController`.
                guard let medicoVC = viewController as? MedicoViewController else {
                    fatalError("Couldn't cast the Medico View Controller.")
                }
                
                let medico = m
                var pazientiMedico = [Paziente]()
                
                for p in pazienti {
                    if (p.medico == m.id){
                        pazientiMedico.append(p)
                    }
                }
                medicoVC.pazientiMedico = pazientiMedico
                medicoVC.medico = medico
                
                // Define the presentation style for the login view.
                medicoVC.modalPresentationStyle = .fullScreen
                medicoVC.modalTransitionStyle = .coverVertical
                
                // Present the login view to the user.
                present(medicoVC, animated: true)
                login = true
                break
            }
        }
        if (login == false){
            for p in pazienti {
                if (usernameField.text == p.username && passwordField.text == p.password){
                    print("CREDENZIALI CORRETTE P")
                    let main = UIStoryboard(name: "Main", bundle: nil)

                    // Get the view controller based on its name.
                    let vcName = "PazienteViewController"
                    let viewController = main.instantiateViewController(identifier: vcName)

                    // Cast it as a `PazienteViewController`.
                    guard let pazienteVC = viewController as? PazienteViewController else {
                        fatalError("Couldn't cast the Paziente View Controller.")
                    }
                    
                    let paziente = p
                    var eserciziPaziente = [Esercizio]()
                    
                    for e in esercizi {
                        if (e.assegnatoA == p.id){
                            eserciziPaziente.append(e)
                        }
                    }
                    
                    pazienteVC.medici = medici
                    pazienteVC.pazienti = pazienti
                    pazienteVC.paziente = paziente
                    pazienteVC.eserciziPaziente = eserciziPaziente
                    
                    // Define the presentation style for the login view.
                    pazienteVC.modalPresentationStyle = .fullScreen
                    pazienteVC.modalTransitionStyle = .coverVertical
                    
                    // Present the login view to the user.
                    present(pazienteVC, animated: true)
                    login = true
                    break
                }
            }
            if (login == false) {
                print("CREDENZIALI ERRATE")
                // create the alert
                let alert = UIAlertController(title: "Credenziali errate", message: "Lo username e/o la passsword inserite sono errati, si prega di riprovare.", preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func tapCloseFunction(sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
