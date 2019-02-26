//
//  MessagesListView.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/25/19.
//

import Cocoa

@objc class MessagesListView: DRStringList {

    var universe: Universe?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        universe = Universe.defaultInstance()
        
        notificationCenter?.addObserver(self, selector: #selector(newMessage), name: "SP_S_MESSAGE", object: nil, useLocks: false, useMainRunLoop: true)
        notificationCenter?.addObserver(self, selector: #selector(newMessage), name: "PM_MESSAGE", object: nil, useLocks: false, useMainRunLoop: false)
        notificationCenter?.addObserver(self, selector: #selector(newMessage), name: "SPW_MESSAGE", object: nil, useLocks: false, useMainRunLoop: true)
        notificationCenter?.addObserver(self, selector: #selector(newMessageInDictionary), name: "SP_MESSAGE", object: nil, useLocks: false, useMainRunLoop: true)
        notificationCenter?.addObserver(self, selector: #selector(disableSelection), name: "PV_PLAYER_SELECTION")
        notificationCenter?.addObserver(self, selector: #selector(emptyAllRows), name: "LM_LOGIN_COMPLETE")
    }
    @objc func newMessage(_ message: NSString) {
        if message == nil || message.length <= 0 {
            return
        }
        debugPrint("messagesListView.newMessage \(message)")
        notificationCenter?.postNotificationName("MV_NEW_MESSAGE", userInfo: message)
    }
    @objc func newMessageInDictionary(_ package: NSDictionary) {
        guard let message = package.object(forKey: "message") as? NSString else {
            debugPrint("messagelistview got nil message in dictionary")
            return
        }
        guard let flags = package.object(forKey: "flags") as? Int else {
            debugPrint("messagelistview got nil flags in dictionary")
            return
        }
        guard let from = package.object(forKey: "from") as? Int else {
            debugPrint("messagelistview got nil from in dictionary")
            return
        }
        var color = NSColor.gray
        if from >= 0 && from < UNIVERSE_MAX_PLAYERS {
            color = universe?.player(withId: Int32(from)).team().colorForTeam() ?? NSColor.gray
        }
        // A new type distress/macro call came in. parse it appropriately
        if flags == TEAM || flags == DISTR || flags == VALID {
            debugPrint("MessagesListView.newMessageInDictionary distress not parsed \(message)")
            return
        }
        self.addString(str: message as NSString, withColor: color)
        notificationCenter?.postNotificationName("MV_NEW_MESSAGE", object: self, userInfo: message)
    }
    override func newStringSelected(_ str: NSString) {
        notificationCenter?.postNotificationName("MV_MESSAGE_SELECTION", object: self, userInfo: str)
    }
}
