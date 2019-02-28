//
//  SoundPlayerForMacTrek.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/24/19.
//

import Foundation
@objc class SoundPlayerForMacTrek: SoundPlayer {
    override func subscribeToNotifications() {
        super.subscribeToNotifications()
        
        notificationCenter?.addObserver(self, selector: #selector(handleTransporter), name: "SPW_BEAMUP2_TEXT")
        notificationCenter?.addObserver(self, selector: #selector(handleTransporter), name: "SSPW_BEAM_D_PLANET_TEXT")
        notificationCenter?.addObserver(self, selector: #selector(handleTransporter), name: "SPW_BEAM_U_TEXT")
        notificationCenter?.addObserver(self, selector: #selector(handleDeath), name: "CC_GO_OUTFIT")

        //NotificationCenter.default.addObserver(self, selector: #selector(handleTransporter), name: NSNotification.Name(rawValue: "SPW_BEAMUP2_TEXT"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleTransporter), name: NSNotification.Name(rawValue: "SSPW_BEAM_D_PLANET_TEXT"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleTransporter), name: NSNotification.Name(rawValue: "SPW_BEAM_U_TEXT"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleDeath), name: NSNotification.Name(rawValue: "CC_GO_OUTFIT"), object: nil)
    }
    
    @objc override func loadSounds() {
        soundEffects["CLOAK_SOUND"] = SoundEffect("SoundEffects2/cloak.wav")
        //soundEffects["ENGINE_SOUND"] = SoundEffect("SoundEffects/engine.au")
        soundEffects["ENTER_SHIP_SOUND"] = SoundEffect("SoundEffects2/enter_ship.wav")
        soundEffects["EXPLOSION_SOUND"] = SoundEffect("SoundEffects2/explosion.wav")
        soundEffects["FIRE_PLASMA_SOUND"] = SoundEffect("SoundEffects2/fire_plasma.wav")
        soundEffects["FIRE_PLASMA_OTHER_SOUND"] = SoundEffect("SoundEffects2/fire_plasma.wav", number: 8)
        soundEffects["FIRE_TORP_SOUND"] = SoundEffect("SoundEffects2/fire_torp.wav", number: 8)
        soundEffects["FIRE_TORP_OTHER_SOUND"] = SoundEffect("SoundEffects2/fire_torp_other.wav", number: 8)
        soundEffects["INTRO_SOUND"] = SoundEffect("SoundEffects2/intro.wav")
        soundEffects["MESSAGE_SOUND"] = SoundEffect("SoundEffects2/message.wav")
        soundEffects["PHASER_SOUND"] = SoundEffect("SoundEffects2/fire_phaser.wav")
        soundEffects["PHASER_OTHER_SOUND"] = SoundEffect("SoundEffects2/fire_phaser_other.wav")
        soundEffects["PLASMA_HIT_SOUND"] = SoundEffect("SoundEffects2/plasma_hit.wav")
        soundEffects["RED_ALERT_SOUND"] = SoundEffect("SoundEffects2/red_alert.wav")
        soundEffects["SELF_DESTRUCT_SOUND"] = SoundEffect("SoundEffects/self_destruct.au")
        soundEffects["SHIELD_DOWN_SOUND"] = SoundEffect("SoundEffects2/shield_down.wav")
        soundEffects["SHIELD_UP_SOUND"] = SoundEffect("SoundEffects2/shield_up.wav")
        soundEffects["TORP_HIT_SOUND"] = SoundEffect("SoundEffects2/torp_hit.wav")
        soundEffects["UNCLOAK_SOUND"] = SoundEffect("SoundEffects2/uncloak.wav")
        //soundEffects["WARNING_SOUND"] = SoundEffect("SoundEffects/warning.au")
        soundEffects["EXPLOSION_OTHER_SOUND"] = SoundEffect("SoundEffects2/explosion_other.wav")

        soundEffects["TRANSPORTER_SOUND"] = SoundEffect("SoundEffects2/transporter.wav")
        soundEffects["I_DIED_SOUND"] = SoundEffect("SoundEffects2/good-day-to-die.au")
        debugPrint("Sound player for mac load done")
        //let SP_SOUNDS_CACHED = NSString(string: "SP_SOUNDS_CACHED")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "SP_SOUNDS_CACHED")))
    }

    @objc override func unSubscribeToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleTransporter() {
        self.playSoundEffect("TRANSPORTER_SOUND")
    }
    @objc func handleDeath() {
        self.playSoundEffect("I_DIED_SOUND")
    }
    

}
