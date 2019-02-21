//
//  SongViewController.swift
//  OnRad.io Connect
//
//  Created by Dmytro Dobrovolskyy on 10/4/18.
//  Copyright © 2018 Igor Zharii. All rights reserved.
//

import UIKit
import Contacts

class SongViewController: UIViewController {
    
    // MARK: - Properties
    private var pipers = [Piper]()
    var selectedUsersToPipe = [Piper]()
    var song = Song()
    
    // MARK: - Outlets
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet var collectionOfButtons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Actions
    @IBAction func buttonsTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            previewSong()
        case 2:
            if song.streamUrl.isEmpty {
                presentAlert(timeAmount: "10")
            } else {
                // TODO: - Send song to friend
            }
        default:
            break
        }
    }
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegations()
        configureViews()
        setupData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            AppData.shared.stopPlayer()
        }
    }
    private func delegations() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Configure views
    private func configureViews() {
        configureSongNameLabel()
        configureButtons()
        configureTableViews()
    }
    private func configureSongNameLabel() {
        songNameLabel.text = song.artist + ", " + song.title
    }
    private func configureButtons() {
        for button in collectionOfButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.height / 2
        }
        for button in collectionOfButtons where button.tag == 0 {
            let imageSize = CGSize(width: 40, height: 40)
            
            button.setImage(UIImage(named: "play.png"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsetsMake(
                (button.frame.size.height - imageSize.height) / 2,
                (button.frame.size.width - imageSize.width) / 2,
                (button.frame.size.height - imageSize.height) / 2,
                (button.frame.size.width - imageSize.width) / 2
            )
        }
    }
    private func configureTableViews() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3))
        footerView.addTopBorderWithColor(color: .lightGray, width: 0.3)
        
        tableView.tableFooterView = footerView
    }
    
    // MARK: - Preview button functionality
    private func previewSong() {
        if self.song.streamUrl.isEmpty {
            self.showAlert(message: "Sorry, but this song is offline now.")
        } else {
            self.playSong(url: self.song.streamUrl)
        }
    }
    private func playSong(url: String) {
        for button in collectionOfButtons where button.tag == 0 {
            button.setImage(UIImage(named: AppData.shared.previewButtonTapped(url: url)), for: .normal)
        }
    }
    
    // MARK: - Pipe button functionality
    private func presentAlert(timeAmount: String) {
        let alert = UIAlertController(title: "Wait a bit!", message: "Expect it to be played in \(timeAmount) minutes - pipe when available?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Setup data
    private func setupData() {
        pipers.append(Piper(name: "Kerrigan"))
        pipers.append(Piper(name: "Hasoyama"))
        pipers.append(Piper(name: "Greedy"))
        pipers.append(Piper(name: "Lacky"))
        pipers.append(Piper(name: "Solomon"))
        pipers.append(Piper(name: "Asket"))
        pipers.append(Piper(name: "Godlike"))
        pipers.append(Piper(name: "Smoothy"))
        pipers.append(Piper(name: "PiperPipe"))
    }
    
}

// MARK: - Table view delegation
extension SongViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            switch cell.accessoryType {
            case .none:
                cell.accessoryType = .checkmark
            case .checkmark:
                cell.accessoryType = .none
            default:
                break
            }
        }
        pipers[indexPath.row].isSelected = !pipers[indexPath.row].isSelected
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}

// MARK: - Table view data source
extension SongViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3))
        headerView.backgroundColor = .lightGray
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pipers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.pipersTableViewReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = pipers[indexPath.row].name
        
        return cell
    }
    
}
