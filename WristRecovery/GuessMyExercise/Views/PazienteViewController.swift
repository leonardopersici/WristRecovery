//
//  PazienteViewController.swift
//  WristRecovery
//
//  Created by Leonardopersici on 09/06/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class PazienteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let db = DBManager()
    var medici = [Medico]()
    var pazienti = [Paziente]()
    var eserciziPaziente = [Esercizio]()
    var paziente = Paziente()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eserciziPaziente.removeAll()
        let esercizi = self.db.readEsercizi()
        for e in esercizi {
            if(e.assegnatoA == paziente.id){
                eserciziPaziente.append(e)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    @IBAction func OnLogoutButtonTapped(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "Logout", message: "Cliccando su Esci si tornerà alla schermata iniziale dell'applicazione. Se si vuole rimanere all'interno del prorpio account cliccare Annulla.", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Esci", style: UIAlertAction.Style.destructive, handler: { action in
            
            // do something like...
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            self.presentingViewController?.dismiss(animated: true, completion: nil)

        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension PazienteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(eserciziPaziente[indexPath.row].completato == 1){
            // create the alert
            let alert = UIAlertController(title: "Esercizio completato", message: "Complimenti, questo esercizio è stato già completato in precedenza. Selezionare un altro esercizio oppure attendere che il medico curante ne assegni ulteriori.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            let main = UIStoryboard(name: "Main", bundle: nil)

            // Get the view controller based on its name.
            let vcName = "MainViewController"
            let viewController = main.instantiateViewController(identifier: vcName)

            // Cast it as a `MedicoViewController`.
            guard let mainVC = viewController as? MainViewController else {
                fatalError("Couldn't cast the Main View Controller.")
            }
            
            mainVC.esercizio = eserciziPaziente[indexPath.row]
            
            // Define the presentation style for the main view.
            modalPresentationStyle = .popover
            modalTransitionStyle = .coverVertical
            
            // Present the main view to the user.
            present(mainVC, animated: true)
        }
    }
}

extension PazienteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eserciziPaziente.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEsercizio", for: indexPath)
        guard let esercizioCell = cell as? EsercizioTableViewCell else {
            fatalError("Not an isntance of 'PazienteViewController'.")}
        
        if(eserciziPaziente[indexPath.row].completato == 1){
            esercizioCell.doneIcon.isHidden = false
            esercizioCell.todoIcon.isHidden = true
        } else {
            esercizioCell.doneIcon.isHidden = true
            esercizioCell.todoIcon.isHidden = false
        }
        esercizioCell.esercizioLabel.text = "Sessione \(indexPath.row + 1)"
        esercizioCell.flexLabel.text = "Flessioni: \(eserciziPaziente[indexPath.row].flex)"
        esercizioCell.extLabel.text = "Estensioni: \(eserciziPaziente[indexPath.row].ext)"
        return esercizioCell
    }
}

class EsercizioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var todoIcon: UIImageView!
    @IBOutlet weak var doneIcon: UIImageView!
    @IBOutlet weak var esercizioLabel: UILabel!
    @IBOutlet weak var flexLabel: UILabel!
    @IBOutlet weak var extLabel: UILabel!
}

