//
//  PipeViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/2/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

// MARK: - Protocols
protocol PipeTableViewCellDelegate : class {
    func dumpPiper(_ sender: PiperCell)
    func dumpRequest(_ sender: RequestCell)
}

// MARK: - Classes
class PipeViewController: UIViewController, PipeTableViewCellDelegate {
    
    // MARK: - Constants
    private let headerHeight: CGFloat = 50.0
    
    // MARK: - Properties
    private var pipers = [Piper]()
    private var requests = [PipeRequest]()
    
    // MARK: - Outlets
    @IBOutlet weak var pipersTableView: UITableView!
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inviteTextField: UITextField!
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()

        delegations()
        configureViews()
        configureData()
    }
    private func delegations() {
        // Pipers table view delegation
        pipersTableView.delegate = self
        pipersTableView.dataSource = self
        
        // Request table view delegation
        requestTableView.delegate = self
        requestTableView.dataSource = self
        
        // Text field delegation
        inviteTextField.delegate = self
    }
    
    // MARK: - Configure views
    private func configureViews() {
        configureSendButton()
        configureTableViews()
        registerForKeyboardNotifications()
    }
    private func configureSendButton() {
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
    }
    private func configureTableViews() {
        let pipersFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3))
        pipersFooterView.addTopBorderWithColor(color: .lightGray, width: 0.3)
        let requestFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3))
        requestFooterView.addTopBorderWithColor(color: .lightGray, width: 0.3)
        
        
        pipersTableView.tableFooterView = pipersFooterView
        requestTableView.tableFooterView = requestFooterView
    }
    
    // MARK: - Keyboard methods
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
            if self.view.frame.origin.y == 0 && UIResponder.currentFirstResponder == inviteTextField {
                self.view.frame.origin.y -= (keyboardSize.height - 10)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect) != nil {
            if self.view.frame.origin.y != 0 && UIResponder.currentFirstResponder == inviteTextField  {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    // MARK: - Table view cell delegation funcions
    func dumpPiper(_ sender: PiperCell) {
        guard let tappedIndexPath = pipersTableView.indexPath(for: sender) else { return }
        
        // Delete the row
        pipers.remove(at: tappedIndexPath.row)
        pipersTableView.deleteRows(at: [tappedIndexPath], with: .automatic)
    }
    func dumpRequest(_ sender: RequestCell) {
        guard let tappedIndexPath = requestTableView.indexPath(for: sender) else { return }

        // Delete the row
        requests.remove(at: tappedIndexPath.row)
        requestTableView.deleteRows(at: [tappedIndexPath], with: .automatic)
    }

    // MARK: - Configure data
    private func configureData() {
        // Configure pipers
        pipers.append(Piper(name: "LokieMean", isSending: true))
        pipers.append(Piper(name: "LuxoryLifer", isReceiving: true))
        pipers.append(Piper(name: "CaceFace", isSending: true))
        pipers.append(Piper(name: "Opium", isSending: true, isReceiving: true))
        pipers.append(Piper(name: "Askabana", isReceiving: true))
        pipers.append(Piper(name: "Olsior", isSending: true))
        pipers.append(Piper(name: "Esket", isSending: true, isReceiving: true))
        
        // Configure requests
        requests.append(PipeRequest(name: "Astalavista"))
        requests.append(PipeRequest(name: "Omnic"))
        requests.append(PipeRequest(name: "Loskot"))
        requests.append(PipeRequest(name: "Optovik"))
        requests.append(PipeRequest(name: "Qivi"))
        requests.append(PipeRequest(name: "Tiko"))
        requests.append(PipeRequest(name: "Molker"))
        
        pipersTableView.reloadData()
        requestTableView.reloadData()
    }
    
}

// MARK: - Invite text field delegation
extension PipeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Table views delegation
extension PipeViewController: UITableViewDelegate {
    
    // configure cell tap if needed
    
}

// MARK: - Table views data source
extension PipeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
        if tableView == pipersTableView {
            headerView.configureHeaderView(withTitle: "Pipers", fontSize: 18.0)
            
            return headerView
        }
        if tableView == requestTableView {
            headerView.configureHeaderView(withTitle: "Requests", fontSize: 18.0)
            
            return headerView
        }
        
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == pipersTableView {
            return pipers.count
        }
        if tableView == requestTableView {
            return requests.count
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == pipersTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.pipersTableViewReuseIdentifier, for: indexPath) as? PiperCell {
                cell.delegate = self
                cell.configureCell(piper: pipers[indexPath.row])
                
                return cell
            }
        }
        if tableView == requestTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.requestTableViewReuseIdentifier, for: indexPath) as? RequestCell {
                cell.delegate = self
                cell.configureCell(name: requests[indexPath.row].name)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
}
