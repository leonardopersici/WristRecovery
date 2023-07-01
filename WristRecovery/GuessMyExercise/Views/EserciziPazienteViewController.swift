//
//  EserciziPazienteViewController.swift
//  WristRecovery
//
//  Created by Leonardopersici on 01/07/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class EserciziPazienteViewController: UIViewController {
    
    @IBOutlet weak var nomePazienteLabel: UILabel!
    
    @IBOutlet weak var assegnaEsercizioButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = DBManager()
    var medico = Medico()
    var paziente = Paziente()
    var eserciziPaziente = [Esercizio]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eserciziPaziente.removeAll()
        let esercizi = self.db.readEsercizi()
        for e in esercizi {
            if(e.assegnatoA == paziente.id){
                eserciziPaziente.append(e)
            }
        }

        nomePazienteLabel.text = paziente.username
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    
    @IBAction func OnAssegnaEsercizioButtonTapped(_ sender: Any) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "PopUpEsercizioViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `PazienteViewController`.
        guard let popUpEsercizioVC = viewController as? PopUpEsercizioViewController else {
            fatalError("Couldn't cast the PopUpEsercizio View Controller.")
        }
        
        let paziente = paziente.id
        let medico = medico.id
        let id = db.readEsercizi().count
        
        popUpEsercizioVC.medicoID = medico
        popUpEsercizioVC.pazienteID = paziente
        popUpEsercizioVC.esercizioID = id
        
        // Define the presentation style for the main view.
        modalPresentationStyle = .popover
        modalTransitionStyle = .coverVertical
        
        // Present the paziente view to the user.
        present(popUpEsercizioVC, animated: true)
    }
    
}

extension EserciziPazienteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped \(indexPath.row)")
    }
}

extension EserciziPazienteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eserciziPaziente.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEsercizioPaziente", for: indexPath)
        guard let esercizioCell = cell as? EsercizioTableViewCell else {
            fatalError("Not an isntance of 'EserciziPazienteViewController'.")}
        
        if(eserciziPaziente[indexPath.row].completato == 1){
            esercizioCell.backgroundColor = UIColor.green
        }
        esercizioCell.esercizioLabel.text = "Esercizio \(eserciziPaziente[indexPath.row].id)"
        return esercizioCell
    }
}

class EserciziPazienteTableViewCell: UITableViewCell {
    
}
