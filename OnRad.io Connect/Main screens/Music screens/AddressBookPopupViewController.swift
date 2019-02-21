//
//  AddressBookPopupViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/17/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit
import Contacts

class AddressBookPopupViewController: UIViewController {
    
    // MARK: - Properties
    private var addressBookUsers = [AddressBookUser]()
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    
    // MARK: - Actions
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            // TODO: - Add function for saving choosed type of acception
            print("WOw")
        })
    }
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegations()
        configureViews()
        fetchContacts()
    }
    private func delegations() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Configure views
    private func configureViews() {
        configurePopupView()
        configureTableViews()
    }
    private func configurePopupView() {
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = 15.0
        tableView.tableFooterView = UIView()
    }
    private func configureTableViews() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3))
        footerView.addTopBorderWithColor(color: .lightGray, width: 0.3)
        
        tableView.tableFooterView = footerView
    }
    
    // MARK: - Fetch info from contacts
    private func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        self.addressBookUsers.append(AddressBookUser(name: contact.givenName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    })
                } catch let err {
                    print("Failed to enumerate contacts:", err)
                }
            } else {
                print("Access denied...")
            }
        }
    }
    
}

// MARK: - Table view delegation
extension AddressBookPopupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            switch cell.accessoryType {
            case .none:
                cell.accessoryType = .checkmark
            case .checkmark:
                cell.accessoryType = .none
            default:
                break
            }
        }
        addressBookUsers[indexPath.row].isSelected = !addressBookUsers[indexPath.row].isSelected
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}

// MARK: - Table view data source
extension AddressBookPopupViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50.0))
        headerView.configureHeaderView(withTitle: "Address Book", fontSize: 18.0)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBookUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.addressBookTableViewReusableIdentifier, for: indexPath)
        
        cell.textLabel?.text = addressBookUsers[indexPath.row].name
        
        return cell
    }
    
}
