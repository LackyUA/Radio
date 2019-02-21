//
//  ViewController.swift
//  OnRad.io Connect
//
//  Created by Igor on 6/14/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
//import Fabric
//import Crashlytics
import NotificationCenter
import MediaPlayer

protocol DeviceCellDelegate {
    func removeDevice(deviceKey: String)
}

class DeviceCell: UITableViewCell {
    
//    var delegate: DeviceCellDelegate?
//    var deviceInstance: Device?
    @IBOutlet weak var deviceLabel: UILabel!
//    @IBOutlet weak var removeDeviceButton: UIButton!
    
//    @IBAction func removeDeviceButtonTapped(_ sender: Any) {
//
//        delegate?.removeDevice(deviceKey: deviceInstance!.deviceKey)
//    }
    
    
}

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var clientRegTokenTextField: UITextField!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var googleActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var googleSignInEmailLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var incVolumeButton: UIButton!
    @IBOutlet weak var decVolumeButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var commandSentLabel: UILabel!
    @IBOutlet weak var searchResultLabel: UILabel!
    
    @IBOutlet weak var devicesTableView: UITableView!
    
    @IBOutlet weak var stopIncomingPlaybackButton: UIButton!
    @IBOutlet weak var stopIncomingLabel: UILabel!
    @IBOutlet weak var stopIncomingLine: UIView!
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    @IBAction func stopIncomingPlaybackButtonTapped(_ sender: Any) {
        stopIncomingPlaybackButton.isHidden = true
        stopIncomingLabel.text = "Stopped playback"
        NotificationCenter.default.post(name: NSNotification.Name("stopPlayer"), object: nil)
    }
    
    
    var devices: [Device] = [Device]()
    var selectedDeviceKey: String = ""
    var selectedRegToken: String = ""
    var refreshing = false
    var firstStart = false
    var searchResult: SearchResult?
    
    func userLoggedIn(showLoginAlert: Bool) -> Bool {
        if Constants.userDefaults.object(forKey: "FirebaseUID") != nil {
            return true
        } else {
            if showLoginAlert { self.showAlert(message: "Please login first") }
            return false
        }
    }
    
    func toggleCommandSent() {
        UIView.animate(withDuration: 0.5, animations: {
            self.commandSentLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                self.commandSentLabel.alpha = 0.0
            })
        })
    }
    
    func getFirebaseUID() -> String {
        return Constants.userDefaults.string(forKey: "FirebaseUID")!
    }
    func getFirebaseToken() -> String {
        return Constants.userDefaults.string(forKey: "FirebaseToken")!
    }
    func getFirebaseRegToken() -> String {
        return Constants.userDefaults.string(forKey: "FirebaseRegToken")!
    }
    func getDeviceName() -> String {
        return Constants.userDefaults.string(forKey: "DeviceName") ?? ""
    }
    func setDeviceName(deviceName: String) {
        Constants.userDefaults.set(deviceName, forKey: "DeviceName")
    }
    func getDeviceKey() -> String {
        if let uuid = Constants.userDefaults.string(forKey: "DeviceKey") {
            return uuid
        } else {
            let uuid = UUID().uuidString.lowercased()
            Constants.userDefaults.set(uuid, forKey: "DeviceKey")
            return uuid
        }
    }
    func getRecepientDeviceKey() -> String {
        return selectedDeviceKey
    }
    func getRecepientRegToken() -> String {
        return selectedRegToken
    }
    
    @IBAction func volumeButtonTapped(_ sender: UIButton) {
        if getRecepientRegToken().count == 0 {
            self.showAlert(message: "Please select a device")
            return
        }
        
        if userLoggedIn(showLoginAlert: true) {
            toggleCommandSent()
            let upVolume = sender === incVolumeButton ? "1" : "0"
            let downVolume = sender === incVolumeButton ? "0" : "1"
            AppData.shared.sendVolume(recepientRegToken: getRecepientRegToken(), volume: "on", volumeUp: upVolume, volumeDown: downVolume, completion: { success in
                if success {
                    print ("volume changed succesfully")
                }
            })
        }
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        googleActivityIndicator.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        try! Auth.auth().signOut()
        GIDSignIn.sharedInstance().signOut()
        
        Constants.userDefaults.removeObject(forKey: "GoogleEmail")
        Constants.userDefaults.removeObject(forKey: "FirebaseUID")
        Constants.userDefaults.removeObject(forKey: "FirebaseRegToken")
        Constants.userDefaults.removeObject(forKey: "FirebaseToken")
//        Constants().removeSearchResult()
//        Constants.userDefaults.removeObject(forKey: "DeviceName")
        Constants.userDefaults.synchronize()
        self.devices.removeAll()
        self.devicesTableView.reloadData()
        self.selectedRegToken = ""
        
        updateSigninState()
        
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        toggleCommandSent()
        getDevices()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        if getRecepientRegToken().count == 0 {
            self.showAlert(message: "Please select a device")
            return
        }
        if let sr = self.searchResult  {
            
            if userLoggedIn(showLoginAlert: true) {
                toggleCommandSent()
                AppData.shared.sendData(recepientRegToken: getRecepientRegToken(), streamUrl: "\(sr.streamUrl)|||||\(sr.name)", title: "Received \(sr.name)", completion: { success in
                    if success {
                        print ("sent stream succesfully")
                    }
                })
                
            }
            
        } else {
            self.showAlert(message: "Please select search result first")
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        
        if getRecepientRegToken().count == 0 {
            self.showAlert(message: "Please select a device")
            return
        }
        
        if userLoggedIn(showLoginAlert: true) {
            toggleCommandSent()
            AppData.shared.sendVolume(recepientRegToken: getRecepientRegToken(), volume: "mute", volumeUp: "0", volumeDown: "0", completion: { success in
                if success {
                    print ("music stopped succesfully")
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(MPVolumeView(frame: CGRect(x: 0, y: -200, width: 10, height: 10)))
        
        registerForKeyboardNotifications()

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 15
        stopButton.layer.masksToBounds = true
        stopButton.layer.cornerRadius = 15
        
        
        googleSignInButton.layer.masksToBounds = true
        googleSignInButton.layer.cornerRadius = 15
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.cornerRadius = 15
        
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.tableFooterView = UIView()
        devicesTableView.isScrollEnabled = devices.count != 0
//        devicesTableView.backgroundColor = UIColor.clear
        refreshButton.isHidden = true//!userLoggedIn(showLoginAlert: false)
        
        incVolumeButton.layer.cornerRadius = 15
        decVolumeButton.layer.cornerRadius = 15
        incVolumeButton.layer.borderColor = UIColor.darkGray.cgColor
        decVolumeButton.layer.borderColor = UIColor.darkGray.cgColor
        incVolumeButton.layer.borderWidth = 2
        decVolumeButton.layer.borderWidth = 2
        
        commandSentLabel.alpha = 0.0
        
        stopIncomingPlaybackButton.layer.cornerRadius = 15
        stopIncomingPlaybackButton.layer.masksToBounds = true
        stopIncomingPlaybackButton.isHidden = true
        
        deviceNameTextField.text = getDeviceName()
        deviceNameTextField.delegate = self
        
        searchResultLabel.isUserInteractionEnabled = true
        searchResultLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSearch)))
        searchResultLabel.layer.masksToBounds = true
        searchResultLabel.layer.cornerRadius = 15
//        Constants().removeSearchResult()
        
        if !firstStart {
            firstStart = true
            NotificationCenter.default.addObserver(self, selector: #selector(playPlayer(_:)), name: NSNotification.Name("playPlayer"), object: nil)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        buildNumberLabel.text = "B: \(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
        
        updateSigninState()
        
        if userLoggedIn(showLoginAlert: false) {
            getAllInfo(showUIDandRegToken: false)
        }
    }
    
    @objc func playPlayer(_ notification: NSNotification) {
        if let url = notification.userInfo?["stream"] as? String {
            stopIncomingLabel.text = "Playing \(url)"
            stopIncomingPlaybackButton.isHidden = false
            // do something with your image
        }
        
        if let _ = notification.userInfo?["stop"] as? String {
            stopIncomingPlaybackButton.isHidden = true
            stopIncomingLabel.text = "Stopped playback"
        }
        
        if let _ = notification.userInfo?["volUp"] as? String {
            MPVolumeView.setVolume(getVolume()+0.1)
        }
        
        if let _ = notification.userInfo?["volDown"] as? String {
            MPVolumeView.setVolume(getVolume()-0.1)
        }
    }
    
    func getVolume() -> Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sr = searchResult {
            searchResultLabel.text = sr.name
        } else {
            searchResultLabel.text = "Tap to search"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // This is used after coming out from background
    func getAllInfoIfSignedIn() {
        
        if userLoggedIn(showLoginAlert: false) {
            getAllInfo(showUIDandRegToken: false)
        }
    }
    
    
    func updateSigninState() {
        var signedIn = false
        if let _ = Constants.userDefaults.string(forKey: "GoogleEmail") {
            signedIn = true
        }
        
        let blue = UIColor.init(hex: "2e86c1")
        let lightGrey = UIColor(hex: "c8c7cc")
        
        googleSignInEmailLabel.text = signedIn ? "Signed in with: \(String(describing: Constants.userDefaults.object(forKey: "GoogleEmail")!))" : "Not signed in"
        googleSignInButton.backgroundColor = signedIn ? lightGrey : blue
        googleSignInButton.setTitleColor(signedIn ? UIColor.black : UIColor.white , for: .normal)
        googleSignInButton.isEnabled = !signedIn
        
//        refreshButton.isHidden = !signedIn
        
        logoutButton.isEnabled = signedIn
        logoutButton.backgroundColor = !signedIn ? lightGrey : blue
        logoutButton.setTitleColor(!signedIn ? UIColor.black : UIColor.white , for: .normal)
        
//        stopIncomingPlaybackButton.isHidden = !signedIn
        stopIncomingLabel.isHidden = !signedIn
        stopIncomingLine.isHidden = !signedIn
        deviceNameTextField.isHidden = !signedIn
    }
    
    @objc func singleTap() {
        view.endEditing(true)
    }
}


extension ViewController {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if error != nil {
            // ...
            self.googleActivityIndicator.stopAnimating()
            self.showAlert(message: Constants.somethingWentWrong)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
//        let googleUID = user.userID
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
            if error != nil {
                // ...
                self.googleActivityIndicator.stopAnimating()
                self.showAlert(message: Constants.somethingWentWrong)
                return
            }
            let uid = user!.user.uid
            print ("Firebase UID: \(uid)")
            Constants.userDefaults.set(uid, forKey: "FirebaseUID")
            Constants.userDefaults.set(user?.user.email, forKey: "GoogleEmail")
            Constants.userDefaults.synchronize()
            
            
            self.updateSigninState()
            
            self.googleActivityIndicator.stopAnimating()
            self.getAllInfo(showUIDandRegToken: true)
            
//            let userInfo = UserInfo()
//            userInfo.username = user!.displayName!
//            userInfo.email = user!.email!
//            userInfo.photoUrl = String(describing: user!.photoURL!)
//            userInfo.googleUID =  googleUID!
//            userInfo.facebookUID = ""
//            userInfo.firebaseUID = user!.uid
//            DBManager.shared.setUserInfo(object: userInfo)
            
            // User is signed in
            // ...
        })
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        self.googleActivityIndicator.stopAnimating()
        self.showAlert(message: Constants.somethingWentWrong)
        // ...
    }
    
    func showUIDandRegToken() {
        let uid = Constants.userDefaults.string(forKey: "FirebaseUID")!
        let regToken = Constants.userDefaults.string(forKey: "FirebaseRegToken")!
        self.showAlert(message: "Logged in successfully with Firebase UID:\n\(uid)\n\nand regToken:\n\(regToken)")
    }
    
    func getAllInfo(showUIDandRegToken: Bool) {
        AppData.shared.getFirebaseToken(completion: { token in
            if token != "" {
                AppData.shared.getFirebaseRegToken(completion: { regToken in
                    if regToken != "" {
                        if showUIDandRegToken { self.showUIDandRegToken() }
                    }
                })
                self.getDevices()
            }
        })
    }
    
    func getDevices() {
        self.refreshing = true
        self.devices.removeAll()
        self.devicesTableView.reloadData()
        AppData.shared.getDeviceInstances(completion: { devices in
            self.refreshing = false
            if devices.count > 0 {
                
                self.devices = devices.sorted(by: { $0.deviceName.lowercased() < $1.deviceName.lowercased() } )
                self.devicesTableView.isScrollEnabled = true
            }
            self.devicesTableView.reloadData()
            if self.selectedRegToken.count > 0 && devices.count > 0 {
                if let devIndex = self.devices.index(where: { $0.regToken == self.selectedRegToken }) {
                    self.devicesTableView.selectRow(at: IndexPath(row: devIndex, section: 0), animated: false, scrollPosition: .middle)
                }
            }
        })
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count > 0 ? devices.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hex: "c8c7cc")
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = UIColor.clear
        if devices.count == 0 {
//            cell.removeDeviceButton.isHidden = true
            var text = ""
            if !userLoggedIn(showLoginAlert: false) {
                text = "Please login first"
            } else {
                text = refreshing ? "Loading devices" : "No devices available"
            }
            cell.deviceLabel?.text = text
            return cell
        }
//        cell.removeDeviceButton.isHidden = false
//        cell.deviceInstance = devices[indexPath.row]
        cell.deviceLabel?.text = devices[indexPath.row].deviceName
//        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if devices.count != 0 {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            selectedRegToken = devices[indexPath.row].regToken
        }
    }
}

//extension ViewController: DeviceCellDelegate {
//    func removeDevice(deviceKey: String) {
//        toggleCommandSent()
//        print (deviceKey)
//        AppData.shared.deleteDeviceInstance(deviceKey: deviceKey, completion: { success in
//
//            print (success)
//            self.devicesTableView.reloadData()
//        })
//    }
//}

extension ViewController {
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            if self.view.frame.origin.y == 0 && UIResponder.currentFirstResponder == deviceNameTextField {
                self.view.frame.origin.y -= (keyboardSize.height)
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect) != nil {
            if self.view.frame.origin.y != 0 && UIResponder.currentFirstResponder == deviceNameTextField  {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    @objc func showSearch() {
        let searchVC = Constants().initiateVCFromStoryboard(name: Constants.searchViewController) as! SearchViewController
        searchVC.modalTransitionStyle = .crossDissolve
        searchVC.mainVC = self
        
        self.present(searchVC, animated: true, completion: nil)//(searchVC)
        
    }
    
//    func hideSearch() {
//        if Constants().getSearchResult() != nil {
//            searchResultLabel.text = Constants().getSearchResult()!.name
//        }
//    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == devicesTableView && !userLoggedIn(showLoginAlert: true) {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == deviceNameTextField && deviceNameTextField.text!.count > 0 {
            if devices.contains(where: { $0.deviceName.lowercased() == deviceNameTextField.text!.lowercased() } ) {
                showAlert(message: "This device name is already in use")
            } else {
                setDeviceName(deviceName: deviceNameTextField.text!)
                toggleCommandSent()
                AppData.shared.sendDeviceInstance(regToken: getFirebaseRegToken(), deviceName: deviceNameTextField.text!, deviceKey: getDeviceKey(), completion: { success in
                    print (success)
                    self.getDevices()
                })
            }
        }
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume;
        }
    }
}
