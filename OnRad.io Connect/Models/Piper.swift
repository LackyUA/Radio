//
//  Pipers.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/11/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Foundation

struct Piper {
    
    // MARK: - Properties
    var name: String
    var isSelected: Bool
    var isSending: Bool
    var isReceiving: Bool
    
    // MARK: - Initializations
    init(name: String, isSelected: Bool = false, isSending: Bool = false, isReceiving: Bool = false) {
        self.name = name
        self.isSelected = isSelected
        self.isSending = isSending
        self.isReceiving = isReceiving
    }
    
}
