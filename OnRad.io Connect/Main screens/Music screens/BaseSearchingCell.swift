//
//  BaseSearchingCell.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/10/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class BaseSearchingCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var index = (section: 0, row: 0)
    
    // MARK: - Life circle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.textColor = UIColor(hex: "314076")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        artworkView.image = UIImage(named: "song-placeholder")
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Configure cell
    func configure(title: String) {
        titleLabel.text = title
    }

}
