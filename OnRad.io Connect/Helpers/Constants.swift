//
//  Constants.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/16/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

struct Constants {
    
    // MARK: - User defaults constants
    static let userDefaults = UserDefaults.standard
    static let userDefaultsDeviceName = "DeviceName"
    static let userDefaultsPhoneNumber = "PhoneNumber"
    static let userDefaultsDeviceKey = "DeviceKey"
    static let userDefaultsFirebaseUID = "FirebaseUID"
    static let userDefaultsFirebaseRegToken = "FirebaseRegToken"
    static let userDefaultsFirebaseToken = "FirebaseToken"
    static let userDefaultsGoogleEmail = "GoogleEmail"
    
    // MARK: - Controllers storyboard identifiers
    static let quizListViewController = "QuizListViewController"
    static let artworkViewController = "ArtworkViewController"
    static let gameViewController = "GameViewController"
    static let resultsViewController = "ResultsViewController"
    static let musicViewController = "MusicViewController"
    static let resultsDetailsViewController = "ResultsDetailsViewController"
    public static let searchViewController = "SearchViewController"
    
    // MARK: - Cells reusable identifiers
    static let outstandingConnectionsTableViewReuseIdentifier = "OutstandingConnectionCell"
    static let addressBookTableViewReusableIdentifier = "AddressBookCell"
    static let pipersTableViewReuseIdentifier = "PiperCell"
    static let requestTableViewReuseIdentifier = "RequestCell"
    static let baseSearchingReuseIdentifier = "BaseSearchingCell"
    static let recoSearchingReuseIdentifier = "RecoSearchingCell"
    
    // MARK: - Other
    static let bounds = UIScreen.main.bounds
    static let appName = "OnRad.io Connect"
    static let kRealmDBKey = "RealmDBKey"
    static let kRealmDBName = "RealmDBName"
    static let onradioArtwork = "http://dar.fm/images/onradio_500.png"
    static let somethingWentWrong = "Something went wrong, please try again"
    
    // MARK: - Special methods
    func initiateVCFromStoryboard(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: name)
    }
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(text.filter {okayChars.contains($0) })
    }
    
}
