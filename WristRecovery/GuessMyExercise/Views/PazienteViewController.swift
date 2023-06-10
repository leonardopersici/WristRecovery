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
        
        print("TABLEVIEW: \(tableView)")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

}

extension PazienteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped \(indexPath.row)")
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
        
        esercizioCell.esercizioLabel.text = "Esercizio \(eserciziPaziente[indexPath.row].id)"
        return esercizioCell
    }
}

class EsercizioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var esercizioLabel: UILabel!
}

