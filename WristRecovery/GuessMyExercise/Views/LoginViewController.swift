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
    var username = ""
    var password = ""
    
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
        username = usernameField.text!
        password = passwordField.text!
        let medici = self.db.readMedici()
        let pazienti = self.db.readPazienti()
        var login = false
        
        for m in medici {
            if (username == m.username && password == m.password){
                print("CREDENZIALI CORRETTE M")
                let main = UIStoryboard(name: "Main", bundle: nil)

                // Get the view controller based on its name.
                let vcName = "MedicoViewController"
                let viewController = main.instantiateViewController(identifier: vcName)

                // Cast it as a `MedicoViewController`.
                guard let medicoVC = viewController as? MedicoViewController else {
                    fatalError("Couldn't cast the Login View Controller.")
                }
                
                medicoVC.medici = medici
                medicoVC.pazienti = pazienti
                medicoVC.username = username
                medicoVC.password = password
                
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
                if (username == p.username && password == p.password){
                    print("CREDENZIALI CORRETTE P")
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
