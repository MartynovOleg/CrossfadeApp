//
//  ViewController.swift
//  CrossfadeApp
//
//  Created by mac on 27.04.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    
    var fileURL = Bundle.main.path(forResource: "Ark Patrol feat. Veronika Redd - Let Go", ofType: "mp3")
   
    @IBOutlet var audio1Botton: UIButton!
    @IBOutlet var audio2Button: UIButton!
    @IBAction func playDidTapped(_ sender: Any) {
        
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            audioPlayer.stop()
            playButton.setTitle(" Play", for: .normal)
            self.audioNames.text = ""
            playButton.setImage(UIImage.init(systemName: "play.circle.fill"), for: .normal)
        } else {
            playSound()
            playButton.setTitle(" Stop", for: .normal)
            playButton.setImage(UIImage.init(systemName: "stop.circle.fill"), for: .normal)
        }
    }
    @IBAction func crossfadeValues(_ sender: Any) {
    }
    @IBOutlet var audioNames: UILabel!
    @IBOutlet var playButton: UIButton!
    
    @IBAction func audio1DidTapped(_ sender: UIButton) {
    }
    
    @IBAction func audio2DidTapped(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Ark Patrol feat. Veronika Redd - Let Go", withExtension: "mp3") else { return }
        self.audioNames.text = url.lastPathComponent
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let audioPlayer = audioPlayer else {
                return
            }
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
   }

