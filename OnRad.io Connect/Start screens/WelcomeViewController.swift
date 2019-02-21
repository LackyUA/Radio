//
//  WelcomeViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/1/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var regButton: UIButton!
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    //MARK: - Configure views
    private func configureViews() {
        configureWelcomeText()
        configureRegButton()
    }
    private func configureWelcomeText() {
        let attributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
            NSAttributedStringKey.foregroundColor: UIColor.black
        ]
        welcomeLabel.attributedText = NSAttributedString(
            string: "Pipe music to another person location.\n\n" + "Find a song and...\n\n" + "Pipe it!",
            attributes: attributes
        )
    }
    private func configureRegButton() {
        regButton.layer.masksToBounds = true
        regButton.layer.cornerRadius = regButton.frame.height / 2
        regButton.setTitle("Create Account/Log in", for: .normal)
    }

}
