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
    var avPlayer: AVPlayer?
    let composition = AVMutableComposition()

    //var fileURL = Bundle.main.path(forResource: "Ark Patrol feat. Veronika Redd - Let Go", ofType: "mp3")
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
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)

//            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            guard let audioPlayer = audioPlayer else {
//                return
//            }
//            audioPlayer.play()
//            audioPlayer.numberOfLoops = -1
            
            let asset = AVAsset(url: url)
            let secondAsset = AVAsset(url: secondFileUrl)
            
            guard let track = asset.tracks.first,
            let secondTrack = secondAsset.tracks.first else { return }
            
            
//            let trackSegment = AVCompositionTrackSegment(url: url,
//                                                         trackID: track.trackID,
//                                                         sourceTimeRange: CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1),
//                                                                                      duration: asset.duration),
//                                                         targetTimeRange: CMTimeRange(start: CMTime(value: asset.duration.value - 5,
//                                                                                                    timescale: 1),
//                                                                                      end: asset.duration))
            
//            composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: trackSegment.sourceTrackID)
            
            let composition = AVMutableComposition()
            let firstTrackComposition = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
            let secondTrackComposition = composition.addMutableTrack(withMediaType: secondTrack.mediaType, preferredTrackID: secondTrack.trackID)
            
            try! firstTrackComposition?.insertTimeRange(CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1),
                                                    duration: asset.duration),
                                        of: track,
                                        at: .zero)
            
            try! secondTrackComposition?.insertTimeRange(CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1),
                                                    duration: secondAsset.duration),
                                        of: secondTrack,
                                        at: .zero)
            
            let playerItem = AVPlayerItem(asset: composition)
            avPlayer = AVPlayer(playerItem: playerItem)
            
            let mix = AVMutableAudioMix()
            let firstTrackParameters = AVMutableAudioMixInputParameters(track: track)
            firstTrackParameters.setVolumeRamp(fromStartVolume: 0.01,
                                     toEndVolume: 1,
                                     timeRange: CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1),
                                                            duration: CMTime(seconds: 5, preferredTimescale: 1)))
            let secondTrackParameters = AVMutableAudioMixInputParameters(track: secondTrack)
            firstTrackParameters.setVolumeRamp(fromStartVolume: 0.01,
                                     toEndVolume: 1,
                                     timeRange: CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1),
                                                            duration: CMTime(seconds: 5, preferredTimescale: 1)))
            mix.inputParameters = [firstTrackParameters, secondTrackParameters]
           // avPlayer?.currentItem?.audioMix = mix
            avPlayer?.play()
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

