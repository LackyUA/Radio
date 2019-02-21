//
//  SearchViewController.swift
//  OnRad.io Connect
//
//  Created by Igor on 9/7/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class SearchViewController2: UIViewController {
    
    var suggestions = [SearchResult]()
    var stations = [SearchResult]()
    var searchResult: SearchResult?
    var mainVC: ViewController?
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.separatorColor = UIColor.clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(tap)
    }
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
//        Constants().setSearchResult(searchResult: searchResult)
//        mainVC?.hideSearch()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController2: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        suggestions.removeAll()
        stations.removeAll()
        
        searchTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        AppData.shared.loadAutocompletion(query: textField.text!, completion: { suggestions in
//            self.suggestions = suggestions
//            DataLoader().loadStations(query: textField.text!, completion: { stations in
//                self.stations = stations
//                self.searchTableView.reloadData()
//            })
        })
        return true
    }
}

extension SearchViewController2: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if suggestions.count + stations.count == 0 { return 1 }
        var c = suggestions.count > 0 ? 1 : 0
        c += stations.count > 0 ? 1 : 0
        return c
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if suggestions.count + stations.count == 0 { return 1 }
        if section == 0 {
            return suggestions.count
        }
        if section == 1 {
            return stations.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var text = ""
        if suggestions.count + stations.count == 0 {
            text = ""
        } else if indexPath.section == 0 {
            text = suggestions[indexPath.row].name
        } else if indexPath.section == 1 {
            text = stations[indexPath.row].name
        }
        cell.textLabel?.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if suggestions.count > 0 && section == 0 { return "Suggestions" }
        if stations.count > 0 && section == 1 { return "Stations" }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            searchResult = suggestions[indexPath.row]
        }
        if indexPath.section == 1 {
            searchResult = stations[indexPath.row]
        }
        endEditing()
    }
}
