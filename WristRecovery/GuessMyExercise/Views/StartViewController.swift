//
//  StartViewController.swift
//  PushupBattle
//
//  Created by leonardo persici on 26/07/22.
//  Copyright © 2022 UNIMI. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        }
    @IBAction func onStartButtonTapped(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "LoginViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `LoginViewController`.
        guard let loginVC = viewController as? LoginViewController else {
            fatalError("Couldn't cast the Login View Controller.")
        }
        
        // Define the presentation style for the login view.
        modalPresentationStyle = .popover
        modalTransitionStyle = .coverVertical
        
        // Present the login view to the user.
        present(loginVC, animated: true)
        }
}
