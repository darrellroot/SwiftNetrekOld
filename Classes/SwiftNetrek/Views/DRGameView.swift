//
//  DRGameView.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/26/19.
//

import Cocoa

class DRGameView: DRBaseView {

    var warMask: Int32 = 0
    var warTeam: Team? = nil
    var step = GV_SCALE_STEP
    var actionKeyMap: MTKeyMap? = nil
    var distressKeyMap: MTKeyMap? = nil
    var mouseMap: MTMouseMap? = nil
    var scale = 40
    let trigonometry = LLTrigonometry.defaultInstance()
    let angleConvertor = Entity()
    let screenshotController = LLScreenShotController()
    var busyDrawing = false
    var inputMode: Int32 = GV_NORMAL_MODE
    let properties = LLObject.properties()
    var painter: PainterFactory?
    let MAX_WAIT_BEFORE_DRAW = (1.0/(2.0*Double(FRAME_RATE)))

    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(voiceCommand), name: NSNotification.Name(rawValue: "VC_VOICE_COMMAND"), object: nil)
        notificationCenter?.addObserver(self, selector: #selector(settingsChanged), name: "SC_NEW_SETTINGS")
        self.settingsChanged(nil)
    }
    @objc func settingsChanged(_ settingsController: SettingsController?) {
        actionKeyMap = properties?.object(forKey: "ACTION_KEYMAP") as? MTKeyMap
        distressKeyMap = properties?.object(forKey: "DISTRESS_KEYMAP") as? MTKeyMap
        mouseMap = properties?.object(forKey: "MOUSE_MAP") as? MTMouseMap
    }
    @objc func voiceCommand(_ notification: NSNotification) {
        //let mousePos = self.mousePos
        if let action = notification.userInfo?["VC_VOICE_COMMAND"] as? Int32 {
            debugPrint("DRGameView:voiceCommand received \(action)")
            _ = self.performAction(action)
        } else {
            debugPrint("DRGameView:voiceCommand ignored \(String(describing: notification.userInfo))")
        }
    }
    @objc func makeFirstResponder() {
        self.window?.makeFirstResponder(self)
    }
    @objc func setPainter(_ newPainter: PainterFactory) {
        painter = newPainter
        inputMode = GV_NORMAL_MODE
    }
    func gamePointRepresentingCentreOfView() -> NSPoint {
        return universe!.playerThatIsMe()!.predictedPosition()
    }
    func setScaleFullView() {
        let viewSize = self.bounds.size
        let minSize = min(viewSize.height,viewSize.width)
        scale = Int(UNIVERSE_PIXEL_SIZE) / Int(minSize)
    }
    func setScale(_ newScale: Int) {
        scale = newScale
    }
    override func draw(_ aRect: NSRect) {
        super.draw(aRect)
        if busyDrawing {
            debugPrint("DRGameView busy drawing")
            return
        }
        busyDrawing = true
        let lock = universe?.synchronizeAccess()?.lock(before: Date(timeIntervalSinceNow: MAX_WAIT_BEFORE_DRAW))
        if lock == false {
            debugPrint("DRGameView:draw waited \(MAX_WAIT_BEFORE_DRAW) for lock, drawing anyway")
        }
        if let gameBounds = painter?.gameRectAround(self.gamePointRepresentingCentreOfView(), forView: self.bounds, withScale: Int32(scale)){
            painter?.draw(aRect, ofViewBounds: self.bounds, whichRepresentsGameBounds: gameBounds, withScale: Int32(scale))
        } else {
            debugPrint("DRGameView:draw unable to calculate gameBounds")
        }
        if lock == true {
            universe?.synchronizeAccess().unlock()
        }
        busyDrawing = false
    }
    override func keyDown(with event: NSEvent) {
        if actionKeyMap == nil {
            debugPrint("DRGameView:keyDown have no keymap")
            super.keyDown(with: event)
        }
        switch (inputMode) {
        case GV_NORMAL_MODE:
            self.normalModeKeyDown(event)
        case GV_MESSAGE_MODE:
            self.messageModeKeyDown(event)
        case GV_MACRO_MODE:
            self.macroModeKeyDown(event)
        case GV_REFIT_MODE:
            self.refitModeKeyDown(event)
        case GV_WAR_MODE:
            self.warModeKeyDown(event)
        default:
            debugPrint("DRGameView.keydown unknown mode \(inputMode)")
            inputMode = GV_NORMAL_MODE
        }
    }
    func normalModeKeyDown(_ theEvent: NSEvent) {
        guard let characters = theEvent.characters else {
            debugPrint("DRGameView:normalModeKeyDown no characters detected for event \(theEvent)")
            return
        }
        let modifierFlags = theEvent.modifierFlags
        for character in characters.utf8 {
            // current implementation allows sending of distress calls by holding down the control key
            if modifierFlags.contains(.control) {
                guard let targetGamePoint = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
                    debugPrint("DRGameView.normalModeKeyDown unable to determine targetGamePoint")
                    return
                }
            macroHandler.setGameViewPointOfCursor(targetGamePoint)
                guard let char = theEvent.charactersIgnoringModifiers?.utf8.first else {
                    debugPrint("DRGameView.normalModeKeyDown unable to determine control character")
                    return
                }
                guard let distressCode = distressKeyMap?.action(forKey: Int8(char), withModifierFlags: UInt32(modifierFlags.rawValue)) else {
                    debugPrint("GameView.keydown nil distress code")
                    return
                }
                guard distressCode != DC_UNKNOWN else {
                    super.keyDown(with: theEvent)
                    return
                }
                let useRCD = properties?.value(forKey: "USE_RCD") as? Bool
                if useRCD ?? false {
                    debugPrint("GameView.keydown sending RCD \(distressCode)")
                    macroHandler.sendReceiverConfigureableDistress(distressCode)
                } else {
                    debugPrint("GameView.keydown sending Macro distress \(distressCode)")
                    macroHandler.sendDistress(distressCode)
                }
                return
            } else {
                //modifier flags do not contain control
                //must be chaos! - DR
                guard let action = actionKeyMap?.action(forKey: Int8(character), withModifierFlags: UInt32(modifierFlags.rawValue)) else {
                    debugPrint("DRGameView normalModeKeyDown unable to identify action")
                    return
                }
                guard action != ACTION_UNKNOWN else {
                    super.keyDown(with: theEvent)
                    return
                }
                guard self.performAction(action) else {
                    super.keyDown(with: theEvent)
                    return
                }
                return
            }
        }
    }
    func messageModeKeyDown(_ theEvent: NSEvent) {
        // always reset
        inputMode = GV_NORMAL_MODE
        // fish for [A|G|T|F|K|O|R|0..f]
        // create address and send the event
        
        // going for the first char only
        guard let theChar = theEvent.characters?.first else {
            debugPrint("DRGameView.messageModeKeyDown unable to get first character from event \(theEvent)")
            return
        }
        var playerId: Int?
        switch theChar {
        case "A":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "ALL")
            return
        case "G":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "GOD")
            return
        case "t":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "TEAM")
            return
        case "F":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "FED")
            return
        case "K","k":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "KLI")
            return
        case "R","r":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "ROM")
            return
        case "O","o":
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: "ORI")
            return
        case "0":
            playerId = 0
        case "1":
            playerId = 1
        case "2":
            playerId = 2
        case "3":
            playerId = 3
        case "4":
            playerId = 4
        case "5":
            playerId = 5
        case "6":
            playerId = 6
        case "7":
            playerId = 7
        case "8":
            playerId = 8
        case "9":
            playerId = 9
        case "a":
            playerId = 10
        case "b":
            playerId = 11
        case "c":
            playerId = 12
        case "d":
            playerId = 13
        case "e":
            playerId = 14
        case "f":
            playerId = 15
        case "g":
            playerId = 16
        case "h":
            playerId = 17
        case "i":
            playerId = 18
        case "j":
            playerId = 19
        //case "k":
        //    playerId = 20
        case "l":
            playerId = 21
        case "m":
            playerId = 22
        case "n":
            playerId = 23
        //case "o":
        //    playerId = 24
        case "p":
            playerId = 25
        case "q":
            playerId = 26
        //case "r":
        //    playerId = 27
        case "s":
            playerId = 28
        case "T":  // swap t and T
            playerId = 29
        case "u":
            playerId = 30
        case "v":
            playerId = 31
        default:
            notificationCenter?.postNotificationName("PM_WARNING", userInfo: "Unknown player. message not sent.")
            return
        }
        if let playerId = playerId {
            debugPrint("DRGameView.messageModeKeyDown character \(theChar) playerId \(playerId)")
            notificationCenter?.postNotificationName("GV_MESSAGE_DEST", userInfo: [universe?.player(withId: Int32(playerId)).mapChars])
        } else {
            debugPrint("DRGameView.messageModeKeyDown character \(theChar) unable to identify playerId")
        }
        return
    }
    func macroModeKeyDown(_ theEvent: NSEvent) {
        debugPrint("GameView.macroModeKeyDown not implemented")
        inputMode = GV_NORMAL_MODE
    }
    func refitModeKeyDown(_ theEvent: NSEvent) {
        inputMode = GV_NORMAL_MODE
        var ship_type = SHIP_CA

        guard let theChar = theEvent.characters?.first else {
            debugPrint("DRGameView.refitModeKeyDown unable to identify theChar")
            return
        }
        switch theChar {
        case "s","S":
            ship_type = SHIP_SC
        case "d","D":
            ship_type = SHIP_DD
        case "c","C":
            ship_type = SHIP_CA
        case "b","B":
            ship_type = SHIP_BB
        case "g","G":
            ship_type = SHIP_GA
        case "o","O":
            ship_type = SHIP_SB
        case "a","A":
            ship_type = SHIP_AS
        default: return
        }
    notificationCenter?.postNotificationName("COMM_SEND_REFIT_REQ", userInfo: NSNumber(value: ship_type))
    }
    func warModeKeyDown(_ theEvent: NSEvent) {
        inputMode = GV_NORMAL_MODE
        guard warTeam != nil else {
            debugPrint("DRGameView.warModeKeyDown no team selected")
            return
        }
        guard let theChar = theEvent.characters?.first else {
            debugPrint("DRGameView.warModeKeyDown unable to get theChar")
            warTeam = nil
            return
        }
        switch theChar {
        case "h":
            //they really want to declare war
            warMask = warMask | warTeam!.bitMask()
            debugPrint("DRGameView.warModeKeyDown declaring hostile on \(warTeam!.abbreviation)")
            notificationCenter?.postNotificationName("COMM_SEND_WAR_REQ", userInfo: NSNumber(value: warMask))
            notificationCenter?.postNotificationName("GV_MODE_INFO", userInfo: "Declaring War on \(warTeam!.abbreviation)")
        case "p":
            // they really want to declare peace
            warMask = warMask & ~(warTeam!.bitMask())
            debugPrint("DRGameView.warModeKeyDown declaring peace on \(warTeam!.abbreviation)")
            notificationCenter?.postNotificationName("COMM_SEND_WAR_REQ", userInfo: NSNumber(value:warMask))
        default:
            debugPrint("DRGameView.warModeKeyDown player did not choose war h or peace p theChar \(theChar)")
        }
        //always clear the team
        warTeam = nil
    }
    override func mouseDown(with event: NSEvent) {
        if let actionMouseLeft = mouseMap?.actionMouseLeft() {
            _ = self.performAction(actionMouseLeft)
        } else {
            debugPrint("DRGameView unable to decode mousedownleft")
        }
    }
    override func otherMouseDown(with event: NSEvent) {
        if let actionMouseMiddle = mouseMap?.actionMouseMiddle() {
            _ = self.performAction(actionMouseMiddle)
        } else {
            debugPrint("DRGameView unable to decode mousedownmiddle")
        }
    }
    override func rightMouseDown(with event: NSEvent) {
        if let actionMouseRight = mouseMap?.actionMouseRight() {
            _ = self.performAction(actionMouseRight)
        } else {
            debugPrint("DRGameView unable to decode mousedownright")
        }
    }
    override func mouseDragged(with event: NSEvent) {
        self.mouseDown(with: event)
    }
    override func otherMouseDragged(with event: NSEvent) {
        self.otherMouseDown(with: event)
    }
    
    // there should be an action for that and a button but leave it
    // static for now
    override func scrollWheel(with event: NSEvent) {
        let mouseRole = event.deltaY
        // 1.0 means zoom in
        // -1.0 means zoom out
        if mouseRole > 0 {
            // zoom in means smaller scale factor
            var newScale = scale - Int(step) * scale
            if newScale == scale {
                newScale = scale - 1 // at least 1
            }
            // if scale is small it may not be possible to zoom in
            // scale*step = 0;
            if let minScale = painter?.minScale(), newScale > minScale {
                scale = newScale
            } else {
                debugPrint("DRGameView.scrollWheel failed to adjust scale oldScale \(scale) proposed newScale \(newScale)")
            }
            return
        }
        if mouseRole < 0 {
            // zoom out means larger factor
            // if scale is small it may not be possible to zoom out
            // scale*step = 0 this means you'll stay zoomed in
            var newScale = scale + Int(step) * scale
            if newScale == scale {
                newScale = scale + 1  // at least 1
            }
            if let maxScale = painter?.maxScale(), newScale < maxScale {
                scale = newScale
            } else {
                debugPrint("DRGameView.scrollWheel failed to adjust scale oldScale \(scale) proposed newScale \(newScale)")
            }
        }
    }
    func sendSpeedReq(speed: Int) {
        guard let universe = universe else {
            debugPrint("DRGameView.sendSpeedReq have no universe?")
            return
        }
        
        let maxSpeed = universe.playerThatIsMe().ship().maxSpeed()
        let newSpeed: Int32
        if speed > maxSpeed {
            newSpeed = maxSpeed
        } else {
            newSpeed = Int32(speed)
        }
        universe.playerThatIsMe().setRequestedSpeed(newSpeed)
        notificationCenter?.postNotificationName("COMM_SEND_SPEED_REQ", userInfo: NSNumber(value: newSpeed))
        debugPrint("DRGameView.sendSpeedReq set speed to \(newSpeed)")
    }
    func mouseDir() -> Float {
        guard let mouseLocation = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
            debugPrint("DRGameView.mouseDir unable to calculate mouseLocation")
            return 0.0
        }
        guard let ourLocation = universe?.playerThatIsMe()?.predictedPosition() else {
            debugPrint("DRGameView.mouseDir unable to calculate my position")
            return 0.0
        }
        guard var dir = trigonometry?.angleDegBetween(mouseLocation, andPoint: ourLocation) else {
            debugPrint("DRGameView.mouseDir unable to access trigonometry")
            return 0.0
        }
        dir = dir - 90 //north is 0 degree
        if dir < 0 {
            dir = dir + 360
        }
        return dir
    }
    // $$ may need locks here if the code becomes multi threaded
    func performAction(_ action: Int32) -> Bool {
        //var target: Player?
        //var planet: Planet?
        //var targetGamePoint: NSPoint?
        guard let me = universe?.playerThatIsMe() else {
            debugPrint("DRGameView.performAction who am I?")
            return false
        }
        switch action {
        case ACTION_UNKNOWN:
            debugPrint("DRGameView.performAction unknown action \(action)")
            return false
        case ACTION_CLOAK:
            if (me.flags() & PLAYER_CLOAK) != 0 {
                notificationCenter?.postNotificationName("COMM_SEND_CLOAK_REQ", userInfo: NSNumber(value: false))
            } else {
                notificationCenter?.postNotificationName("COMM_SEND_CLOAK_REQ", userInfo: NSNumber(value: true))
            }
        case ACTION_DET_ENEMY:
            // $$ JTrek checks if current time - last det time > 100 ms before sending this again
            // sounds sensible...
            notificationCenter?.postNotificationName("COMM_SEND_DETONATE_REQ", userInfo: nil)
        case ACTION_DET_OWN:
            notificationCenter?.postNotificationName("COMM_SEND_DET_MINE_ALL_REQ", userInfo: nil)
        case ACTION_FIRE_PLASMA:
            angleConvertor.setCourse(Int32(self.mouseDir()))
            let netrekCourse = angleConvertor.netrekFormatCourse()
            notificationCenter?.postNotificationName("COMM_SEND_PLASMA_REQ", userInfo: NSNumber(value: netrekCourse))
        case ACTION_FIRE_TORPEDO:
            angleConvertor.setCourse(Int32(self.mouseDir()))
            let netrekCourse = angleConvertor.netrekFormatCourse()
            notificationCenter?.postNotificationName("COMM_SEND_TORPS_REQ", userInfo: NSNumber(value: netrekCourse))
        case ACTION_FIRE_PHASER:
            angleConvertor.setCourse(Int32(self.mouseDir()))
            let netrekCourse = angleConvertor.netrekFormatCourse()
            notificationCenter?.postNotificationName("COMM_SEND_PHASER_REQ", userInfo: NSNumber(value: netrekCourse))
        case ACTION_SHIELDS:
            if (me.flags() & PLAYER_SHIELD) != 0 {
                notificationCenter?.postNotificationName("COMM_SEND_SHIELD_REQ", userInfo: NSNumber(value: false))

            } else {
                notificationCenter?.postNotificationName("COMM_SEND_SHIELD_REQ", userInfo: NSNumber(value: true))

            }
        case ACTION_TRACTOR:
            guard let targetGamePoint = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
                debugPrint("DRGameView.action_tractor unable to identify targetGamePoint")
                return false
            }
            guard let target = universe?.playerNearPosition(targetGamePoint, ofType: UNIVERSE_TARG_PLAYER) else {
                debugPrint("DRGameView action tractor unable to identify target")
                return false
            }
            // if we are already tractoring disable:
            if me.flags() & PLAYER_TRACT != 0 {
                notificationCenter?.postNotificationName("COMM_SEND_TRACTOR_OFF_REQ", userInfo: NSNumber(value: target.playerId()))
            } else {
                notificationCenter?.postNotificationName("COMM_SEND_TRACTOR_ON_REQ", userInfo: NSNumber(value: target.playerId()))
                me.setTractorTarget(target)
            }
        // end ACTION TRACTOR
        case ACTION_PRESSOR:
            guard let targetGamePoint = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
                debugPrint("DRGameView.action_pressor unable to identify targetGamePoint")
                return false
            }
            guard let target = universe?.playerNearPosition(targetGamePoint, ofType: UNIVERSE_TARG_PLAYER) else {
                debugPrint("DRGameView action pressor unable to identify target")
                return false
            }
            // if we are already pressoring disable:
            if me.flags() & PLAYER_PRESS != 0 {
                notificationCenter?.postNotificationName("COMM_SEND_REPRESSOR_OFF_REQ", userInfo: NSNumber(value: target.playerId()))
            } else {
                notificationCenter?.postNotificationName("COMM_SEND_REPRESSOR_ON_REQ", userInfo: NSNumber(value: target.playerId()))
                me.setTractorTarget(target)
            }
        case ACTION_WARP_0:
            self.sendSpeedReq(speed: 0)
        case ACTION_WARP_1:
            self.sendSpeedReq(speed: 1)
        case ACTION_WARP_2:
            self.sendSpeedReq(speed: 2)
        case ACTION_WARP_3:
            self.sendSpeedReq(speed: 3)
        case ACTION_WARP_4:
            self.sendSpeedReq(speed: 4)
        case ACTION_WARP_5:
            self.sendSpeedReq(speed: 5)
        case ACTION_WARP_6:
            self.sendSpeedReq(speed: 6)
        case ACTION_WARP_7:
            self.sendSpeedReq(speed: 7)
        case ACTION_WARP_8:
            self.sendSpeedReq(speed: 8)
        case ACTION_WARP_9:
            self.sendSpeedReq(speed: 9)
        case ACTION_WARP_10:
            self.sendSpeedReq(speed: 10)
        case ACTION_WARP_11:
            self.sendSpeedReq(speed: 11)
        case ACTION_WARP_12:
            self.sendSpeedReq(speed: 12)
        case ACTION_WARP_MAX:
            let maxSpeed = me.ship().maxSpeed()
            self.sendSpeedReq(speed: Int(maxSpeed))
        case ACTION_WARP_HALF_MAX:
            let maxSpeed = me.ship().maxSpeed()
            self.sendSpeedReq(speed: Int(maxSpeed/2))
        case ACTION_WARP_INCREASE:
            let speed = Int(me.speed()) + 1
            let maxSpeed = Int(me.ship().maxSpeed())
            let newSpeed = min(speed, maxSpeed)
            self.sendSpeedReq(speed: newSpeed)
        case ACTION_WARP_DECREASE:
            var speed = Int(me.speed()) - 1
            if speed < 0 { speed = 0 }
            self.sendSpeedReq(speed: speed)
        case ACTION_SET_COURSE:
            angleConvertor.setCourse(Int32(self.mouseDir()))
            let netrekFormatCourse = angleConvertor.netrekFormatCourse()
            notificationCenter?.postNotificationName("COMM_SEND_DIR_REQ", userInfo: NSNumber(value: netrekFormatCourse))
            // remove the planet lock
            let newFlags = me.flags() & ~PLAYER_PLOCK & ~PLAYER_PLLOCK
            me.setFlags(newFlags)
        case ACTION_LOCK:
            guard let targetGamePoint = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
                debugPrint("DRGameView.action_lock unable to identify targetGamePoint")
                return false
            }
            guard let target = universe?.playerNearPosition(targetGamePoint, ofType: UNIVERSE_TARG_PLAYER) else {
                debugPrint("DRGameView action lock unable to identify target")
                return false
            }
            guard let planet = universe?.planetNearPosition(targetGamePoint) else {
                debugPrint("DRGameView action lock unable to identify nearest planet")
                return false
            }
            if universe!.entity(target, closerToPos: targetGamePoint, than: planet) {
                // lock on player
                notificationCenter?.postNotificationName("COMM_SEND_PLAYER_LOCK_REQ", userInfo: NSNumber(value: target.playerId()))
            } else {
                // lock on planet
                notificationCenter?.postNotificationName("COMM_SEND_PLANET_LOCK_REQ", userInfo: NSNumber(value: planet.planetId()))
                me.setPlanetLock(planet)
            }
        case ACTION_PRACTICE_BOT:
            notificationCenter?.postNotificationName("COMM_SEND_PRACTICE_REQ")
        case ACTION_TRANSWARP:
            // netrek uses the same message for this, it could lead to very
            // funny results now we seperate it.
        notificationCenter?.postNotificationName("COMM_SEND_PRACTICE_REQ")
        case ACTION_BOMB:
            if me.flags() & PLAYER_BOMB == 0 {
                // not already bombing
                notificationCenter?.postNotificationName("COMM_SEND_BOMB_REQ", userInfo: NSNumber(value: true))
            }
        case ACTION_ORBIT:
            notificationCenter?.postNotificationName("COMM_SEND_ORBIT_REQ", userInfo: NSNumber(value: true))
        case ACTION_BEAM_DOWN:
            if me.flags() & PLAYER_BEAMDOWN == 0 {
                // not already beaming
                notificationCenter?.postNotificationName("COMM_SEND_BEAM_REQ", userInfo: NSNumber(value: false))
                // false means down
            }
        case ACTION_BEAM_UP:
            if me.flags() & PLAYER_BEAMUP == 0 {
                // not already beaming
                notificationCenter?.postNotificationName("COMM_SEND_BEAM_REQ", userInfo: NSNumber(value: true))
            }
        case ACTION_DISTRESS_CALL:
            macroHandler.sendDistress(DC_GENERIC)
        case ACTION_ARMIES_CARRIED_REPORT:
            macroHandler.sendDistress(DC_CARRYING)
        case ACTION_MESSAGE:
            debugPrint("DRGameView sending action message")
            notificationCenter?.postNotificationName("GV_MODE_INFO", userInfo: "A=all, [TFORK]=team, [0..f]=player")
            inputMode = GV_MESSAGE_MODE
            // next keystroke gets handled differently and will cause the
            // destination to be set and may set the focus to input panel.
        case ACTION_DOCK_PERMISSION:
            if me.flags() & PLAYER_DOCKOK == 0 {
                notificationCenter?.postNotificationName("COMM_SEND_DOCK_REQ", userInfo: NSNumber(value: true))
            } else {
                notificationCenter?.postNotificationName("COMM_SEND_DOCK_REQ", userInfo: NSNumber(value: false))
            }
        case ACTION_INFO:
            // convert the mouse pointer to a point in the game grid
            guard let targetGamePoint = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
                debugPrint("DRGameView.action_info unable to identify targetGamePoint")
                return false
            }
            guard let target = universe?.playerNearPosition(targetGamePoint, ofType: UNIVERSE_TARG_PLAYER) else {
                debugPrint("DRGameView action info unable to identify target")
                return false
            }
            guard let planet = universe?.planetNearPosition(targetGamePoint) else {
                debugPrint("DRGameView action info unable to identify nearest planet")
                return false
            }
            if universe!.entity(target, closerToPos: targetGamePoint, than: planet) {
                // I don't understand this - DR
                // toggle info on player
                if !target.isMe() { // im already showing
                    universe?.resetShowInfoPlanets() // close any other one
                    target.setShowInfo(target.showInfo())
                }
            } else {
                universe?.resetShowInfoPlanets() // close any other one
                planet.setShowInfo(planet.showInfo())
            }
        case ACTION_REFIT:
            notificationCenter?.postNotificationName("GV_MODE_INFO", userInfo: "s=scout, d=destroyer, c=cruiser, b=battleship, a=assault, g=galaxy, o=starbase")
            inputMode = GV_REFIT_MODE
            // next keystroke gets handled ifferently
        case ACTION_WAR:
            guard let targetGamePoint = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale)) else {
                debugPrint("DRGameView.action_info unable to identify targetGamePoint")
                return false
            }
            guard let planet = universe?.planetNearPosition(targetGamePoint) else {
                debugPrint("DRGameView action info unable to identify nearest planet")
                return false
            }
            guard let warTeam = planet.owner() else {
                debugPrint("DRGameView action war unable to identify war team from nearest planet")
                return true
            }
            if me.team() == warTeam {
                notificationCenter?.postNotificationName("GV_MODE_INFO", userInfo: "Civil war not allowed")
                return true
            }
            if warTeam.teamId() < TEAM_FED || warTeam.teamId() < TEAM_ORI {
                notificationCenter?.postNotificationName("GV_MODE_INFO", userInfo: "No contact with that goverment")
                return false
            }
            notificationCenter?.postNotificationName("GV_MODE_INFO", userInfo: "Declare h=hostile or p=peace on \(warTeam.abbreviation())")
            inputMode = GV_WAR_MODE
            
            // next keystroke gets handled differently
        case ACTION_REPAIR:
            notificationCenter?.postNotificationName("COMM_SEND_REPAIR_REQ", userInfo: NSNumber(value: true))
        case ACTION_QUIT:
            notificationCenter?.postNotificationName("COMM_SEND_QUIT_REQ")
        case ACTION_HELP:
            notificationCenter?.postNotificationName("GV_SHOW_HELP")
            debugPrint("DRGameView perform action help should raise panel")
        case ACTION_DEBUG:
            if let currentDebug = painter?.debugLabels() {
                painter?.setDebugLabels(!currentDebug)
            } else {
                debugPrint("DRGameView perform action debug unable to identify current debug label status")
                painter?.setDebugLabels(false)
            }
        case ACTION_SCREENSHOT:
            screenshotController.snap()
        case ACTION_COUP:
            debugPrint("DRGameView perform action coup sending coup request")
            notificationCenter?.postNotificationName("COMM_SEND_COUP_REQ")
        default:
            debugPrint("DRGameView perform action unknown action \(action)")
            return false
        }
        return true
    }
}
