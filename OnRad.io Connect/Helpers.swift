//
//  Helpers.swift
//  OnRad.io Connect
//
//  Created by Igor on 6/20/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit

struct SearchResult {
    var name: String
    var streamUrl: String
    
    init(name: String = "",
         streamUrl: String = "") {
        self.name = name
        self.streamUrl = streamUrl
    }
}

enum SearchType {
    case artist
    case title
    case callsign
}

class PintVC : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hex: "eef1ef")
        title = ""
        
//        if !self.isKind(of: SearchViewController.self) {
//            let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(PintVC.searchButtonTapped))
//            self.navigationItem.setRightBarButton(searchButton, animated: false)
//        }
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //        if !self.isKind(of: PlayerViewController.self) {
    //
    //            if PlayerManager.shared.currentSong.artist != "" && !PlayerManager.shared.miniPlayerVisible {
    //                let nc = self.navigationController as! PintNC
    //                nc.showMiniPlayer()
    //            }
    //        } else {
    //            if PlayerManager.shared.currentSong.artist != "" && PlayerManager.shared.miniPlayerVisible {
    //                let nc = self.navigationController as! PintNC
    //                nc.hideMiniPlayer()
    //            }
    //        }
    //    }
    
    @objc func searchButtonTapped() {
        print("search")
        let searchVC = Constants().initiateVCFromStoryboard(name: Constants.searchViewController)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}
