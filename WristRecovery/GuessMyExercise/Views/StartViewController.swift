//
//  StartViewController.swift
//  PushupBattle
//
//  Created by leonardo persici on 26/07/22.
//  Copyright © 2022 UNIMI. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var tutorialLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var startIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapTutorial = UITapGestureRecognizer(target: self, action: #selector(StartViewController.tapTutorialFunction))
        tutorialLabel.isUserInteractionEnabled = true
        tutorialLabel.addGestureRecognizer(tapTutorial)
        
        let tapCredits = UITapGestureRecognizer(target: self, action: #selector(StartViewController.tapCreditsFunction))
        creditsLabel.isUserInteractionEnabled = true
        creditsLabel.addGestureRecognizer(tapCredits)
        
        let tapStart = UITapGestureRecognizer(target: self, action: #selector(StartViewController.tapStartFunction))
        startIcon.isUserInteractionEnabled = true
        startIcon.addGestureRecognizer(tapStart)
        
        }
    
    @objc func tapTutorialFunction(sender:UITapGestureRecognizer) {
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "TutorialViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `LoginViewController`.
        guard let tutorialVC = viewController as? TutorialViewController else {
            fatalError("Couldn't cast the Tutorial View Controller.")
        }
        
        // Define the presentation style for the login view.
        tutorialVC.modalPresentationStyle = .fullScreen
        tutorialVC.modalTransitionStyle = .coverVertical
        
        // Present the login view to the user.
        present(tutorialVC, animated: true)
    }
    
    @objc func tapCreditsFunction(sender:UITapGestureRecognizer) {
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "CreditsViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `LoginViewController`.
        guard let creditsVC = viewController as? CreditsViewController else {
            fatalError("Couldn't cast the Credits View Controller.")
        }
        
        // Define the presentation style for the login view.
        creditsVC.modalPresentationStyle = .fullScreen
        creditsVC.modalTransitionStyle = .coverVertical
        
        // Present the login view to the user.
        present(creditsVC, animated: true)
    }
    
    @objc func tapStartFunction(sender:UITapGestureRecognizer) {
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "LoginViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `LoginViewController`.
        guard let loginVC = viewController as? LoginViewController else {
            fatalError("Couldn't cast the Login View Controller.")
        }
        
        // Define the presentation style for the login view.
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .coverVertical
        
        // Present the login view to the user.
        present(loginVC, animated: true)
    }
}
