//
//  RecoSearchingCell.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/10/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class RecoSearchingCell: BaseSearchingCell {

    // MARK: - Outlets
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var callsignLabel: UILabel!
    
    // MARK: - Life circle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        artistLabel.textColor = UIColor(hex: "314076")
        callsignLabel.textColor = UIColor.darkGray
    }
    
    // MARK: - Configure cell
    func configure(song: Song) {
        titleLabel.text = song.title
        artistLabel.text = song.artist
        callsignLabel.text = song.callsign
    }

}
