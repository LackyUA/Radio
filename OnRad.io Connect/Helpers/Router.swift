//
//  Router.swift
//  OnRad.io Connect
//
//  Created by Igor on 6/28/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Alamofire

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint(self)
        #endif
        return self
    }
}

enum Router: URLRequestConvertible {
    
    case sendData(recepientRegToken: String, streamUrl: String, title: String)
    case sendMessage(deviceKey: String, event: String)
    case sendPong()
    case sendVolume(recepientRegToken: String, volume: String, volumeUp: String, volumeDown: String)
    case sendDeviceInstance(regToken: String, deviceName: String, deviceKey: String)
    case deleteDeviceInstance(deviceKey: String)
    case getDeviceInstances()
    
    case loadAllSongs(artist: String)
    case loadReco2(artist: String)
    case loadAutocompletion(query: String)
    case loadStationInfo(stationId: Int)
    case loadStationsAutocompletion(callsign: String)
    case loadPlaylist(query: String)
    case search(query: String)
    case loadArt(artist: String, title: String)
    case loadOnline(query: String)
    case nowOnStation(stationId: Int)
    case loadTop150()
    
    static let ocURLString = "https://fcoins.org/api/v1"
    static let baseURLString = "http://api.dar.fm"
    var method: HTTPMethod {
        switch self {
        case .sendData, .sendVolume, .sendMessage, .sendDeviceInstance, .deleteDeviceInstance, .sendPong:
            return .post
        case .getDeviceInstances, .loadAutocompletion, .loadStationsAutocompletion, .loadPlaylist, .loadArt, .loadOnline, .search, .loadStationInfo, .loadAllSongs, .loadReco2, .nowOnStation, .loadTop150:
            return .get
        }
        
    }
    var path: String {
        switch self {
        case .loadAutocompletion:
            return "/songartist.php"
        case .loadStationInfo, .loadStationsAutocompletion:
            return "/darstations.php"
        case .loadPlaylist, .search, .nowOnStation:
            return "/playlist.php"
        case .loadAllSongs:
            return "/allsongs.php"
            
            
        case .loadOnline:
            return "/onradio.php"
        case .loadArt:
            return "/songart.php"
        case .sendData:
            return "/data"
        case .loadReco2:
            return "/reco2.php"
        case .sendMessage:
            return "/send_message"
        case .sendVolume:
            return "/volume"
        case .getDeviceInstances, .sendDeviceInstance:
            return "/device_instance"
        case .deleteDeviceInstance:
            return "/device_instance"
        case .sendPong():
            return "/update_device"
        case .loadTop150:
            return "/topsongs.php"
        }
    }
    var parameters: [String: Any]? {
        switch self {
            
        case .loadPlaylist(let query), .search(let query), .loadOnline(let query):
            return ["q" : query]
        case .loadAutocompletion(let query):
            return ["q" : query,
                    "search_index" : "songlist_artist_index2"]
        case .loadStationsAutocompletion(let callsign):
            return ["q" : callsign]
    
        case .loadAllSongs(let artist):
            return ["artist" : artist]
        case .loadStationInfo(let stationId):
            return ["station_id" : stationId]
            
        case .loadArt(let artist, let title):
            return ["res" : "mid",
                    "artist" : artist,
                    "title" : title]
            
        case .nowOnStation(let stationId):
            return ["station_id" : stationId]
        case .sendData(let recepientRegToken, let streamUrl, let title):
            return ["registration_id" : recepientRegToken,
                    "stream" : streamUrl,
                    "title" : title]
        case .sendMessage(let deviceKey, let event):
            return ["data" : ["deviceKey" : deviceKey,
                              "event" : event]]
        case .sendVolume(let recepientRegToken, let volume, let volumeUp, let volumeDown):
            var title = ""
            if volume == "mute" {
                title = "Playback stopped received"
            } else {
                if volumeUp == "1" {
                    title = "Volume up command received"
                }
                if volumeDown == "1" {
                    title = "Volume down command received"
                }
            }
            return ["registration_id" : recepientRegToken,
                    "volume" : volume,
                    "volume_up" : volumeUp,
                    "volume_down" : volumeDown,
                    "title" : title]
        case .sendDeviceInstance(let regToken, let deviceName, let deviceKey):
            return ["registration_id" : regToken,
                    "device_name" : deviceName,
                    "device_key" : deviceKey]
        case .deleteDeviceInstance(let deviceKey):
            return ["device_key" : deviceKey]
        case .getDeviceInstances():
            return [:]
        case .loadReco2(let artist):
            return ["artist" : artist]
        case .sendPong():
            var uuid = ""
            if let deviceKey = Constants.userDefaults.string(forKey: Constants.userDefaultsDeviceKey) {
                uuid = deviceKey;
            }
            return ["device_key" : uuid]
        case .loadTop150():
            return [:]
        }
        
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        var url: URL
        var params = [String : Any]()
        var urlRequest: URLRequest
        
        switch self {
        case .sendData, .sendVolume, .sendMessage, .sendDeviceInstance, .deleteDeviceInstance, .sendPong():
            url = try Router.ocURLString.asURL()
            urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            let id = Constants.userDefaults.object(forKey: Constants.userDefaultsFirebaseToken) as! String
            params["id"] = id
            parameters?.forEach { params[$0] = $1 }
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            urlRequest.httpBody = jsonData
            
            return urlRequest
    case .loadAutocompletion, .loadStationsAutocompletion, .loadPlaylist, .search, .loadArt, .loadOnline, .loadStationInfo, .loadAllSongs, .loadReco2, .nowOnStation:
            url = try Router.baseURLString.asURL()
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            var params: [String : Any] = ["callback" : "json",
                                          "partner_token" : "5277783314"]
            parameters?.forEach { params[$0] = $1 }
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
            
            return urlRequest
            
        case .getDeviceInstances():
            url = try Router.ocURLString.asURL()
            urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            let id = Constants.userDefaults.object(forKey: "FirebaseToken") as! String
            params["id"] = id
            parameters?.forEach { params[$0] = $1 }
            
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
            return urlRequest
            
        case .loadTop150:
            url = try Router.baseURLString.asURL()
            
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            var params: [String : Any] = ["q" : "Music",
                                          "page_size" : "150",
                                          "nonplaying" : "1",
                                          "callback" : "json",
                                          "partner_token" : "5277783314"]
            parameters?.forEach { params[$0] = $1 }
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
            
            return urlRequest
        }
    }
}
