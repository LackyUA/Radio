//
//  MainScreenViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/2/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {
    
    // MARK: - Constants
    private let headerHeight: CGFloat = 50.0

    // MARK: - Outlets
    @IBOutlet var collectionOfButtons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegations()
        configureViews()
    }
    private func delegations() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Configure view
    private func configureViews() {
        configureButtons()
        configureTableViews()
    }
    private func configureButtons() {
        for button in collectionOfButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.height / 2
        }
    }
    private func configureTableViews() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3))
        footerView.addTopBorderWithColor(color: .lightGray, width: 0.3)
        
        tableView.tableFooterView = footerView
    }
    
}

// MARK: - Table view delegation
extension MainScreenViewController: UITableViewDelegate {
    
    // configure cell tap if needed
    
}

// MARK: - Table view data source
extension MainScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
        headerView.configureHeaderView(withTitle: "Outstanding Connections", fontSize: 18.0)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.outstandingConnectionsTableViewReuseIdentifier, for: indexPath)
        
        // configure cell
        
        return cell
    }
    
}
