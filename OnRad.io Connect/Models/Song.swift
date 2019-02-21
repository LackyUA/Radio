//
//  Song.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/11/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Foundation

struct Song {
    
    // MARK: - Properties
    var artist: String
    var title: String
    var band: String
    var streamUrl: String
    var artUrl: String
    var callsign: String
    var stationId: Int
    var secondsRemaining: Int
    var expiringTimestamp: Int
    
    // MARK: - Initializers
    init(artist: String = "",
         title: String = "",
         band: String = "",
         streamUrl: String = "",
         artUrl: String = "",
         callsign: String = "",
         stationId: Int = 0,
         secondsRemaining: Int = 0,
         expiringTimestamp: Int = 0) {
        self.artist = artist
        self.title = title
        self.band = band
        self.streamUrl = streamUrl
        self.artUrl = artUrl
        self.callsign = callsign
        self.stationId = stationId
        self.secondsRemaining = secondsRemaining
        self.expiringTimestamp = expiringTimestamp
    }
    
}
