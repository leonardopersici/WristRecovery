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
    var username = ""
    var password = ""
    
    let names = [
        "Mallio Ciao",
        "Billy Balla",
        "Ballo Billy",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension MedicoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
}

extension MedicoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for m in medici{
            if(m.username == username){
                return m.pazienti!.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPaziente", for: indexPath)
        var nomi = [String]()
        for m in medici{
            if(m.username == username){
                var ids = m.pazienti!
                for p in pazienti {
                    nomi.append(p.username)
                }
            }
        }
        cell.textLabel?.text = nomi[indexPath.row]
        return cell
    }
}
