//
//  SoundPlayer.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/24/19.
//

import Foundation

@objc class SoundPlayer: NSObject {
    let notificationCenter = LLNotificationCenter.default()
    var volumeFX: Float = 0.5
    var volumeMusic: Float = 0.5
    var soundEffects: [String:SoundEffect] = [:]
    let universe: Universe!
    let SP_MAX_RANGE: Float = 10000.0
    override init() {
        universe = Universe.defaultInstance()
        super.init()
        self.performSelector(inBackground: #selector(loadSounds), with: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopIntroSound), name: NSNotification.Name(rawValue: "GM_GAME_ENTERED"), object: nil)
    }
    @objc func stopSound(_ snd: NSString) {
        if let sound = soundEffects[snd as String] {
            sound.stop()
        } else {
            print("SoundPlayer sound \(snd) not found unable to stop")
        }
    }
    @objc func stopIntroSound() {
        self.stopSound("INTRO_SOUND")
    }
    func loadSoundsInSeparateThread(sender: Any) {
        self.loadSounds()
    }
    @objc func setVolumeFx(_ vol: Float) {
        self.volumeFX = vol
    }
    @objc func setVolumeMusic(_ vol: Float) {
        self.volumeMusic = vol
    }
    @objc func subscribeToNotifications() {
        
        notificationCenter?.addObserver(self, selector: #selector(handleAlertChanged), name: "PL_ALERT_STATUS_CHANGED")
        notificationCenter?.addObserver(self, selector: #selector(handleCloakChanged), name: "PL_CLOAKING")
        notificationCenter?.addObserver(self, selector: #selector(handleAlertChanged), name: "PL_UNCLOAKING")
        notificationCenter?.addObserver(self, selector: #selector(handleMyPhaser), name: "PL_MY_PHASER_FIRING")
        notificationCenter?.addObserver(self, selector: #selector(handleOtherPhaser), name: "PL_OTHER_PHASER_FIRING")
        notificationCenter?.addObserver(self, selector: #selector(handleMyTorpFired), name: "PL_TORP_FIRED_BY_ME")
        notificationCenter?.addObserver(self, selector: #selector(handleOtherTorpFired), name: "PL_TORP_FIRED_BY_OTHER")
        notificationCenter?.addObserver(self, selector: #selector(handleTorpExploded), name: "PL_TORP_EXPLODED")
        notificationCenter?.addObserver(self, selector: #selector(handleMyPlasmaFired), name: "PL_PLASMA_FIRED_BY_ME")
        notificationCenter?.addObserver(self, selector: #selector(handleOtherPlasmaFired), name: "PL_PLASMA_FIRED_BY_OTHER")
        notificationCenter?.addObserver(self, selector: #selector(handlePlasmaExploded), name: "PL_PLASMA_EXPLODED")
        notificationCenter?.addObserver(self, selector: #selector(handlePlayerExploded), name: "PL_EXPLODE_PLAYER")
        notificationCenter?.addObserver(self, selector: #selector(handleSelfDestruct), name: "SPW_SELF_DESTRUCT_INITIATED")
        notificationCenter?.addObserver(self, selector: #selector(handleShieldsPlayer), name: "PL_SHIELD_UP_PLAYER")
        notificationCenter?.addObserver(self, selector: #selector(handleShieldsPlayer), name: "PL_SHIELD_DOWN_PLAYER")
        notificationCenter?.addObserver(self, selector: #selector(handleSpeedChangeRequest), name: "COMM_SEND_SPEED_REQ")
        notificationCenter?.addObserver(self, selector: #selector(handleMessageSent), name: "COMM_SEND_MESSAGE")

        //NotificationCenter.default.addObserver(self, selector: #selector(handleAlertChanged),name: NSNotification.Name(rawValue: "PL_ALERT_STATUS_CHANGED"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleCloakChanged),name: NSNotification.Name(rawValue: "PL_CLOAKING"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleCloakChanged),name: NSNotification.Name(rawValue: "PL_UNCLOAKING"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleMyPhaser),name: NSNotification.Name(rawValue: "PL_MY_PHASER_FIRING"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleOtherPhaser),name: NSNotification.Name(rawValue: "PL_OTHER_PHASER_FIRING"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleMyTorpFired),name: NSNotification.Name(rawValue: "PL_TORP_FIRED_BY_ME"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleOtherTorpFired),name: NSNotification.Name(rawValue: "PL_TORP_FIRED_BY_OTHER"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleTorpExploded),name: NSNotification.Name(rawValue: "PL_TORP_EXPLODED"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleMyPlasmaFired),name: NSNotification.Name(rawValue: "PL_PLASMA_FIRED_BY_ME"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleOtherPlasmaFired),name: NSNotification.Name(rawValue: "PL_PLASMA_FIRED_BY_OTHER"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handlePlasmaExploded),name: NSNotification.Name(rawValue: "PL_PLASMA_EXPLODED"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerExploded),name: NSNotification.Name(rawValue: "PL_EXPLODE_PLAYER"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleSelfDestruct),name: NSNotification.Name(rawValue: "SPW_SELF_DESTRUCT_INITIATED"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleShieldsPlayer),name: NSNotification.Name(rawValue: "PL_SHIELD_UP_PLAYER"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleShieldsPlayer),name: NSNotification.Name(rawValue: "PL_SHIELD_DOWN_PLAYER"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleSpeedChangeRequest),name: NSNotification.Name(rawValue: "COMM_SEND_SPEED_REQ"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handleMessageSent),name: NSNotification.Name(rawValue: "COMM_SEND_MESSAGE"), object: nil)

        //[notificationCenter addObserver:self selector:@selector(handleOtherPhaser:) name:@"PL_OTHER_PHASER_FIRING"];
        //[notificationCenter addObserver:self selector:@selector(handleOtherTorpFired:) name:@"PL_TORP_FIRED_BY_OTHER"];
        //[notificationCenter addObserver:self selector:@selector(handleOtherPlasmaFired:) name:@"PL_PLASMA_FIRED_BY_OTHER"];
        //[notificationCenter addObserver:self selector:@selector(handlePlasmaExploded:) name:@"PL_PLASMA_EXPLODED"];
        //[notificationCenter addObserver:self selector:@selector(handlePlayerExploded:) name:@"PL_EXPLODE_PLAYER"];
    }
    @objc func unSubscribeToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func loadSounds() {
        soundEffects["CLOAK_SOUND"] = SoundEffect("SoundEffects/cloak.au")
        soundEffects["ENGINE_SOUND"] = SoundEffect("SoundEffects/engine.au")
        soundEffects["ENTER_SHIP_SOUND"] = SoundEffect("SoundEffects/enter_ship.au")
        soundEffects["EXPLOSION_SOUND"] = SoundEffect("SoundEffects/explosion_other.au")
        soundEffects["FIRE_PLASMA_SOUND"] = SoundEffect("SoundEffects/fire_plasma.au")
        soundEffects["FIRE_PLASMA_OTHER_SOUND"] = SoundEffect("SoundEffects/fire_plasma.au", number: 8)         // use same sound")
        soundEffects["FIRE_TORP_SOUND"] = SoundEffect("SoundEffects/fire_torp.au", number: 8)
        soundEffects["FIRE_TORP_OTHER_SOUND"] = SoundEffect("SoundEffects/fire_torp_other.au", number: 8)
        soundEffects["INTRO_SOUND"] = SoundEffect("SoundEffects/intro.au")
        soundEffects["MESSAGE_SOUND"] = SoundEffect("SoundEffects/message.au")
        soundEffects["PHASER_SOUND"] = SoundEffect("SoundEffects/fire_phaser.au")
        soundEffects["PHASER_OTHER_SOUND"] = SoundEffect("SoundEffects/fire_phaser_other.au")
        soundEffects["PLASMA_HIT_SOUND"] = SoundEffect("SoundEffects/plasma_hit.au")
        soundEffects["RED_ALERT_SOUND"] = SoundEffect("SoundEffects/red_alert.au")
        soundEffects["SELF_DESTRUCT_SOUND"] = SoundEffect("SoundEffects/self_destruct.au")
        soundEffects["SHIELD_DOWN_SOUND"] = SoundEffect("SoundEffects/shield_down.au")
        soundEffects["SHIELD_UP_SOUND"] = SoundEffect("SoundEffects/shield_up.au")
        soundEffects["TORP_HIT_SOUND"] = SoundEffect("SoundEffects/torp_hit.au")
        soundEffects["UNCLOAK_SOUND"] = SoundEffect("SoundEffects/uncloak.au")
        soundEffects["WARNING_SOUND"] = SoundEffect("SoundEffects/warning.au")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "SP_SOUNDS_CACHED")))
        debugPrint("SoundPlayer sounds loaded")
     }
    @objc func handleSpeedChangeRequest(_ reqSpeed: NSNumber) {
        // do nothing, horrible sound effect
    }
    @objc func handleAlertChanged(_ intAlert: NSNumber) {
        let newAlertStatus = intAlert.intValue
        if newAlertStatus == PLAYER_RED {
            self.playSoundEffect("RED_ALERT_SOUND")
        }
    }
    
    @objc func playSoundEffect(_ snd: NSString) {
        if let sound = soundEffects[snd as String] {
            sound.playWithVolume(volumeFX)
        } else {
            debugPrint("SoundPlayer no sound for \(snd)")
        }
    }
    
    @objc func handleCloakChanged(_ boolCloakOn: NSNumber) {
        let cloakOn = boolCloakOn.boolValue
        if cloakOn {
            self.playSoundEffect("CLOAK_SOUND")
        } else {
            self.playSoundEffect("UNCLOAK_SOUND")
        }
    }
    
    @objc func handleMessageSent() {
        self.playSoundEffect("MESSAGE_SOUND")
    }
    
    @objc func handleSelfDestruct() {
        self.playSoundEffect("SELF_DESTRUCT_SOUND")
    }
    @objc func handleMyPhaser(_ phaser: Phaser) {
        self.playSoundEffect("PHASER_SOUND")
    }
    @objc func handleShieldsPlayer(_ player: Player) {
        if player.isMe() {
            if player.flags() & PLAYER_SHIELD != 0 {
                self.playSoundEffect("SHIELD_UP_SOUND")
            } else {
                self.playSoundEffect("SHIELD_DOWN_SOUND")
            }
        }
    }
    @objc func handlePlayerExploded(_ player: Player) {
        if player.isMe() {
            self.playSoundEffect("EXPLOSION_SOUND")
        } else {
            self.playSoundEffect("EXPLOSION_OTHER_SOUND")
        }
    }
    @objc func handleOtherPhaser(_ phaser: Phaser) {
        if let sound = soundEffects["PHASER_OTHER_SOUND"] {
            self.playSoundEffect(sound, relativeToEntity: phaser.owner())
        }
    }
    @objc func handleMyTorpFired(_ torp: Torp) {
        self.playSoundEffect("FIRE_TORP_SOUND")
    }
    @objc func handleOtherTorpFired(_ torp: Torp) {
        if let sound = soundEffects["FIRE_TORP_OTHER_SOUND"] {
            self.playSoundEffect(sound, relativeToEntity: torp.owner())
        }
    }
    @objc func handleTorpExploded(_ torp: Torp) {
        if let sound = soundEffects["TORP_HIT_SOUND"] {
            self.playSoundEffect(sound, relativeToEntity: torp)
        }
    }
    @objc func handleMyPlasmaFired() {
        self.playSoundEffect("FIRE_PLASMA_SOUND")
    }
    @objc func handleOtherPlasmaFired(_ plasma: Plasma) {
        if let sound = soundEffects["FIRE_PLASMA_OTHER_SOUND"] {
            self.playSoundEffect(sound, relativeToEntity: plasma.owner())
        }
    }
    @objc func handlePlasmaExploded(_ plasma: Plasma) {
        if let sound = soundEffects["PLASMA_HIT_SOUND"] {
            self.playSoundEffect(sound, relativeToEntity: plasma)
        }
    }
    func playSoundEffect(_ sound: SoundEffect, relativeToEntity obj: Entity) {
        let distance = universe.distance(to: obj, from: universe.playerThatIsMe())
        let angle = universe.angleDegBetweenEntity(obj, from: universe.playerThatIsMe())
        self.playSoundEffect(sound, angle: angle, distance: Float(distance))
    }
    func playSoundEffect(_ sound: SoundEffect, angle: Float, distance: Float) {
        if (distance > SP_MAX_RANGE) {
            // prevent negative volume
            return
        }
        let balance = sin(angle)
        let volume = volumeFX - (volumeFX * distance) / SP_MAX_RANGE
        
        sound.playWithVolume(volume, balance: balance)
    }
    
}
