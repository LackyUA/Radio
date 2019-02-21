//
//  AppData.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/15/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Foundation

final class AppData {
    
    // MARK: - Singleton init
    static let shared = AppData()
    private init(){}
    
    // MARK: - Cascade inits
    private let player = AudioPlayer()
    private let dateLoader = DataLoader()
    
    // MARK: - AudioPlayer methods
    func initPlayer() {
        player.initPlayer()
    }
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        player.didReceiveRemoteNotification(userInfo: userInfo)
    }
    @objc func stopPlayer() {
        player.stopPlayer()
    }
    func previewButtonTapped(url: String) -> String {
        return player.previewButtonTapped(url: url)
    }
    
    // MARK: - DataLoader methods
    func sendMessage(deviceKey: String, event: String, completion: @escaping (_ result: Bool) -> Void) {
        dateLoader.sendMessage(deviceKey: deviceKey, event: event, completion: completion)
    }
    func sendData(recepientRegToken: String, streamUrl: String, title: String, completion: @escaping (_ result: Bool) -> Void) {
        dateLoader.sendData(recepientRegToken: recepientRegToken, streamUrl: streamUrl, title: title, completion: completion)
    }
    func sendVolume(recepientRegToken: String, volume: String, volumeUp: String, volumeDown: String, completion: @escaping (_ result: Bool) -> Void) {
        dateLoader.sendVolume(recepientRegToken: recepientRegToken, volume: volume, volumeUp: volumeUp, volumeDown: volumeDown, completion: completion)
    }
    func sendDeviceInstance(regToken: String, deviceName: String, deviceKey: String, completion: @escaping (_ result: Bool) -> Void) {
        dateLoader.sendDeviceInstance(regToken: regToken, deviceName: deviceName, deviceKey: deviceKey, completion: completion)
    }
    func deleteDeviceInstance(deviceKey: String, completion: @escaping (_ result: Bool) -> Void) {
        dateLoader.deleteDeviceInstance(deviceKey: deviceKey, completion: completion)
    }
    func sendPong(completion: @escaping (_ result: Bool) -> Void) {
        dateLoader.sendPong(completion: completion)
    }
    func getDeviceInstances(completion: @escaping (_ result: [Device]) -> Void) {
        dateLoader.getDeviceInstances(completion: completion)
    }
    func loadTop150(completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.loadTop150(completion: completion)
    }
    func getFirebaseRegToken(completion: @escaping (_ result: String) -> Void) {
        dateLoader.getFirebaseRegToken(completion: completion)
    }
    func getFirebaseToken(completion: @escaping (_ result: String) -> Void) {
        dateLoader.getFirebaseToken(completion: completion)
    }
    func loadAutocompletion(query: String, completion: @escaping (_ result: [String]) -> Void) {
        dateLoader.loadAutocompletion(query: query, completion: completion)
    }
    func loadPlaylist(query: String, completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.loadPlaylist(query: query, completion: completion)
    }
    func search(type: SearchType, query: String, completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.search(type: type, query: query, completion: completion)
    }
    func loadOnline(query: String, completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.loadOnline(query: query, completion: completion)
    }
    func loadArt(artist: String, title: String, completion: @escaping (_ result: String) -> Void) {
        dateLoader.loadArt(artist: artist, title: title, completion: completion)
    }
    func loadStationArt(stationId: Int, completion: @escaping (_ result: String) -> Void) {
        dateLoader.loadStationArt(stationId: stationId, completion: completion)
    }
    func loadAllSongs(artist: String, completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.loadAllSongs(artist: artist, completion: completion)
    }
    func loadNowOnStation(stationId: Int, completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.loadNowOnStation(stationId: stationId, completion: completion)
    }
    func getStreamForStationId(stationId: Int, completion: @escaping (_ result: String) -> Void) {
        dateLoader.getStreamForStationId(stationId: stationId, completion: completion)
    }
    func loadReco2(artist: String, completion: @escaping (_ result: [Song]) -> Void) {
        dateLoader.loadReco2(artist: artist, completion: completion)
    }
    
}
