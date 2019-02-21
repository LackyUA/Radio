//
//  AddressBookUser.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/11/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Foundation

struct AddressBookUser {
    
    // MARK: - Properties
    var name: String
    var phoneNumber: String
    var isSelected: Bool
    
    // MARK: - Initializers
    init(name: String, phoneNumber: String, isSelected: Bool = false) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.isSelected = isSelected
    }
    
}
