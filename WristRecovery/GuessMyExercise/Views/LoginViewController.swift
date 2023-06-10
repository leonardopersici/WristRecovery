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
    @IBOutlet weak var accediButton: UIButton!
    @IBOutlet weak var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapFunction))
        testLabel.isUserInteractionEnabled = true
        testLabel.addGestureRecognizer(tap)
    }
    @IBAction func onAccediButtonTapped(_ sender: Any) {
        let medici = self.db.readMedici()
        let pazienti = self.db.readPazienti()
        let esercizi = self.db.readEsercizi()
        var login = false
        
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
                
                medicoVC.medici = medici
                medicoVC.pazienti = pazienti
                medicoVC.medico = medico
                
                // Define the presentation style for the main view.
                modalPresentationStyle = .popover
                modalTransitionStyle = .coverVertical
                
                // Present the medico view to the user.
                present(medicoVC, animated: true)
                login = true
                break
            } else {
                print("CREDENZIALI ERRATE M")
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
                    pazienteVC.eserciziPaziente = eserciziPaziente
                    pazienteVC.paziente = paziente
                    
                    // Define the presentation style for the main view.
                    modalPresentationStyle = .popover
                    modalTransitionStyle = .coverVertical
                    
                    // Present the paziente view to the user.
                    present(pazienteVC, animated: true)
                    break
                } else {
                    print("CREDENZIALI ERRATE P")
                }
            }
        }
    }
    @objc func tapFunction(sender:UITapGestureRecognizer) {

        print("tap working")
    }
}
