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
    
    @IBOutlet var blurView: UIView!
    
    let db = DBManager()
    var medico = Medico()
    var paziente = Paziente()
    var eserciziPaziente = [Esercizio]()

    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in blurView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
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
    
    @IBAction func OnBackButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func OnAssegnaButtonTapped(_ sender: Any) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurView.addSubview(blurEffectView)
        
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
        
        popUpEsercizioVC.medicoID = medico
        popUpEsercizioVC.pazienteID = paziente
        
        // Define the presentation style for the main view.
        modalPresentationStyle = .popover
        modalTransitionStyle = .coverVertical
        
        // Present the paziente view to the user.
        present(popUpEsercizioVC, animated: true)
    }    
}

extension EserciziPazienteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("you tapped \(indexPath.row)")
    }
}

extension EserciziPazienteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eserciziPaziente.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEsercizio", for: indexPath)
        guard let esercizioCell = cell as? EsercizioTableViewCell else {
            fatalError("Not an isntance of 'EsercizioPazienteViewController'.")}
        
        if(eserciziPaziente[indexPath.row].completato == 1){
            esercizioCell.doneIcon.isHidden = false
            esercizioCell.todoIcon.isHidden = true
        }
        esercizioCell.esercizioLabel.text = "Sessione \(indexPath.row + 1)"
        esercizioCell.flexLabel.text = "Flessioni: \(eserciziPaziente[indexPath.row].flex)"
        esercizioCell.extLabel.text = "Estensioni: \(eserciziPaziente[indexPath.row].ext)"
        return esercizioCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //delete
        let delete = UIContextualAction(style: .normal, title: "Elimina") { (action, view, completionHandler) in
            // create the alert
            let alert = UIAlertController(title: "Elimina esercizio", message: "Cliccando su Elimina confermi la cancellazione dell'esercizio selezionato. Clicca su Annulla per cancellare l'operazione.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Elimina", style: UIAlertAction.Style.destructive, handler: { action in
                
                // do something like...
                self.db.deleteEsercizio(id: self.eserciziPaziente[indexPath.row].id)
                self.viewDidLoad()

            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        //swipe actions
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //delete
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
            // create the alert
            let alert = UIAlertController(title: "Elimina esercizio", message: "Cliccando su Elimina confermi la cancellazione dell'esercizio selezionato. Clicca su Annulla per cancellare l'operazione.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Elimina", style: UIAlertAction.Style.destructive, handler: { action in
                
                // do something like...
                self.db.deleteEsercizio(id: self.eserciziPaziente[indexPath.row].id)
                self.viewDidLoad()

            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        //swipe actions
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}
