//
//  SignUpViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/1/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignUpViewController: UIViewController {

    //MARK: - Properties
    private var devices: [Device] = [Device]()
    
    // MARK: - Outlets
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var googleActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var collectionOfButtons: [UIButton]!
    @IBOutlet var collectionOfTextFields: [UITextField]!
    
    // MARK: - Actions
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            googleActivityIndicator.isHidden = false
            googleActivityIndicator.startAnimating()
            GIDSignIn.sharedInstance().signIn()
        case 1:
            if collectionOfTextFields[0].text!.count > 0 {
                if !devices.contains(where: { $0.deviceName.lowercased() == collectionOfTextFields[0].text!.lowercased() } ) {
                    setDeviceName(deviceName: collectionOfTextFields[0].text!)
                    setPhoneNumber(phoneNumber: collectionOfTextFields[1].text!)
                    AppData.shared.sendDeviceInstance(regToken: getFirebaseRegToken(), deviceName: collectionOfTextFields[0].text!, deviceKey: getDeviceKey(), completion: { success in
                        print (success)
                    })
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        delegations()
    }
    private func delegations() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        for textField in collectionOfTextFields {
            textField.delegate = self
        }
    }
    
    // MARK: - Configure views
    private func configureViews() {
        configureButtons()
        configureActivityIndicator()
        registerForKeyboardNotifications()
        changeTextFieldsUserInteractivity(value: false)
        addTapGesture()
    }
    private func configureButtons() {
        for button in collectionOfButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.height / 2
            if button.tag == 1 {
                button.isUserInteractionEnabled = false
                button.backgroundColor = .lightGray
            }
        }
    }
    private func configureActivityIndicator() {
        googleActivityIndicator.isHidden = true
    }
    private func changeTextFieldsUserInteractivity(value: Bool) {
        for textField in collectionOfTextFields {
            textField.isUserInteractionEnabled = value
        }
    }
    
    // MARK: - Add tap gesture for dismissing keyboard
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func tapGesture(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            for textField in collectionOfTextFields {
                textField.resignFirstResponder()
            }
        default:
            break
        }
    }
    
    // MARK: - Keyboard notification methods
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard disappearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            for textField in collectionOfTextFields {
                if self.view.frame.origin.y == 0 && UIResponder.currentFirstResponder == textField {
                    self.view.frame.origin.y -= (keyboardSize.height - 150)
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect) != nil {
            for textField in collectionOfTextFields {
                if self.view.frame.origin.y != 0 && UIResponder.currentFirstResponder == textField  {
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func setDeviceName(deviceName: String) {
        Constants.userDefaults.set(deviceName, forKey: Constants.userDefaultsDeviceName)
    }
    private func setPhoneNumber(phoneNumber: String) {
        Constants.userDefaults.set(phoneNumber, forKey: Constants.userDefaultsPhoneNumber)
    }
    private func getFirebaseRegToken() -> String {
        return Constants.userDefaults.string(forKey: Constants.userDefaultsFirebaseRegToken)!
    }
    private func getDeviceKey() -> String {
        if let uuid = Constants.userDefaults.string(forKey: Constants.userDefaultsDeviceKey) {
            return uuid
        } else {
            let uuid = UUID().uuidString.lowercased()
            Constants.userDefaults.set(uuid, forKey: Constants.userDefaultsDeviceKey)
            return uuid
        }
    }
    private func getDevices() {
        self.devices.removeAll()
        AppData.shared.getDeviceInstances(completion: { devices in
            if devices.count > 0 {
                self.devices = devices.sorted(by: { $0.deviceName.lowercased() < $1.deviceName.lowercased() } )
            }
        })
    }
    private func showUIDandRegToken() {
        let uid = Constants.userDefaults.string(forKey: Constants.userDefaultsFirebaseUID)!
        let regToken = Constants.userDefaults.string(forKey: Constants.userDefaultsFirebaseRegToken)!
        self.showAlert(message: "Logged in successfully with Firebase UID:\n\(uid)\n\nand regToken:\n\(regToken)")
    }

}

// MARK: - Nickname text field delegation
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        getDevices()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if collectionOfTextFields[0].text!.count > 0, collectionOfTextFields[1].text!.count > 0 {
            for button in collectionOfButtons where button.tag == 1 {
                button.backgroundColor = #colorLiteral(red: 1, green: 0.4573812485, blue: 0, alpha: 1)
                button.isUserInteractionEnabled = true
            }
            if textField == collectionOfTextFields[0] {
                if devices.contains(where: { $0.deviceName.lowercased() == textField.text!.lowercased() } ) {
                    showAlert(message: "This device name is already in use")
                    for button in collectionOfButtons where button.tag == 1 {
                        button.backgroundColor = .lightGray
                        button.isUserInteractionEnabled = false
                    }
                }
            }
        } else {
            for button in collectionOfButtons where button.tag == 1 {
                button.backgroundColor = .lightGray
                button.isUserInteractionEnabled = false
            }
        }
    }
    
}

// MARK: - Google methods
extension SignUpViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            self.googleActivityIndicator.stopAnimating()
            self.showAlert(message: Constants.somethingWentWrong)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(
            withIDToken: authentication.idToken,
            accessToken: authentication.accessToken
        )
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
            if error != nil {
                self.googleActivityIndicator.stopAnimating()
                self.showAlert(message: Constants.somethingWentWrong)
                return
            }
            let uid = user!.user.uid
            print ("Firebase UID: \(uid)")
            Constants.userDefaults.set(uid, forKey: Constants.userDefaultsFirebaseUID)
            Constants.userDefaults.set(user?.user.email, forKey: Constants.userDefaultsGoogleEmail)
            Constants.userDefaults.synchronize()
            
            self.googleActivityIndicator.stopAnimating()
            self.getAllInfo(showUIDandRegToken: true)
            self.changeTextFieldsUserInteractivity(value: true)
        })
    }
    private func getAllInfo(showUIDandRegToken: Bool) {
        AppData.shared.getFirebaseToken(completion: { token in
            if token != "" {
                AppData.shared.getFirebaseRegToken(completion: { regToken in
                    if regToken != "" {
                        if showUIDandRegToken { self.showUIDandRegToken() }
                    }
                })
            }
        })
    }
    
}
