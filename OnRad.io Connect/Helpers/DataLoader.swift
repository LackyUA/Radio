//
//  DataLoader.swift
//  OnRad.io Connect
//
//  Created by Igor on 6/28/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//


import Alamofire
import SwiftyJSON
import Firebase

class DataLoader {
    
    private static var manager = DataLoader().generateManager()
    
    func generateManager() -> SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Accept": "application/json",
                                               "Content-Type": "application/json"]
        let manager = Alamofire.SessionManager(configuration: configuration)
//        manager.retrier = DataLoaderRetrier()
        return manager
    }
    
    func sendMessage(deviceKey: String, event: String, completion: @escaping (_ result: Bool) -> Void) {
        DataLoader.manager.request(Router.sendMessage(deviceKey: deviceKey, event: event)).debugLog().validate().responseJSON { response in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func sendData(recepientRegToken: String, streamUrl: String, title: String, completion: @escaping (_ result: Bool) -> Void) {
        DataLoader.manager.request(Router.sendData(recepientRegToken: recepientRegToken, streamUrl: streamUrl, title: title)).debugLog().validate().responseJSON { response in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func sendVolume(recepientRegToken: String, volume: String, volumeUp: String, volumeDown: String, completion: @escaping (_ result: Bool) -> Void) {
        DataLoader.manager.request(Router.sendVolume(recepientRegToken: recepientRegToken, volume: volume, volumeUp: volumeUp, volumeDown: volumeDown)).debugLog().validate().responseJSON { response in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func sendDeviceInstance(regToken: String, deviceName: String, deviceKey: String, completion: @escaping (_ result: Bool) -> Void) {
        DataLoader.manager.request(Router.sendDeviceInstance(regToken: regToken, deviceName: deviceName, deviceKey: deviceKey)).debugLog().validate().responseJSON { response in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func deleteDeviceInstance(deviceKey: String, completion: @escaping (_ result: Bool) -> Void) {
        DataLoader.manager.request(Router.deleteDeviceInstance(deviceKey: deviceKey)).debugLog().validate().responseJSON { response in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func sendPong(completion: @escaping (_ result: Bool) -> Void) {
        DataLoader.manager.request(Router.sendPong()).debugLog().validate().responseJSON { response in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func getDeviceInstances(completion: @escaping (_ result: [Device]) -> Void) {
        var devices = [Device]()
        DataLoader.manager.request(Router.getDeviceInstances()).debugLog().validate().responseJSON { response in
            
            let json = JSON(response.result.value as Any)
            
            for (_, device):(String, JSON) in json["data"]["documents"][0] {
                var d = Device()
                d.deviceKey = device["device_key"].stringValue
                d.deviceName = device["device_name"].stringValue
                d.regToken = device["registration_id"].stringValue
                devices.append(d)
            }
            completion(devices)
        }
    }
    func loadTop150(completion: @escaping (_ result: [Song]) -> Void) {
        var songs = [Song]()
        
        DataLoader.manager.request(Router.loadTop150()).debugLog().validate().responseJSON { response in
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["result"] {
                var artist = song["songartist"].stringValue
                artist.removingBraces()
                var title = song["songtitle"].stringValue
                title.removingBraces()
                songs.append(Song(
                    artist: artist,
                    title: title,
                    streamUrl: song["uberurl"]["url"].string ?? "",
                    callsign: song["callsign"].string ?? "",
                    stationId: song["station_id"].int ?? 0,
                    secondsRemaining: song["playlist"]["seconds_remaining"].int ?? 0
                ))
            }
            var cleanSongs = [Song]()
            songs.forEach({ song in
                var occurances = cleanSongs.filter{ $0.title.removeSpecChars().lowercased() == song.title.removeSpecChars().lowercased() }.count
                let occ = cleanSongs.filter{ $0.title.removeSpecChars().lowercased().range(of: song.title.removeSpecChars().lowercased()) != nil }.count
                occurances += occ
                if occurances == 0 && song.title != "" {
                    cleanSongs.append(song)
                }
            })
            completion(cleanSongs)
        }
    }
    func getFirebaseRegToken(completion: @escaping (_ result: String) -> Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
                completion("")
            } else if let result = result {
                Constants.userDefaults.set(result.token, forKey: "FirebaseRegToken")
                Constants.userDefaults.synchronize()
                print("Remote instance ID token: \(result.token)")
                completion(result.token)
            }
        }
    }
    func getFirebaseToken(completion: @escaping (_ result: String) -> Void) {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDToken(completion: { (idToken, error) in
            if error != nil {
//              Handle error
//              completion(false)
                completion("")
                return
            }
            Constants.userDefaults.set(idToken!, forKey: "FirebaseToken")
            Constants.userDefaults.synchronize()
            print ("firebase token = \(idToken!)")
            completion(idToken!)
        })
    }
    func loadAutocompletion(query: String, completion: @escaping (_ result: [String]) -> Void) {
        DataLoader.manager.request(Router.loadAutocompletion(query: query)).responseJSON { response in
            let json = JSON(response.result.value as Any)
            let stringArr:[String] = json["result"].arrayValue.map { $0.stringValue}
            var cleanArr = [String]()
            stringArr.forEach({
                let cleanStr = Constants().removeSpecialCharsFromString(text: $0).condenseWhitespace()
                let occurances = cleanArr.filter{$0 == cleanStr }.count
                if occurances == 0 {
                    cleanArr.append(cleanStr)
                }
            })
            completion(cleanArr)
        }
    }
    func loadPlaylist(query: String, completion: @escaping (_ result: [Song]) -> Void) {
        var songs = [Song]()
        
        DataLoader.manager.request(Router.loadPlaylist(query: query)).responseJSON { response in
            let timestamp = Int(Date().timeIntervalSince1970)
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["result"] {
                var a = song["artist"].stringValue
                a.removingBraces()
                var t = song["title"].stringValue
                t.removingBraces()
                var s = Song(artist: a.condenseWhitespace(),
                             title: t.condenseWhitespace(),
                             band: song["band"].stringValue,
                             callsign: song["callsign"].stringValue,
                             stationId: song["station_id"].intValue,
                             secondsRemaining: song["seconds_remaining"].intValue)
                if s.secondsRemaining != 0 {
                    s.expiringTimestamp = s.secondsRemaining + timestamp
                }
                songs.append(s)
            }
            var cleanSongs = [Song]()
            songs.forEach({ song in
                var occurances = cleanSongs.filter{ $0.title.removeSpecChars().lowercased() == song.title.removeSpecChars().lowercased() }.count
                let occ = cleanSongs.filter{ $0.title.removeSpecChars().lowercased().range(of: song.title.removeSpecChars().lowercased()) != nil }.count
                occurances += occ
                if occurances == 0 && song.title != "" {
                    cleanSongs.append(song)
                }
            })
            cleanSongs.sort(by: { $0.secondsRemaining > $1.secondsRemaining })
            completion(cleanSongs)
        }
    }
    func search(type: SearchType, query: String, completion: @escaping (_ result: [Song]) -> Void) {
        var longQuery = ""
        switch type {
        case .artist:
            longQuery = "@artist *\(query)*"
        case .title:
            longQuery = "@title *\(query)*"
        case .callsign:
            longQuery = "@callsign *\(query)*"
        }
        let escapedQuery = longQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        var songs = [Song]()
        DataLoader.manager.request(Router.search(query: escapedQuery)).responseJSON { response in
            let timestamp = Int(Date().timeIntervalSince1970)
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["result"] {
                var s = Song(artist: song["artist"].stringValue,
                             title: song["title"].stringValue,
                             callsign: song["callsign"].stringValue,
                             stationId: song["station_id"].intValue,
                             secondsRemaining: song["seconds_remaining"].intValue)
                if s.secondsRemaining != 0 {
                    s.expiringTimestamp = s.secondsRemaining + timestamp
                }
                var occurances = 0
                var empty = false
                switch type {
                case .artist:
                    occurances = songs.filter{$0.artist == s.artist}.count
                    empty = s.artist == ""
                case .title:
                    occurances = songs.filter{$0.title == s.title}.count
                    empty = s.title == ""
                case .callsign:
                    occurances = songs.filter{$0.callsign == s.callsign}.count
                    empty = s.callsign == ""
                }
                if occurances == 0 && !empty {
                    songs.append(s)
                }
            }
            
            switch type {
            case .artist:
                songs.sort(by: { $0.artist < $1.artist })
            case .title:
                songs.sort(by: { $0.title < $1.title })
            case .callsign:
                songs.sort(by: { $0.callsign < $1.callsign })
            }
            completion(songs)
        }
    }
    func loadOnline(query: String, completion: @escaping (_ result: [Song]) -> Void) {
        var songs = [Song]()
        
        DataLoader.manager.request(Router.loadOnline(query: query)).responseJSON { response in
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["songmatch"] {
                let s = Song(artist: song["artist"].stringValue,
                             title: song["title"].stringValue)
                songs.append(s)
            }
            completion(songs)
        }
    }
    func loadArt(artist: String, title: String, completion: @escaping (_ result: String) -> Void) {
        DataLoader.manager.request(Router.loadArt(artist: artist, title: title)).responseJSON { response in
            let json = JSON(response.result.value as Any)
            var url = json["result"][0]["arturl"].stringValue
            if !url.hasPrefix("http") {
                url = Constants.onradioArtwork
            }
            completion(url)
        }
    }
    func loadStationArt(stationId: Int, completion: @escaping (_ result: String) -> Void) {
        DataLoader.manager.request(Router.loadStationInfo(stationId: stationId)).responseJSON { response in
            let json = JSON(response.result.value as Any)
            var url = json["result"][0]["stations"][0]["imageurl"].stringValue
            if !url.hasPrefix("http") {
                url = Constants.onradioArtwork
            }
            completion(url)
        }
    }
    func loadAllSongs(artist: String, completion: @escaping (_ result: [Song]) -> Void) {
        var songs = [Song]()
        
        DataLoader.manager.request(Router.loadAllSongs(artist: artist)).responseJSON { response in
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["songmatch"] {
                let s = Song(artist: song["artist"].stringValue,
                             title: Constants().removeSpecialCharsFromString(text: song["title"].stringValue))
                songs.append(s)
            }
            var cleanSongs = [Song]()
            songs.forEach({ song in
                let occurances = cleanSongs.filter{$0.title == song.title }.count
                if occurances == 0 && song.title != "" {
                    cleanSongs.append(song)
                }
            })
            cleanSongs.sort(by: {$0.title < $1.title })
            completion(cleanSongs)
        }
    }
    func loadNowOnStation(stationId: Int, completion: @escaping (_ result: [Song]) -> Void) {
        var songs = [Song]()
        
        DataLoader.manager.request(Router.nowOnStation(stationId: stationId)).responseJSON { response in
            let timestamp = Int(Date().timeIntervalSince1970)
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["result"] {
                var s = Song(artist: song["artist"].stringValue,
                             title: song["title"].stringValue,
                             band: song["band"].stringValue,
                             callsign: song["callsign"].stringValue,
                             stationId: song["station_id"].intValue,
                             secondsRemaining: song["seconds_remaining"].intValue)
                if s.secondsRemaining != 0 {
                    s.expiringTimestamp = s.secondsRemaining + timestamp
                }
                songs.append(s)
            }
            completion(songs)
        }
    }
    func getStreamForStationId(stationId: Int, completion: @escaping (_ result: String) -> Void) {
        completion("http://stream.dar.fm/\(stationId)")
    }
    func loadReco2(artist: String, completion: @escaping (_ result: [Song]) -> Void) {
        var songs = [Song]()
        
        DataLoader.manager.request(Router.loadReco2(artist: artist)).responseJSON { response in
            let timestamp = Int(Date().timeIntervalSince1970)
            let json = JSON(response.result.value as Any)
            
            for (_, song):(String, JSON) in json["result"] {
                
                var s = Song(artist: song["songartist"].stringValue,
                             title: song["songtitle"].stringValue,
                             band: song["band"].stringValue,
                             streamUrl: song["uberurl"]["url"].stringValue,
                             callsign: song["uberurl"]["callsign"].stringValue,
                             stationId: song["uberurl"]["station_id"].intValue,
                             secondsRemaining: song["playlist"]["seconds_remaining"].intValue)
                if s.secondsRemaining != 0 {
                    s.expiringTimestamp = s.secondsRemaining + timestamp
                }
                songs.append(s)
            }
            completion(songs)
        }
    }
    
//    func loadAutocompletion(query: String, completion: @escaping (_ result: [SearchResult]) -> Void) {
//
//        let escapedQuery = "*\(query)*"//query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
////        escapedQuery = "*\(escapedQuery)*"
//
//        DataLoader.manager.request(Router.loadAutocompletion(query: escapedQuery)).responseJSON { response in
//
//            let json = JSON(response.result.value as Any)
//
//            let stringArr:[String] = json["result"].arrayValue.map { $0.stringValue}
//
//            var cleanArr = [SearchResult]()
//            stringArr.forEach({
//                let cleanStr = SearchResult(name: $0, stationId: 0) //Constants().removeSpecialCharsFromString(text: $0)
//
//                let occurances = cleanArr.filter{$0.name == cleanStr.name }.count
//                if occurances == 0 {
//
//                    cleanArr.append(cleanStr)
//
//                }
//            })
//
//            cleanArr.sort(by: {$0.name < $1.name })
//
//            completion(cleanArr)
//        }
//    }
//
//    func loadStations(query: String, completion: @escaping (_ result: [SearchResult]) -> Void) {
//
//        let escapedQuery = "@callsign ^\(query)*"//query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
//        //        escapedQuery = "*\(escapedQuery)*"
//
//        DataLoader.sharedManager.request(Router.loadStationsAutocompletion(callsign: escapedQuery)).responseJSON { response in
//
//            let json = JSON(response.result.value as Any)
//
////            let stringArr:[String] = json["result"].arrayValue.map { $0.stringValue}
//
//            var cleanArr = [SearchResult]()
//            for (_, station):(String, JSON) in json["result"] {
//                let cleanStr = SearchResult(name: station["callsign"].stringValue, stationId: station["station_id"].intValue)
//                let occurances = cleanArr.filter{$0.name == cleanStr.name }.count
//                if occurances == 0 {
//
//                    cleanArr.append(cleanStr)
//
//                }
//            }
////            stringArr.forEach({
////                let cleanStr = $0[""].st//Constants().removeSpecialCharsFromString(text: $0)
////
////                let occurances = cleanArr.filter{$0 == cleanStr }.count
////                if occurances == 0 {
////
////                    cleanArr.append(cleanStr)
////
////                }
////            })
//
//            cleanArr.sort(by: {$0.name < $1.name })
//
//            completion(cleanArr)
//        }
//    }
//
//
//    func loadPlaylist(query: String, completion: @escaping (_ result: [Song]) -> Void) {
//
//        var songs = [Song]()
//
//        DataLoader.sharedManager.request(Router.loadPlaylist(query: query)).responseJSON { response in
//
//            let timestamp = Int(Date().timeIntervalSince1970)
//            let json = JSON(response.result.value as Any)
//
//            for (_, song):(String, JSON) in json["result"] {
//
//                var s = Song(artist: song["artist"].stringValue,
//                             title: song["title"].stringValue,
//                             band: song["band"].stringValue,
//                             streamUrl: "",
//                             callsign: song["callsign"].stringValue,
//                             stationId: song["station_id"].intValue,
//                             secondsRemaining: song["seconds_remaining"].intValue)
//
//                if s.secondsRemaining != 0 {
//                    s.expiringTimestamp = s.secondsRemaining + timestamp
//                }
//
//                songs.append(s)
//            }
//
//
//            var cleanSongs = [Song]()
//            songs.forEach({ song in
//
//                let occurances = cleanSongs.filter{$0.title == song.title }.count
//                if occurances == 0 && song.title != "" {
//
//                    cleanSongs.append(song)
//
//                }
//            })
//
//            cleanSongs.sort(by: {$0.title < $1.title })
//
//            completion(cleanSongs)
//        }
//    }
    
}

//class DataLoaderRetrier: RequestAdapter, RequestRetrier {
//
//    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//        return urlRequest
//    }
//
//    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
//
//        guard request.retryCount == 0 else { return completion(false, 0) }
//
//        if let response = request.task?.response as? HTTPURLResponse, response.statusCode != 200 {
//
//            DataLoader().getFirebaseToken({ success in
//                completion(true, 0)
//            })
//
//        } else {
//            completion(false, 0.0)
//        }
//    }
//}
