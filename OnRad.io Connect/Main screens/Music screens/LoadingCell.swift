//
//  LoadingCell.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/10/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life circle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityIndicator.startAnimating()
    }

}
