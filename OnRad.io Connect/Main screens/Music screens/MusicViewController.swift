//
//  MusicViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/2/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit
import Kingfisher

class MusicViewController: UIViewController {

    // MARK: - Constants
    private struct sizeConstants {
        static let headerHeight: CGFloat = 50.0
        static let defaultHeight: CGFloat = 80.0
    }
    
    // MARK: - Properties
    private var loadingOptions: KingfisherOptionsInfo = [.forceTransition, .transition(.fade(1.0))]
    private var topSongs = [Song]()
    private var callsignSongs = [Song]()
    private var artistSongsOn = [Song]()
    private var artistSongsOff = [Song]()
    private var artistSongsAll = [Song]()
    private var recoSongs = [Song]()
    private var loadingResult = false
    private var sections = 6
    private var itemsPerSection = 150
    private var loadedResults = 0
    private var loadedMatchResults = 0
    private var searchQuery = ""
    private var artist = ""
    private var recommendation = ""
    private var imageList = [[String]]()
    private var musicSongs = [String]()
    private var timer: Timer?
    private var lastTappedCell: IndexPath?
    
    // MARK: - Outlets
    @IBOutlet var collectionOfButtons: [UIButton]!
    @IBOutlet var collectionOfTextFields: [UITextField]!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Custom views
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView()
    private let loadingLabel = UILabel()
    
    // MARK: - Actions
    @IBAction func textFieldChanged(_ sender: UITextField) {
        searchMusic()
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchMusic()
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
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegations()
        configureViews()
        loadTopMusic()
        configureImageList()
    }
    private func delegations() {
        tableView.delegate = self
        tableView.dataSource = self
        for textField in collectionOfTextFields {
            textField.delegate = self
        }
    }

    // MARK: - Configure views
    private func configureViews() {
        configureButtons()
        configureTableViews()
        setLoadingScreen()
    }
    private func configureButtons() {
        for button in collectionOfButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.height / 2
            if button.tag == 1 {
                button.isUserInteractionEnabled = false
            }
        }
    }
    private func configureTableViews() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = sizeConstants.defaultHeight
    }
    
    // MARK: - Set the activity indicator into the main view
    private func setLoadingScreen() {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (view.frame.width / 2) - (width / 2)
        let y = (view.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)! - 100
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
    }
    
    // MARK: - Helpers
    private func configureImageList() {
        imageList = Array(repeating: Array(repeating: "", count: itemsPerSection), count: sections)
    }
    private func stopSpinner() {
        if lastTappedCell != nil && !loadingResult && tableView.cellForRow(at: lastTappedCell!) != nil {
            let cell = tableView.cellForRow(at: lastTappedCell!) as! BaseSearchingCell
            cell.activityIndicator.stopAnimating()
        }
    }
    private func searchMusic() {
        if (collectionOfTextFields[0].text?.isEmpty)! {
            removeAll()
            loadTopMusic()
        } else {
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            searchQuery = Constants().removeSpecialCharsFromString(text: collectionOfTextFields[0].text!)
            if searchQuery == "" {
                loadingResult = false
                removeAll()
            } else {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getSearchResults), userInfo: nil, repeats: false)
            }
        }
    }
    private func removeAll() {
        loadedResults = 0
        loadedMatchResults = 0
        self.musicSongs.removeAll()
        self.callsignSongs.removeAll()
        self.artistSongsOn.removeAll()
        self.artistSongsOff.removeAll()
        self.artistSongsAll.removeAll()
        self.recoSongs.removeAll()
        self.topSongs.removeAll()
        self.artist = ""
        self.recommendation = ""
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
    private func checkIfGotAllResults() {
        if loadedResults == 2 {
            self.loadingResult = false
            self.tableView.separatorStyle = .singleLine
            self.tableView.reloadData()
        }
    }
    private func openSongView(song: Song) {
        var song = song
        if song.streamUrl.isEmpty, song.stationId != 0 {
            AppData.shared.getStreamForStationId(stationId: song.stationId, completion: { streamUrl in
                song.streamUrl = streamUrl
                self.presentSongView(song: song)
            })
        } else {
            presentSongView(song: song)
        }
    }
    private func presentSongView(song: Song) {
        if let destinationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SongView") as? SongViewController {
            destinationController.song = song
            if let navigator = navigationController {
                navigator.pushViewController(destinationController, animated: true)
            }
        }
    }
    
    // MARK: - Image downloader
    private func getArtUrl(cell: UITableViewCell, artUrl: (String)) {
        var searchCell = BaseSearchingCell()
        if cell is RecoSearchingCell {
            searchCell = cell as! RecoSearchingCell
        } else {
            searchCell = cell as! BaseSearchingCell
        }
        
        self.imageList[searchCell.index.section][searchCell.index.row] = artUrl
        guard artUrl != Constants.onradioArtwork else { return }
        let url = URL(string: artUrl)
        let placeholder = UIImage(named: "song-placeholder")
        searchCell.artworkView.kf.setImage(with: url, placeholder: placeholder, options: self.loadingOptions, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if error != nil {
                print ("Error")
                self.imageList[searchCell.index.section][searchCell.index.row] = Constants.onradioArtwork
            }
        })
    }
    
    // MARK: - Section 0
    private func checkIfTappedArtistOrTitle(songName: String) {
        AppData.shared.loadOnline(query: songName, completion: { onlineSongs in
            if onlineSongs.count != 0 {
                let onlineSong = onlineSongs[0]
                self.artist = onlineSong.artist
                if songName == onlineSong.title {
                    // Song was a title
                    self.maybeArtistOfflineSongIsOnline(song: onlineSong)
                } else if songName == onlineSong.artist {
                    // Song was an artist
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
    private func loadAllSongsForArtist(artist: String) {
        AppData.shared.loadAllSongs(artist: artist, completion: { clearSongs in
            self.artistSongsAll = clearSongs
            self.matchOnlineAndAllSongs()
        })
    }
    private func loadOnlineSongsForArtist(artist: String) {
        let q = "@artist \(artist)"
        AppData.shared.loadPlaylist(query: q, completion: { songs in
            self.artistSongsOn = songs
            self.matchOnlineAndAllSongs()
        })
    }
    private func loadRecoForArtist(artist: String) {
        self.artist = artist
        AppData.shared.loadReco2(artist: artist, completion: { recommendedSongs in
            self.recoSongs = recommendedSongs.sorted(by: { $0.callsign < $1.callsign })
            self.recommendation = "Stations with \(artist)"
            self.matchOnlineAndAllSongs()
        })
    }
    private func matchOnlineAndAllSongs() {
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
    
    // MARK: - Section 1
    private func loadWhatsOnStationAndPlayTheStation(stationId: Int) {
        AppData.shared.loadNowOnStation(stationId: stationId, completion: { songs in
            self.stopSpinner()
            self.openSongView(song: songs[0])
        })
    }
    
    // MARK: - Section 2
    private func playArtistOnlineSong(song: Song) {
        self.stopSpinner()
        self.openSongView(song: song)
    }
    
    // MARK: - Section 3
    private func maybeArtistOfflineSongIsOnline(song: Song) {
        
        let q = "@artist \(song.artist) @title \(song.title)"
        AppData.shared.loadPlaylist(query: q, completion: { songs in
            if songs.count != 0 {
                self.stopSpinner()
                self.openSongView(song: songs[0])
            } else {
                self.loadReco(artist: song.artist, matchedArtist: true)
            }
        })
        
    }
    
    // MARK: - Section 4
    private func playStationWithRecoSong(song: Song) {
        self.stopSpinner()
        self.openSongView(song: song)
    }
    private func scrollToSection(number: Int) {
        self.musicSongs.removeAll()
        self.callsignSongs.removeAll()
        
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: number), at: .top, animated: true)
    }
    
    private func loadReco(artist: String, matchedArtist: Bool) {
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
    
    // MARK: - Section 5
    private func loadTopMusic() {
        tableView.addSubview(loadingView)
        
        DispatchQueue.global().async {
            AppData.shared.loadTop150(completion: { songList in
                self.topSongs = songList
                self.loadingView.removeFromSuperview()
                self.loadedResults += 2
                self.checkIfGotAllResults()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
}

// MARK: - Table view delegation
extension MusicViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !loadingResult else { return }
        self.view.endEditing(true)
        
        let cell = tableView.cellForRow(at: indexPath) as! BaseSearchingCell
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
        case 5:
            stopSpinner()
            openSongView(song: topSongs[indexPath.row])
        default:
            break
        }
    }
    
}

// MARK: - Table view data source
extension MusicViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = String()
        switch section {
        case 0:
            title = "Music"
        case 1:
            title = "Stations"
        case 2:
            title = "\(artist) songs on right now"
        case 3:
            title = "\(recommendation)"
        case 4:
            title = "\(artist) songs on soon"
        case 5:
            title = "Trending Pipes"
        default:
            title = ""
        }
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: sizeConstants.headerHeight))
        headerView.configureHeaderView(withTitle: title, fontSize: 18.0)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !loadingResult else { return 0 }
        
        switch section {
        case 0:
            return musicSongs.count == 0 ? 0 : sizeConstants.headerHeight
        case 1:
            return callsignSongs.count == 0 ? 0 : sizeConstants.headerHeight
        case 2:
            return artistSongsOn.count == 0 ? 0 : sizeConstants.headerHeight
        case 3:
            return recoSongs.count == 0 ? 0 : sizeConstants.headerHeight
        case 4:
            return artistSongsOff.count == 0 ? 0 : sizeConstants.headerHeight
        case 5:
            return topSongs.count == 0 ? 0 : sizeConstants.headerHeight
        default:
            return sizeConstants.headerHeight
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return loadedResults == 0 ? 1 : 6
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
        case 5:
            return topSongs.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Section 0 - title and artists from songartist.php (autocomplete) that match *query*
        // Section 1 - stations from playlist.php that match @callsign query
        // Section 2 - Online songs from artist if tapped on him on section 0
        // Section 3 - Recommendations
        // Section 4 - Offline songs from artist if tapped on him on section 0
        // Section 5 - Top 150 songs
        
        guard !loadingResult else {
            tableView.addSubview(loadingView)
            
            let cell = UITableViewCell()
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0.9607843137, alpha: 1)
            cell.selectionStyle = .none
            return cell
        }
        loadingView.removeFromSuperview()
        
        if indexPath.section != 3 {
            // sections 0,1,2,4,5
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.baseSearchingReuseIdentifier, for: indexPath) as! BaseSearchingCell
            cell.selectionStyle = .none
            
            if imageList[indexPath.section][indexPath.row] == "" || imageList[indexPath.section][indexPath.row] == Constants.onradioArtwork {
                if indexPath.section == 0 {
                    AppData.shared.loadOnline(query: musicSongs[indexPath.row], completion: { songs in
                        if songs.count != 0 {
                            AppData.shared.loadArt(artist: songs[0].artist, title: songs[0].title, completion: { artUrl in
                                self.getArtUrl(cell: cell, artUrl: artUrl)
                            })
                        }
                    })
                }
                if indexPath.section == 1 {
                    AppData.shared.loadStationArt(stationId: callsignSongs[indexPath.row].stationId, completion: { artUrl in
                        self.getArtUrl(cell: cell, artUrl: artUrl)
                    })
                }
                if indexPath.section == 2 {
                    AppData.shared.loadArt(artist: artistSongsOn[indexPath.row].artist, title: artistSongsOn[indexPath.row].title, completion: { artUrl in
                        self.getArtUrl(cell: cell, artUrl: artUrl)
                    })
                }
                if indexPath.section == 4 {
                    AppData.shared.loadArt(artist: artistSongsOff[indexPath.row].artist, title: artistSongsOff[indexPath.row].title, completion: { artUrl in
                        self.getArtUrl(cell: cell, artUrl: artUrl)
                    })
                }
                if indexPath.section == 5 {
                    AppData.shared.loadArt(artist: topSongs[indexPath.row].artist, title: topSongs[indexPath.row].title, completion: { artUrl in
                        self.getArtUrl(cell: cell, artUrl: artUrl)
                    })
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
                cell.configure(title: musicSongs[indexPath.row])
            case 1:
                cell.configure(title: callsignSongs[indexPath.row].callsign)
            case 2:
                cell.configure(title: artistSongsOn[indexPath.row].title)
            case 4:
                cell.configure(title: artistSongsOff[indexPath.row].title)
            case 5:
                cell.configure(title: topSongs[indexPath.row].artist + ", " +  topSongs[indexPath.row].title)
            default:
                break
            }
            
            return cell
            
        } else {
            // section 3
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.recoSearchingReuseIdentifier, for: indexPath) as! RecoSearchingCell
            cell.selectionStyle = .none
            
            if imageList[indexPath.section][indexPath.row] == "" || imageList[indexPath.section][indexPath.row] == Constants.onradioArtwork {
                if indexPath.section == 4 {
                    DataLoader().loadArt(artist: recoSongs[indexPath.row].artist, title: recoSongs[indexPath.row].title, completion: { artUrl in
                        self.getArtUrl(cell: cell, artUrl: artUrl)
                    })
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
            
            cell.configure(song: recoSongs[indexPath.row])
            return cell
        }
        
    }
    
}

// MARK: - Text fields delegation
extension MusicViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            for textF in collectionOfTextFields where textF.tag == 0 {
                DispatchQueue.main.async {
                    textF.becomeFirstResponder()
                }
            }
        }
    }
    
}
