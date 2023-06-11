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
    
    var medici = [Medico]()
    var pazienti = [Paziente]()
    var eserciziPaziente = [Esercizio]()
    var paziente = Paziente()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

}

extension PazienteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped \(indexPath.row)")
        
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

extension PazienteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eserciziPaziente.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEsercizio", for: indexPath)
        guard let esercizioCell = cell as? EsercizioTableViewCell else {
            fatalError("Not an isntance of 'PazienteViewController'.")}
        
        if(eserciziPaziente[indexPath.row].completato == 1){
            esercizioCell.esercizioLabel.backgroundColor = UIColor.green
        }
        esercizioCell.esercizioLabel.text = "Esercizio \(eserciziPaziente[indexPath.row].id)"
        return esercizioCell
    }
}

class EsercizioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var esercizioLabel: UILabel!
}

