//
//  PiperCell.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/2/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class PiperCell: UITableViewCell {
    
    //MARK: - Properies
    weak var delegate: PipeTableViewCellDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sendStatus: UILabel!
    @IBOutlet weak var receiveStatus: UILabel!
    @IBOutlet weak var dumpButton: UIButton!
    
    // MARK: - Actions
    @IBAction func dumpButtonTapped(_ sender: Any) {
        delegate?.dumpPiper(self)
    }
    
    // MARK: - Configuring cell
    func configureCell(piper: Piper) {
        configureDumpButton()
        nameLabel.text = piper.name
        sendStatus.text = (piper.isSending ? "x" : " ")
        receiveStatus.text = (piper.isReceiving ? "x" : " ")
    }
    private func configureDumpButton() {
        dumpButton.layer.masksToBounds = true
        dumpButton.layer.cornerRadius = dumpButton.frame.height / 2
    }

}
