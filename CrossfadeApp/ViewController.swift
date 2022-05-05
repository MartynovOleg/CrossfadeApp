//
//  ViewController.swift
//  CrossfadeApp
//
//  Created by mac on 27.04.2022.
//

import UIKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var audio1Botton: UIButton!
    @IBOutlet var audio2Button: UIButton!
    @IBOutlet var audioNames: UILabel!
    @IBOutlet var playButton: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var avPlayer: AVQueuePlayer?
    var looper: AVPlayerLooper?
    let composition = AVMutableComposition()

    var firstSelectedUrl: URL?
    var secondSelectedUrl: URL?
    var selectingFileHandler: ((URL) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .systemMint
        containerView.layer.cornerRadius = 8
    }
    
    // MARK: - IBActions
    
    @IBAction func playDidTapped(_ sender: Any) {
        
        if let avPlayer = avPlayer {
            avPlayer.pause()
            audioNames.text = ""
            playButton.setBackgroundImage(UIImage.init(systemName: "play.circle.fill"), for: .normal)
        } else {
            playSound()
            playButton.setBackgroundImage(UIImage.init(systemName: "stop.circle.fill"), for: .normal)
        }
    }
    
    @IBAction func audio1DidTapped(_ sender: UIButton) {
        selectingFileHandler = { url in
            self.firstSelectedUrl = url
        }
        openDocumentPicker()
    }
    
    @IBAction func audio2DidTapped(_ sender: UIButton) {
        selectingFileHandler = { url in
            self.secondSelectedUrl = url
        }
        openDocumentPicker()
    }
    
    @IBAction func crossfadeSlider(_ sender: UISlider) {
    }
    
    // MARK: - Private
    
    private func playSound() {
        guard let url = firstSelectedUrl,
              let secondFileUrl = secondSelectedUrl else { return }
        self.audioNames.text = url.lastPathComponent
        do {
            
            let asset = AVAsset(url: url)
            let secondAsset = AVAsset(url: secondFileUrl)
            
            guard let track = asset.tracks.first,
            let secondTrack = secondAsset.tracks.first else { return }

            let composition = AVMutableComposition()
            let firstTrackComposition = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
            let secondTrackComposition = composition.addMutableTrack(withMediaType: secondTrack.mediaType, preferredTrackID: secondTrack.trackID)

            let fadeDuration: CMTime = 2.5
            let offset: CMTime = 0.0
            try firstTrackComposition?.insertTimeRange(CMTimeRange(start: 0.0,
                                                                   duration: asset.duration),
                                                       of: track,
                                                       at: .zero)
            try secondTrackComposition?.insertTimeRange(CMTimeRange(start: 0.0,
                                                                    duration: secondAsset.duration),
                                                        of: secondTrack,
                                                        at: asset.duration - offset)
            
            let playerItem = AVPlayerItem(asset: composition)
            
            let mix = AVMutableAudioMix()
            let firstTrackParameters = AVMutableAudioMixInputParameters(track: firstTrackComposition!)
            firstTrackParameters.setVolumeRamp(fromStartVolume: 0,
                                               toEndVolume: 1,
                                               timeRange: CMTimeRange(start: 0.0,
                                                                      duration: fadeDuration))
            firstTrackParameters.setVolumeRamp(fromStartVolume: 1,
                                               toEndVolume: 0,
                                               timeRange: CMTimeRange(start: asset.duration - offset,
                                                                      duration: fadeDuration))
            let secondTrackParameters = AVMutableAudioMixInputParameters(track: secondTrackComposition!)
            secondTrackParameters.setVolumeRamp(fromStartVolume: 0,
                                                toEndVolume: 1,
                                                timeRange: CMTimeRange(start: asset.duration - offset,
                                                                       duration: fadeDuration))
            secondTrackParameters.setVolumeRamp(fromStartVolume: 1,
                                                toEndVolume: 0,
                                                 timeRange: CMTimeRange(start: asset.duration + secondAsset.duration - offset - offset,
                                                                      duration: fadeDuration))
            mix.inputParameters = [firstTrackParameters, secondTrackParameters]
            playerItem.audioMix = mix
            
            let player = AVQueuePlayer(playerItem: playerItem)
            avPlayer = player
            looper = AVPlayerLooper(player: player, templateItem: playerItem)
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    private func openDocumentPicker() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3])
        present(documentPickerController, animated: true)
        documentPickerController.delegate = self
    }
   // private func crossfadeVolume() {
   //       audioPlayer?.setVolume(0.00, fadeDuration: crossfadeSlider.value)
   //}
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.isEmpty { return }
        selectingFileHandler?(urls[0])
        selectingFileHandler = nil
    }
}

extension CMTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(seconds: value, preferredTimescale: 1)
    }
}
