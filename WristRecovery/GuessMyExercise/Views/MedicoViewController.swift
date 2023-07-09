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
    @IBOutlet var blurView: UIView!
    
    let db = DBManager()
    var pazientiMedico = [Paziente]()
    var medico = Medico()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in blurView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
        pazientiMedico.removeAll()
        let pazienti = self.db.readPazienti()
        for p in pazienti {
            if(p.medico == medico.id){
                pazientiMedico.append(p)
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
    
    @IBAction func OnNuovoButtonTapped(_ sender: Any) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurView.addSubview(blurEffectView)
        
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "PopUpPazienteViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `PazienteViewController`.
        guard let popUpPazienteVC = viewController as? PopUpPazienteViewController else {
            fatalError("Couldn't cast the PopUpPaziente View Controller.")
        }
        
        let medicoID = medico.id
        let pazienteID = self.db.readPazienti().count
        
        popUpPazienteVC.medicoID = medicoID
        popUpPazienteVC.pazienteID = pazienteID
        
        // Define the presentation style for the main view.
        modalPresentationStyle = .popover
        modalTransitionStyle = .coverVertical
        
        // Present the paziente view to the user.
        present(popUpPazienteVC, animated: true)
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
        
        let paziente = pazientiMedico[indexPath.row]
        
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
        return pazientiMedico.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPaziente", for: indexPath)
        guard let pazienteCell = cell as? MedicoTableViewCell else {
            fatalError("Not an isntance of 'MedicoViewController'.")}
        
        pazienteCell.pazienteLabel.text = pazientiMedico[indexPath.row].username
        return pazienteCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //delete
        let delete = UIContextualAction(style: .normal, title: "Elimina") { (action, view, completionHandler) in
            // create the alert
            let alert = UIAlertController(title: "Elimina paziente", message: "Cliccando su Elimina confermi la cancellazione del paziente selezionato e tutti i dati a lui annessi. Clicca su Annulla per cancellare l'operazione.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Elimina", style: UIAlertAction.Style.destructive, handler: { action in
                
                // do something like...
                self.db.deletePaziente(id: self.pazientiMedico[indexPath.row].id)
                for e in self.db.readEsercizi(){
                    if(e.assegnatoA == self.pazientiMedico[indexPath.row].id){
                        self.db.deleteEsercizio(id: e.id)
                    }
                }
                self.viewDidLoad()
                print("delete \(indexPath.row)")

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
        let delete = UIContextualAction(style: .normal, title: "Elimina") { (action, view, completionHandler) in
            // create the alert
            let alert = UIAlertController(title: "Elimina paziente", message: "Cliccando su Elimina confermi la cancellazione del paziente selezionato e tutti i dati a lui annessi. Clicca su Annulla per cancellare l'operazione.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Elimina", style: UIAlertAction.Style.destructive, handler: { action in
                
                // do something like...
                self.db.deletePaziente(id: self.pazientiMedico[indexPath.row].id)
                for e in self.db.readEsercizi(){
                    if(e.assegnatoA == self.pazientiMedico[indexPath.row].id){
                        self.db.deleteEsercizio(id: e.id)
                    }
                }
                self.viewDidLoad()
                print("delete \(indexPath.row)")

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

class MedicoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pazienteLabel: UILabel!
    
}
