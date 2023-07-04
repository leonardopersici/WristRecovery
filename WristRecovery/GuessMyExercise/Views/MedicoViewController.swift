//
//  MedicoViewController.swift
//  WristRecovery
//
//  Created by Leonardopersici on 08/06/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class MedicoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var medici = [Medico]()
    var pazienti = [Paziente]()
    var medico = Medico()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

extension MedicoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped \(indexPath.row)")
        
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "EserciziPazienteViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `PazienteViewController`.
        guard let eserciziPazienteVC = viewController as? EserciziPazienteViewController else {
            fatalError("Couldn't cast the EserciziPaziente View Controller.")
        }
        
        let paziente = pazienti[indexPath.row]
        
        eserciziPazienteVC.medico = medico
        eserciziPazienteVC.paziente = paziente
        
        // Define the presentation style for the login view.
        eserciziPazienteVC.modalPresentationStyle = .fullScreen
        eserciziPazienteVC.modalTransitionStyle = .flipHorizontal
        
        // Present the login view to the user.
        present(eserciziPazienteVC, animated: true)
    }
}

extension MedicoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medico.pazienti!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPaziente", for: indexPath)
        guard let pazienteCell = cell as? MedicoTableViewCell else {
            fatalError("Not an isntance of 'MedicoViewController'.")}
        var nomiPazienti = [String]()
        for i in medico.pazienti! {
            for np in pazienti {
                if (i == np.id){
                    nomiPazienti.append(np.username)
                }
            }
        }
        
        pazienteCell.pazienteLabel.text = nomiPazienti[indexPath.row]
        return pazienteCell
    }
}

class MedicoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var pazienteLabel: UILabel!
    
    @IBAction func OnPlusButtonTapped(_ sender: Any) {
        print("bottone schiacciato")
    }
    
}
