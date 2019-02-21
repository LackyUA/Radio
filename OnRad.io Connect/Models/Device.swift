//
//  Device.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/17/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Foundation

struct Device {
    var deviceName: String
    var deviceKey: String
    var regToken: String
    
    init(deviceName: String = "",
         deviceKey: String = "",
         regToken: String = "") {
        self.deviceName = deviceName
        self.deviceKey = deviceKey
        self.regToken = regToken
    }
}
