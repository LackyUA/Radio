//
//  SettingViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/4/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class SettingViewController: UIViewController {

    // MARK: - Constants
    private let devToken = Constants.userDefaults.object(forKey: Constants.userDefaultsFirebaseRegToken) as! String
    
    // MARK: - Properties
    private var devices: [Device] = [Device]()
    private var device = Device() {
        didSet {
            nickNameLabel.text = device.deviceName
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet var collectionOfButtons: [UIButton]!
    
    // MARK: - Custom views
    private let changeView = UIView()
    private let nicknameField = UITextField()
    
    // MARK: - Actions
    @IBAction func buttonsTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            configureChangeAlert()
            break
        case 1:
            googleLogOutButtonTapped()
        default:
            break
        }
    }
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    // MARK: - Configure views
    private func configureViews() {
        configureButtons()
        configureNicknameLabel()
    }
    private func configureButtons() {
        for button in collectionOfButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.height / 2
        }
    }
    private func configureNicknameLabel() {
        nickNameLabel.text = Constants.userDefaults.string(forKey: Constants.userDefaultsDeviceName) ?? ""
    }
    
    // MARK: - Configure change alert
    private func configureChangeAlert() {
        
        let alert = UIAlertController(
            title: "Change Nickname",
            message: "Enter your new nickname and sumbit it.",
            preferredStyle: .alert
        )
        
        // Submit button
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
            let textField = alert.textFields![0]
            if let text = textField.text, text.count > 3 {
                Constants.userDefaults.set(text, forKey: Constants.userDefaultsDeviceName)
            }
            self.configureNicknameLabel()
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // Add textField and customize it
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Enter nickname"
            textField.clearButtonMode = .whileEditing
            textField.becomeFirstResponder()
        }
        
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    private func googleLogOutButtonTapped() {
        try! Auth.auth().signOut()
        GIDSignIn.sharedInstance().signOut()
        
        Constants.userDefaults.removeObject(forKey: Constants.userDefaultsGoogleEmail)
        Constants.userDefaults.removeObject(forKey: Constants.userDefaultsFirebaseUID)
        Constants.userDefaults.removeObject(forKey: Constants.userDefaultsFirebaseRegToken)
        Constants.userDefaults.removeObject(forKey: Constants.userDefaultsFirebaseToken)
        Constants.userDefaults.removeObject(forKey: Constants.userDefaultsDeviceName)
        Constants.userDefaults.removeObject(forKey: Constants.userDefaultsPhoneNumber)
        Constants.userDefaults.synchronize()
        
        let destinationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInView")
        present(destinationController, animated: true, completion: nil)
    }
    
}
