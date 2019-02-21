//
//  SearchViewController.swift
//  Pint
//
//  Created by Igor Zhariy on 1/16/18.
//  Copyright © 2018 Igor Zhariy. All rights reserved.
//

import UIKit
import Kingfisher

class SearchViewController: PintVC {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var searchTableViewBottomConstraint: NSLayoutConstraint!
    
    var loadingOptions: KingfisherOptionsInfo = [.forceTransition, .transition(.fade(1.0))]
    
    var sections = 5
    var itemsPerSection = 100
    var loadedResults = 0
    var loadedMatchResults = 0
    let defaultHeight = CGFloat(80.0)
    let headerHeight = CGFloat(30.0)
    var imageList = [[String]]()
    var timer: Timer?
    var musicSongs = [String]()
    var callsignSongs = [Song]()
    var searchQuery = ""
    var artist = ""
    var recommendation = ""
    var artistSongsOn = [Song]()
    var artistSongsOff = [Song]()
    var artistSongsAll = [Song]()
    var recoSongs = [Song]()
    var loadingResult = false
    var mainVC: ViewController?
    var searchResult: SearchResult?
    
    var lastTappedCell: IndexPath?
    
    // Section 0 - title and artists from songartist.php (autocomplete) that match *query*
    // Section 1 - stations from playlist.php that match @callsign query
    // Section 2 - Online songs from artist if tapped on him on section 0
    // Section 4 - Offline songs from artist if tapped on him on section 0
    // Section 3 - Recommendations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.tableFooterView = UIView(frame: CGRect.zero)
        searchTableView.rowHeight = defaultHeight
        
        searchTextField.delegate = self
        searchTextField.textColor = UIColor(hex: "314076")
        
        searchTextField.becomeFirstResponder()
        
        imageList = Array(repeating: Array(repeating: "", count: itemsPerSection), count: sections)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        var additionalHeight = CGFloat(0.0)
//        if UIDevice().userInterfaceIdiom == .phone {
//            if UIScreen.main.nativeBounds.height == 2436 {
//                additionalHeight = 34
//            }
//        }
        
        searchTableViewBottomConstraint.constant = 0//PlayerManager.shared.miniPlayerVisible ? Constants.miniPlayerSize.height - additionalHeight : 0
        
    }
    
    func stopSpinner() {
        if lastTappedCell != nil && !loadingResult && searchTableView.cellForRow(at: lastTappedCell!) != nil {
            let cell = searchTableView.cellForRow(at: lastTappedCell!) as! BaseSearchCell
            cell.activityIndicator.stopAnimating()
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        
        if self.searchResult != nil {
            mainVC?.searchResult = self.searchResult
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        searchQuery = Constants().removeSpecialCharsFromString(text: searchTextField.text!)
        if searchQuery == "" {
            loadingResult = false
            removeAll()
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SearchViewController.getSearchResults), userInfo: nil, repeats: false)
        }
    }
    
    @objc func getSearchResults() {
        
        loadingResult = true
        removeAll()
        AppData.shared.loadAutocompletion(query: "*\(searchQuery)*", completion: { music in
            self.musicSongs = music
            self.loadedResults += 1
            self.checkIfGotAllResults()
        })
        AppData.shared.search(type: .callsign, query: searchQuery, completion: { songs in
            self.callsignSongs = songs
            self.loadedResults += 1
            self.checkIfGotAllResults()
        })
    }
    
    func removeAll() {
        loadedResults = 0
        loadedMatchResults = 0
        self.musicSongs.removeAll()
        self.callsignSongs.removeAll()
        self.artistSongsOn.removeAll()
        self.artistSongsOff.removeAll()
        self.artistSongsAll.removeAll()
        self.recoSongs.removeAll()
        self.artist = ""
        self.recommendation = ""
        self.searchTableView.separatorStyle = .none
        self.searchTableView.reloadData()
    }
    
    func checkIfGotAllResults() {
        if loadedResults == 2 {
            self.loadingResult = false
            self.searchTableView.separatorStyle = .singleLine
            self.searchTableView.reloadData()
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return loadedResults == 0 ? 1 : 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !loadingResult else { return 1 }
        
        switch section {
        case 0:
            return musicSongs.count
        case 1:
            return callsignSongs.count
        case 2:
            return artistSongsOn.count
        case 3:
            return recoSongs.count
        case 4:
            return artistSongsOff.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !loadingResult else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingSearchCell", for: indexPath) as! LoadingSearchCell
            cell.selectionStyle = .none
            return cell
        }
        
        if indexPath.section != 3 {
            // sections 0,1,2,3
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! BaseSearchCell
            cell.selectionStyle = .none
            
            if imageList[indexPath.section][indexPath.row] == "" || imageList[indexPath.section][indexPath.row] == Constants.onradioArtwork {
                if indexPath.section == 0 {
                    AppData.shared.loadOnline(query: musicSongs[indexPath.row], completion: { songs in
                        if songs.count != 0 {
                            self.loadArtFor(artist: songs[0].artist, title: songs[0].title, cell: cell)
                        }
                    })
                }
                if indexPath.section == 1 {
                    AppData.shared.loadStationArt(stationId: callsignSongs[indexPath.row].stationId, completion: { artUrl in
                        self.imageList[cell.index.section][cell.index.row] = artUrl
                        guard artUrl != Constants.onradioArtwork else { return }
                        let url = URL(string: artUrl)
                        let placeholder = UIImage(named: "song-placeholder")
                        cell.artworkView.kf.setImage(with: url, placeholder: placeholder, options: self.loadingOptions, completionHandler: {
                            (image, error, cacheType, imageUrl) in
                            if error != nil {
                                print ("Error")
                                self.imageList[cell.index.section][cell.index.row] = Constants.onradioArtwork
                            }
                        })
                    })
                }
                if indexPath.section == 2 {
                    self.loadArtFor(artist: artistSongsOn[indexPath.row].artist, title: artistSongsOn[indexPath.row].title, cell: cell)
                }
                if indexPath.section == 4 {
                    self.loadArtFor(artist: artistSongsOff[indexPath.row].artist, title: artistSongsOff[indexPath.row].title, cell: cell)
                }
            } else {
                let artUrl = imageList[indexPath.section][indexPath.row]
                if artUrl != Constants.onradioArtwork {
                    let url = URL(string: artUrl)
                    let placeholder = UIImage(named: "song-placeholder")
                    cell.artworkView.kf.setImage(with: url, placeholder: placeholder, options: self.loadingOptions, completionHandler: { _, _, _, _ in
                    })
                }
            }
            
            
            
            
            switch indexPath.section {
            case 0:
                cell.titleLabel.text = musicSongs[indexPath.row]
            case 1:
                cell.titleLabel.text = callsignSongs[indexPath.row].callsign
            case 2:
                cell.titleLabel.text = artistSongsOn[indexPath.row].title
            case 4:
                cell.titleLabel.text = artistSongsOff[indexPath.row].title
            default:
                break
            }
            
            return cell
            
        } else {
            
            
            // section 3
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchRecoCell", for: indexPath) as! SearchRecoCell
            cell.selectionStyle = .none
            
            if imageList[indexPath.section][indexPath.row] == "" || imageList[indexPath.section][indexPath.row] == Constants.onradioArtwork {
                if indexPath.section == 4 {
                    self.loadArtFor2(artist: recoSongs[indexPath.row].artist, title: recoSongs[indexPath.row].title, cell: cell)
                }
            } else {
                let artUrl = imageList[indexPath.section][indexPath.row]
                if artUrl != Constants.onradioArtwork {
                    let url = URL(string: artUrl)
                    let placeholder = UIImage(named: "song-placeholder")
                    cell.artworkView.kf.setImage(with: url, placeholder: placeholder, options: self.loadingOptions, completionHandler: { _, _, _, _ in
                    })
                }
            }
            
            
                cell.titleLabel.text = recoSongs[indexPath.row].title
                cell.artistLabel.text = recoSongs[indexPath.row].artist
                cell.callsignLabel.text = recoSongs[indexPath.row].callsign
            return cell
        }
        
        
    }
    
    
    func loadArtFor(artist: String, title: String, cell: BaseSearchCell) {
        AppData.shared.loadArt(artist: artist, title: title, completion: { artUrl in
            self.imageList[cell.index.section][cell.index.row] = artUrl
            
            guard artUrl != Constants.onradioArtwork else { return }
            let url = URL(string: artUrl)
            let placeholder = UIImage(named: "song-placeholder")
            cell.artworkView.kf.setImage(with: url, placeholder: placeholder, options: self.loadingOptions, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if error != nil {
                    print ("Error")
                    self.imageList[cell.index.section][cell.index.row] = Constants.onradioArtwork
                }
            })
        })
    }
    
    func loadArtFor2(artist: String, title: String, cell: SearchRecoCell) {
        AppData.shared.loadArt(artist: artist, title: title, completion: { artUrl in
            self.imageList[cell.index.section][cell.index.row] = artUrl
            
            guard artUrl != Constants.onradioArtwork else { return }
            let url = URL(string: artUrl)
            let placeholder = UIImage(named: "song-placeholder")
            cell.artworkView.kf.setImage(with: url, placeholder: placeholder, options: self.loadingOptions, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if error != nil {
                    print ("Error")
                    self.imageList[cell.index.section][cell.index.row] = Constants.onradioArtwork
                }
            })
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: headerHeight))
        view.backgroundColor = UIColor(hex: "d9d9d9")
        
        let label = UILabel(frame: view.frame)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textColor = UIColor(hex: "314076")
        switch section {
        case 0:
            label.text = "Music"
        case 1:
            label.text = "Stations"
        case 2:
            label.text = "\(artist) songs on right now"
        case 3:
            label.text = "\(recommendation)"
        case 4:
            label.text = "\(artist) songs on soon"
        default:
            label.text = ""
        }
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !loadingResult else { return 0 }
        
        switch section {
        case 0:
            return musicSongs.count == 0 ? 0 : headerHeight
        case 1:
            return callsignSongs.count == 0 ? 0 : headerHeight
        case 2:
            return artistSongsOn.count == 0 ? 0 : headerHeight
        case 3:
            return recoSongs.count == 0 ? 0 : headerHeight
        case 4:
            return artistSongsOff.count == 0 ? 0 : headerHeight
        default:
            return headerHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard !loadingResult else { return }
        
        self.view.endEditing(true)
        
        let cell = tableView.cellForRow(at: indexPath) as! BaseSearchCell
        cell.activityIndicator.startAnimating()
        lastTappedCell = indexPath
        
        switch indexPath.section {
        case 0:
            self.checkIfTappedArtistOrTitle(songName: musicSongs[indexPath.row])
        case 1:
            self.loadWhatsOnStationAndPlayTheStation(stationId: callsignSongs[indexPath.row].stationId)
        case 2:
            self.playArtistOnlineSong(song: artistSongsOn[indexPath.row])
        case 3:
            self.playStationWithRecoSong(song: recoSongs[indexPath.row])
        case 4:
            self.maybeArtistOfflineSongIsOnline(song: artistSongsOff[indexPath.row])
        default:
            break
        }
        
    }
    
    // Section 0
    func checkIfTappedArtistOrTitle(songName: String) {
        AppData.shared.loadOnline(query: songName, completion: { onlineSongs in
            if onlineSongs.count != 0 {
                let onlineSong = onlineSongs[0]
                self.artist = onlineSong.artist
                if songName == onlineSong.title {
                    // Song was a title
                    self.maybeArtistOfflineSongIsOnline(song: onlineSong)
                } else if songName == onlineSong.artist {
                    // Song was artist
                    self.loadAllSongsForArtist(artist: onlineSong.artist)
                    self.loadOnlineSongsForArtist(artist: onlineSong.artist)
                    self.loadRecoForArtist(artist: onlineSong.artist)
                } else {
                    // Song was something else?
                    self.loadReco(artist: onlineSong.artist, matchedArtist: false)
                }
            } else {
                // No songs with this songname matched
                self.loadReco(artist: songName, matchedArtist: false)
            }
        })
    }
    
    func loadAllSongsForArtist(artist: String) {
        AppData.shared.loadAllSongs(artist: artist, completion: { clearSongs in
            self.artistSongsAll = clearSongs
            self.matchOnlineAndAllSongs()
        })
    }
    
    func loadOnlineSongsForArtist(artist: String) {
        let q = "@artist \(artist)"
        AppData.shared.loadPlaylist(query: q, completion: { songs in
            self.artistSongsOn = songs
            self.matchOnlineAndAllSongs()
        })
    }
    
    func loadRecoForArtist(artist: String) {
        self.artist = artist
        AppData.shared.loadReco2(artist: artist, completion: { recommendedSongs in
            self.recoSongs = recommendedSongs.sorted(by: { $0.callsign < $1.callsign })
            self.recommendation = "Stations with \(artist)"
            self.matchOnlineAndAllSongs()
        })
    }
    
    func matchOnlineAndAllSongs() {
        loadedMatchResults += 1
        if loadedMatchResults != 3 { return }
        
        self.artistSongsAll.forEach { song in
            let occurances = self.artistSongsOn.filter{$0.title.lowercased() == song.title.lowercased() }.count
            if occurances == 0 && song.title != "" {
                self.artistSongsOff.append(song)
            }
        }
        
        if artistSongsOn.count == 0 && artistSongsAll.count == 0 {
            self.loadReco(artist: musicSongs[lastTappedCell!.row], matchedArtist: true)
        }
        if artistSongsOn.count == 0 && artistSongsAll.count > 0 {
            
            self.scrollToSection(number: 3)
        }
        if artistSongsOn.count > 0 && artistSongsAll.count >= 0 {
            self.scrollToSection(number: 2)
        }
    }
    
    // Section 1
    func loadWhatsOnStationAndPlayTheStation(stationId: Int) {
        AppData.shared.loadNowOnStation(stationId: stationId, completion: { songs in
            self.playSong(song: songs[0], station: true)
        })
    }
    
    // Section 2
    func playArtistOnlineSong(song: Song) {
        self.playSong(song: song, station: false)
    }
    
    // Section 3
    func maybeArtistOfflineSongIsOnline(song: Song) {
        
        let q = "@artist \(song.artist) @title \(song.title)"
        AppData.shared.loadPlaylist(query: q, completion: { songs in
            if songs.count != 0 {
                self.playSong(song: songs[0], station: false)
            } else {
                self.loadReco(artist: song.artist, matchedArtist: true)
            }
        })
        
    }
    
    // Section 4
    func playStationWithRecoSong(song: Song) {
        self.playSong(song: song, station: true)
    }
    
    func playSong(song: Song, station: Bool) {
        AppData.shared.getStreamForStationId(stationId: song.stationId, completion: { streamUrl in
            print(streamUrl)
            if station {
                self.searchResult = SearchResult(name: "Station: \(song.callsign)", streamUrl: streamUrl)
            } else {
                self.searchResult = SearchResult(name: "\(song.artist) - \(song.title)", streamUrl: streamUrl)
            }
            self.backButtonTapped(self)
        })
//        let nc = self.navigationController as! PintNC
//        nc.viewControllers.forEach({ vc in
//            if vc.isKind(of: PlayerViewController.self) {
//                let playerVC = vc as! PlayerViewController
//                playerVC.song = song
//                nc.popToViewController(playerVC, animated: true)
//                return
//            }
//        })
//        PlayerManager.shared.latestTitles.removeAll()
//        PlayerManager.shared.artistSeed = song.artist
//        if !PlayerManager.shared.miniPlayerVisible {
////            let playerVC = Constants().initiateVCFromStoryboard(name: Constants.playerViewController) as! PlayerViewController
//////            PlayerManager.shared.currentSong = song
////            self.navigationController?.pushViewController(playerVC, animated: true)
//
//            self.stopSpinner()
//        } else {
//            if PlayerManager.shared.currentSong.stationId != song.stationId {
//                DataLoader().getStreamForStationId(stationId: song.stationId, completion: { streamUrl in
////                    PlayerManager.shared.currentSong = song
////                    PlayerManager.shared.currentSong.streamUrl = streamUrl
//
//
////                    let nc = self.navigationController as! PintNC
////                    let miniPlayer = nc.miniPlayer
////                    miniPlayer?.updateInfo()
////                    if PlayerManager.shared.isPlaying {
////                        miniPlayer?.setLoadingSong(true)
////                        PlayerManager.shared.playSong()
////                    }
//
//                    self.stopSpinner()
//                })
//            } else {
//                self.stopSpinner()
//            }
//        }
    }
    
    
    func scrollToSection(number: Int) {
            self.musicSongs.removeAll()
            self.callsignSongs.removeAll()
        
        self.searchTableView.reloadData()
        self.searchTableView.scrollToRow(at: IndexPath(row: 0, section: number), at: .top, animated: true)
    }
    
    func loadReco(artist: String, matchedArtist: Bool) {
        self.artist = artist
        self.showAlert(message: "Here are stations likely to play that song soon")
        AppData.shared.loadReco2(artist: artist, completion: { recommendedSongs in
            if recommendedSongs.count == 0 {
                self.loadReco(artist: "Culture beat", matchedArtist: false)
                return
            }
            self.recoSongs = recommendedSongs.sorted(by: { $0.callsign < $1.callsign })
            self.recommendation = matchedArtist ? "Stations with \(artist)" : "Similar stations"
            
            
            self.scrollToSection(number: 3)
        })
    }
    
    
}


class SearchCell: BaseSearchCell {
    
}

class BaseSearchCell: UITableViewCell {
    
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var index = (section: 0, row: 0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.textColor = UIColor(hex: "314076")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.image = UIImage(named: "song-placeholder")
        activityIndicator.stopAnimating()
    }
}

class SearchRecoCell: BaseSearchCell {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var callsignLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        artistLabel.textColor = UIColor(hex: "314076")
        callsignLabel.textColor = UIColor.darkGray
    }
}

class LoadingSearchCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.startAnimating()
    }
}
