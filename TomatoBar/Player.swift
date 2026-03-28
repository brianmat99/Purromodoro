import AVFoundation
import SwiftUI

class TBPlayer: ObservableObject {
    private var dingSound: AVAudioPlayer
    private var meowSound: AVAudioPlayer
    private var purrSound: AVAudioPlayer

    @AppStorage("dingVolume") var dingVolume: Double = 1.0 {
        didSet {
            setVolume(dingSound, dingVolume)
        }
    }
    @AppStorage("meowVolume") var meowVolume: Double = 1.0 {
        didSet {
            setVolume(meowSound, meowVolume)
        }
    }
    @AppStorage("purrVolume") var purrVolume: Double = 1.0 {
        didSet {
            setVolume(purrSound, purrVolume)
        }
    }

    private func setVolume(_ sound: AVAudioPlayer, _ volume: Double) {
        sound.setVolume(Float(volume), fadeDuration: 0)
    }

    init() {
        let dingSoundAsset = NSDataAsset(name: "ding")
        let meowSoundAsset = NSDataAsset(name: "meow")
        let purrSoundAsset = NSDataAsset(name: "purr")

        let wav = AVFileType.wav.rawValue
        do {
            dingSound = try AVAudioPlayer(data: dingSoundAsset!.data, fileTypeHint: wav)
            meowSound = try AVAudioPlayer(data: meowSoundAsset!.data, fileTypeHint: wav)
            purrSound = try AVAudioPlayer(data: purrSoundAsset!.data, fileTypeHint: wav)
        } catch {
            fatalError("Error initializing players: \(error)")
        }

        dingSound.prepareToPlay()
        meowSound.prepareToPlay()
        purrSound.prepareToPlay()

        setVolume(dingSound, dingVolume)
        setVolume(meowSound, meowVolume)
        setVolume(purrSound, purrVolume)
    }

    func playDing() {
        dingSound.play()
    }

    func playMeow() {
        meowSound.play()
    }

    func playPurr() {
        purrSound.play()
    }
}
