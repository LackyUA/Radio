//
//  RequestCell.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/2/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {
    
    //MARK: - Properies
    weak var delegate: PipeTableViewCellDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var collectionOfButtons: [UIButton]!
    
    // MARK: - Actions
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        
    }
    @IBAction func dumpButtonTapped(_ sender: UIButton) {
        delegate?.dumpRequest(self)
    }
    
    // MARK: - Configuring cell
    func configureCell(name: String) {
        configureButtons()
        nameLabel.text = name
    }
    private func configureButtons() {
        for button in collectionOfButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.height / 2
        }
    }

}
