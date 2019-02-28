//
//  MTVoiceController.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/24/19.
//

import Foundation


@objc class MTVoiceController: NSObject, NSSpeechRecognizerDelegate {
    let speechRecognizer = NSSpeechRecognizer()
    let cmds = [
        "torpedo",
        "plasma",
        "phaser",
        "course",
        "shields",
        "bomb",
        "repair",
        "lock",
        "tractor",
        "press",
        "max",
        "stop",
        "cloak"]
    let codes = [
        ACTION_FIRE_TORPEDO,
        ACTION_FIRE_PLASMA,
        ACTION_FIRE_PHASER,
        ACTION_SET_COURSE,
        ACTION_SHIELDS,
        ACTION_BOMB,
        ACTION_REPAIR,
        ACTION_LOCK,
        ACTION_TRACTOR,
        ACTION_PRESSOR,
        ACTION_WARP_MAX,
        ACTION_WARP_0,
        ACTION_CLOAK]

    override init() {
        super.init()
        speechRecognizer?.commands = cmds
        speechRecognizer?.delegate = self
    }
    
    @objc func setEnableListening(_ onOff: Bool) {
        if onOff { // listen
            debugPrint("MTVoiceController.setEnableListening enabled")
            speechRecognizer?.startListening()
        } else {
            debugPrint("MTVoiceController.setEnableListening disabled")
            speechRecognizer?.stopListening()
        }
        NSSound(named: "Whit")?.play()
    }
    
    //TODO notification probably doesnt work
    func speechRecognizer(_ sender: NSSpeechRecognizer, didRecognizeCommand: String) {
        if let index = cmds.index(of: didRecognizeCommand) {
            let act = codes[index]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VC_VOICE_COMMAND"), object: nil, userInfo: ["VC_VOICE_COMMAND":act])
        } else {
            debugPrint("speech recognizer command \(didRecognizeCommand) not programmed")
        }
    }
}
