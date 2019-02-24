//
//  SoundEffect.swift
//  MacTrek
//
//  Created by Darrell Root on 2/24/19.
//

import Foundation
import AVFoundation

@objc class SoundEffect: NSObject {
    var name: NSString?
    var soundInstances: [AVAudioPlayer] = []
    override init () {
        super.init()
    }
    @objc public func loadSoundWithName(_ soundName: NSString) -> Bool {
        return loadSoundWithName(soundName, nrOfInstances: 1)
    }
    @objc public func loadSoundWithName(_ soundName: NSString, nrOfInstances: Int) -> Bool {
        guard nrOfInstances > 0 else { return false }
        let possiblePathToSound = Bundle.main.url(forResource: soundName as String, withExtension: "")
 /*       if possiblePathToSound == nil {
            possiblePathToSound = Bundle.main.url(forResource: soundName as String, withExtension: "au")
        }*/
        guard let pathToSound = possiblePathToSound else {
            print("failed to load sound \(soundName)")
            return false
        }
        self.setName(newName: soundName)
        for _ in 0..<nrOfInstances {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: pathToSound)
                soundInstances.append(audioPlayer)
            } catch {
                print("failed to load sound \(soundName)")
                return false
            }
        }
        return true
    }
    
    func setName(newName: NSString) {
        self.name = newName
    }
    func sound() -> AVAudioPlayer? {
        for sound in soundInstances {
            if sound.currentTime == 0 || sound.currentTime >= sound.duration {
                sound.currentTime = 0
                return sound
            }
        }
        print("soundEffect no free sound")
        return nil
    }
    func play() {
        if let sound = sound() {
            sound.play()
        }
    }
    func stop() {
        for sound in soundInstances {
            sound.stop()
            sound.currentTime = 0
        }
    }
    @objc func playWithVolume(_ vol: Float, bal: Float = 0.0) {
        //no balance control that I see, so ignoring balance
        if let sound = sound() {
            sound.setVolume(vol, fadeDuration: 0.0)
            sound.play()
        }
    }
    @objc func playWithVolume(_ vol: Float) {
        self.playWithVolume(vol, bal: 0.0)
    }
}
