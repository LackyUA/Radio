//
//  Player.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/15/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import Foundation
import StreamingKit
import AVFoundation

final class AudioPlayer: NSObject {
    
    // MARK: - Properties
    private var player: STKAudioPlayer!
    private var playerIsPlaying = false
    
    // MARK: - Player methods
    func initPlayer() {
        player = STKAudioPlayer()
        player.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayer), name: NSNotification.Name("stopPlayer"), object: nil)
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setMode(AVAudioSessionModeDefault)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        // Start streaming
        startStream(userInfo: userInfo)
        
        // Check ping
        checkPing(userInfo: userInfo)
        
        // Volume value change
        changeVolumeValue(userInfo: userInfo)
    }
    @objc func stopPlayer() {
        playerIsPlaying = false
        player.stop()
    }
    func previewButtonTapped(url: String) -> String {
        switch playerIsPlaying {
        case true:
            player.stop()
            playerIsPlaying = !playerIsPlaying
            return "play.png"
        case false:
            player.play(url)
            playerIsPlaying = !playerIsPlaying
            return "pause.png"
        }
    }
    private func startStream(userInfo: [AnyHashable: Any]) {
        if let stream = userInfo["stream"] {
            let url = String(describing: stream).components(separatedBy: "|||||")[0]
            let title = String(describing: stream).components(separatedBy: "|||||")[1]
            if url != "" {
                playSong(url: url, title: title)
            }
        }
    }
    private func checkPing(userInfo: [AnyHashable: Any]) {
        if userInfo["ping"] != nil {
            playSong(url: "ping", title: "")
        }
    }
    private func changeVolumeValue(userInfo: [AnyHashable: Any]) {
        if let volume = userInfo["volume"] {
            let mute = String(describing: volume)
            if mute == "mute" {
                playSong(url: "stop", title: "")
            }
            if mute == "on" {
                let volUp = String(describing: userInfo["volume_up"]!)
                let volDown = String(describing: userInfo["volume_down"]!)
                if volUp == "1" {
                    playSong(url: "volUp", title: "")
                }
                if volDown == "1" {
                    playSong(url: "volDown", title: "")
                }
            }
        }
    }
    private func playSong(url: String, title: String) {
        if url == "stop" {
            player.stop()
            NotificationCenter.default.post(name: NSNotification.Name("playPlayer"), object: nil, userInfo: ["stop": "stop"])
            return
        }
        if url == "volUp" {
            NotificationCenter.default.post(name: NSNotification.Name("playPlayer"), object: nil, userInfo: ["volUp": "volUp"])
            return
        }
        if url == "volDown" {
            NotificationCenter.default.post(name: NSNotification.Name("playPlayer"), object: nil, userInfo: ["volDown": "volDown"])
            return
        }
        if url == "ping" {
            AppData.shared.getFirebaseToken(completion: { token in
                AppData.shared.sendPong(completion: { success in
                    print ("pong sent")
                })
            })
            return
        }
        
        player.stop()
        player.play(url)
        NotificationCenter.default.post(name: NSNotification.Name("playPlayer"), object: nil, userInfo: ["stream": title])
    }
    
}

// MARK: - STK audio player delegation
extension AudioPlayer: STKAudioPlayerDelegate {
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
    }

}
