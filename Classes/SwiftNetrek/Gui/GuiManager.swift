//
//  GuiManager.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/27/19.
//

import Foundation
import AppKit

enum GameState: String {
    case noServerSelected
    case serverSelected
    case serverConnected
    case serverSlotFound
    case loginAccepted
    case outfitAccepted
    case gameActive
}
class GuiManager: NSObject, NSApplicationDelegate {
    let frameRate = 10
    //
    // The GuiManger maintains (among others) the game state machine, or to be precise the state machine that handles
    // the changes between the menus. It uses the following table to jump between states and specifies which events
    // trigger a state change
    //                     State          1          2          3          4          5          7          8
    // Event                              no       server     server     slot       login      outfit     game
    //                                  server    selected   contacted   found     accepted   accepted   entered
    //                                 selected
    // MS_SERVER_SELECT                   2          2          2          2          2
    // LOGIN button pressed                                                5          5
    // CC_SERVER_CALL_SUCCESS                        3
    // CC_SERVER_CALL_FAILED                         1
    // CC_SLOT_FOUND                                            4
    // LM_LOGIN_INVALID_SERVER                                             1
    // LM_LOGIN_COMPLETE                                                              7
    // OM_ENTER_GAME                                                                             8
    // CC_GO_OUTFIT                                                                                        7
    // CC_GO_LOGIN                                                                                         5
    //
    // AddOn: there actually is a state 0 (begin state) that shows the splashScreen. The Splash Screen waits for
    //        a number of events before it raises the menu pane and allows the game to start
    var clientRuns = false
    var firstGame = true
    var startUpEvents = 0
    var quickConnectBool = false
    var defaultName = "guest"
    var defaultPassword = ""
    let multiThreaded = true
    let mutex = NSLock()
    let client = ClientController()
    var soundPlayerTheme1: SoundPlayerForNetrek!
    var soundPlayerTheme2: SoundPlayerForMacTrek!
    var soundPlayerTheme3: SoundPlayerForTac!
    var painterTheme1: PainterFactoryForNetrek!
    var painterTheme2: PainterFactoryForMacTrek!
    var painterTheme3: PainterFactoryForTac!
    var tipCntrl: MTTipOfTheDayController!
    var gameState = GameState.noServerSelected
    let notificationCenter = LLNotificationCenter.default()
    let properties = LLObject.properties()
    let nrOfEventsBeforeShowingMenu = 7
    var server: ServerControllerNew!
    var service: NetService!
    var timer: Timer?
    var startTime = Date.timeIntervalSinceReferenceDate
    let showTime = false
    var lastStartTime = Date.timeIntervalSinceReferenceDate
    var currentServer: MetaServerEntry?
    var helpWindowCntrl: LLHUDWindowController? // new keyMapPanel implementation

    
    var soundPlayerActiveTheme: SoundPlayer?
    var painterActiveTheme: PainterFactory?
    var activeTheme: Int32?
    
    var keyMapMode = 0 // 0 = invisible, 1 = action keys, 2 is macro keys
    var showActionKeys = true

    @IBOutlet weak var outfitCntrl: OutfitMenuController!
    @IBOutlet weak var loginCntrl: LoginController!
    @IBOutlet weak var gameCntrl: GameController!
    @IBOutlet weak var startUpProgress: NSLevelIndicator!
    @IBOutlet weak var menuButton: NSButton!
    @IBOutlet weak var menuCntrl: MenuController!
    @IBOutlet weak var versionString: NSTextField!
    @IBOutlet weak var selectServerCntrl: SelectServerController!
    @IBOutlet weak var localServerCntrl: LocalServerController!
    @IBOutlet weak var keyMapPanel: NSPanel!
    @IBOutlet weak var settingsCntrl: SettingsController!


    override init() {
        super.init()
        soundPlayerActiveTheme = soundPlayerTheme2
        painterActiveTheme = painterTheme2
        notificationCenter?.addObserver(self, selector: #selector(serverSelected), name: "MS_SERVER_SELECTED")
        notificationCenter?.addObserver(self, selector: #selector(serverSlotFound), name: "CC_SLOT_FOUND")
        notificationCenter?.addObserver(self, selector: #selector(serverDeselected), name: "LC_INVALID_SERVER")
        notificationCenter?.addObserver(self, selector: #selector(loginComplete), name: "LC_LOGIN_COMPLETE")
        notificationCenter?.addObserver(self, selector: #selector(outfitAccepted), name: "SP_PICKOK")
        notificationCenter?.addObserver(self, selector: #selector(loginComplete), name: "SP_PICKNOK")
        notificationCenter?.addObserver(self, selector: #selector(serverDeselected), name: "SP_QUEUE")
        notificationCenter?.addObserver(self, selector: #selector(iDied), name: "CC_GO_OUTFIT")
        notificationCenter?.addObserver(self, selector: #selector(commError), name: "COMM_TCP_WRITE_ERROR")
        notificationCenter?.addObserver(self, selector: #selector(increaseStartUpCounter), name: "PF_IMAGES_CACHED")
        notificationCenter?.addObserver(self, selector: #selector(gotSPSounds), name: "SP_SOUNDS_CACHED")
        notificationCenter?.addObserver(self, selector: #selector(settingsChanged), name: "SC_NEW_SETTINGS")
        notificationCenter?.addObserver(self, selector: #selector(showKeyMapPanel), name: "GV_SHOW_HELP")
        notificationCenter?.addObserver(self, selector: #selector(focusToGameView), name: "COMM_SEND_MESSAGE")
        notificationCenter?.addObserver(self, selector: #selector(quickConnect), name: "SC_QUICK_CONNECT_STAGE_2")
        notificationCenter?.addObserver(self, selector: #selector(shutdown), name: "MC_MACTREK_SHUTDOWN")
        soundPlayerTheme1 = SoundPlayerForNetrek()
        soundPlayerTheme2 = SoundPlayerForMacTrek()
        soundPlayerTheme3 = SoundPlayerForTac()
        painterTheme1 = PainterFactoryForNetrek()
        painterTheme2 = PainterFactoryForMacTrek()
        painterTheme3 = PainterFactoryForTac()
        tipCntrl = MTTipOfTheDayController()
        server = ServerControllerNew()
        service = NetService()
    }
    @objc func gotSPSounds() {
        debugPrint("GuiManager got SPSounds")
        self.increaseStartUpCounter()
    }
    @objc func settingsChanged(_ settingsController: SettingsController) {
        self.setTheme()
    }
    @objc func quickConnect(_ entry: MetaServerEntry) {
        debugPrint("GuiManager.quickConnect server \(entry.address) \(String(describing: properties?.object(forKey:"USERNAME")))")
        quickConnectBool = true
    }
    func quickConnectAutoLogin() {
        debugPrint("GuiManager.quickConnectAutoLogin: logging in with \(defaultName)")
        notificationCenter?.postNotificationName("GM_SEND_LOGIN_REQ", object: nil, userInfo: [
            "name":defaultName,
            "pass":defaultPassword,
            "login":NSUserName(),
            "query":NSNumber(value: 0)
            ])
    }
    func quickConnectPickTeamShip() {
        debugPrint("GuiManager.quickConnectPickTeamShip")
        outfitCntrl.setQuickConnect(true)
        outfitCntrl.findTeam()
        loginCntrl.reset()
    }
    func quickConnectComplete() {
        quickConnectBool = false
        outfitCntrl.setQuickConnect(false)
    }
    @objc func focusToGameView() {
        gameCntrl.gameView().makeFirstResponder()
    }
    @objc func shutdown() {
        server.stopServer()
        service.stop()
    }
    func playIntroSoundEffect() {
        soundPlayerActiveTheme?.playSoundEffect("INTRO_SOUND")
    }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        debugPrint("GuiManager.applicationShouldTerminate")
        self.shutdown()
        return NSApplication.TerminateReply.terminateNow
    }
    func gameStateAsString() -> NSString {
        return gameState.rawValue as NSString
    }
    @objc func increaseStartUpCounter() {
        startUpEvents = startUpEvents + 1
        startUpProgress.intValue = Int32(startUpEvents)
        startUpProgress.needsDisplay = true
        debugPrint("GuiManager.increaseStartUpCounter got event \(startUpEvents) of \(nrOfEventsBeforeShowingMenu)")
        
        if startUpEvents > nrOfEventsBeforeShowingMenu {
            debugPrint("GuiManager.increaseStartUpCounter did not expect event number \(startUpEvents)")
        }
        if startUpEvents >= nrOfEventsBeforeShowingMenu {
            self.playIntroSoundEffect()
            menuButton.isHidden = false
            menuButton.isEnabled = true
            menuButton.needsDisplay = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.menuCntrl?.leaveSplashScreen()
            }
            if tipCntrl.newVersionAvailable() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.tipCntrl.showNewVersionIndicationIfAvailable()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.tipCntrl.showTip()
                }
            }
        }
    }
    @IBAction func showNextTip(_ sender: Any) {
        tipCntrl.showTip()
    }
    override func awakeFromNib() {
        startUpProgress.maxValue = Double(nrOfEventsBeforeShowingMenu)
        self.setSyncScreenUpdateWithRead(false)
        loginCntrl.setMultiThreaded(multiThreaded)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        versionString.stringValue = version
        server.restartServer()
        if selectServerCntrl.findServer("localhost") == nil {
            let entry = MetaServerEntry()
            entry.setAddress("localhost")
            entry.setPort(2592)
            entry.setStatus(DEFAULT)
            entry.setGameType(BRONCO)
            selectServerCntrl.addServerPassivly(entry)
        }
        //NotificationCenter.default.addObserver(self, selector: #selector(killed), name: NSMenu.didChangeItemNotification, object: nil)
        self.setUpKeyMapPanel()
    }
    func setSyncScreenUpdateWithRead(_ enable: Bool) {
        timer?.invalidate()
        if (enable) {
            notificationCenter?.addObserver(self, selector: #selector(screenRefreshTimerFired), name: "SERVER_READER_READ_SYNC", object: nil, useLocks: false, useMainRunLoop: false)
            notificationCenter?.addObserver(self, selector: #selector(screenRefreshTimerFired), name: "GM_GAME_ENTERED", object: nil, useLocks: false, useMainRunLoop: false)
            notificationCenter?.addObserver(self, selector: #selector(screenRefreshTimerFired), name: "COMM_SEND_TEAM_REQ", object: nil, useLocks: false, useMainRunLoop: false)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1.0/Double(frameRate), target: self, selector: #selector(screenRefreshTimerFired), userInfo: nil, repeats: true)
        }
    }
    @objc func screenRefreshTimerFired(_ theTimer: Timer) {
        lastStartTime = startTime
        startTime = Date.timeIntervalSinceReferenceDate
        if showTime {
            debugPrint("GuiManager.screenRefreshTimerFired \(startTime - lastStartTime)")
        }
        
        if gameState == .gameActive {
            gameCntrl.repaint(Float(startTime - lastStartTime))
        }
        if showTime {
            debugPrint("GuiManager repaint took \(Date()-startTime))")
        }
    }
    @objc func serverSelected(_ selectedServer: MetaServerEntry) {
        quickConnectBool = false
        switch gameState {
        case .noServerSelected, .serverSelected:
            /* TODO selectedServer is not optional, this may not be needed
             if selectedServer == nil {
                self.serverDeselected()
                return
            }*/
            // when a server is selected, connect to it
            // to see if we can go to the login panel
            gameState = .serverSelected
            currentServer = selectedServer
            client.stop()
            if client.startClient(at: selectedServer.address(), port: selectedServer.port(), seperate: multiThreaded) {
                debugPrint("GuiManager.serverSelected connect to server successful")
                self.serverConnected()
            } else {
                debugPrint("GuiManager.serverSelected cannot connect to server")
                self.serverDeselected()
                selectServerCntrl.invalidServer()
            }
        case .serverConnected, .serverSlotFound, .loginAccepted:
            debugPrint("GuiManager.serverSelected reconnecting to \(selectedServer.address)")
            if let currentServer = currentServer {
                debugPrint("GuiManager.serverSelected disconnecting from \(currentServer.address)")
                self.serverDeselected()
            }
            // open to new
            self.serverSelected(selectedServer)
            currentServer = selectedServer
        case .outfitAccepted, .gameActive:
            debugPrint("GuiManager.serverSelected unexpected game state \(gameState.rawValue)")
            self.serverDeselected()
            menuCntrl.raiseMenu(self)
        }
    }
    @objc func serverDeselected() {
        gameState = .noServerSelected
        client.stop()
        menuCntrl.disableLogin()
        localServerCntrl.disableLogin()
        selectServerCntrl.disableLogin()
        // when we cannot type our name
        loginCntrl.disablePlayerName()
        loginCntrl.reset()
        currentServer = nil
        // get's also called to force our state back to deselection
        // so make sure nothing is selected after all
        selectServerCntrl.deselectServer(self)
        debugPrint("GuiManager.serverDeselected gameState = \(gameState.rawValue)")
    }
    @objc func serverConnected() {
        switch gameState {
        case .serverSelected:
            // nothing sepecial,
            // wait for a slot found
            gameState = .serverConnected
            debugPrint("GuiManager.serverConnected gameState \(gameState.rawValue)")
        case .serverSlotFound:
            debugPrint("GuiManager.serverConnected gameState \(gameState.rawValue)")
        case .serverConnected, .outfitAccepted, .gameActive, .loginAccepted, .noServerSelected:
            debugPrint("GuiManager.serverConnected unexpected game state \(gameState.rawValue) resetting")
            self.serverDeselected()
            menuCntrl.raiseMenu(self)
        }
    }
    @objc func serverSlotFound() {
        switch (gameState) {
        case .noServerSelected, .outfitAccepted:
            debugPrint("GuiManager.serverSlotFound unexpected gamestate \(gameState.rawValue) resetting")
            self.serverDeselected()
            menuCntrl.raiseMenu(self)
        case .serverConnected, .serverSelected, .gameActive:
            gameState = .serverSlotFound
            menuCntrl.enableLogin()
            localServerCntrl.enableLogin()
            selectServerCntrl.enableLogin()
            loginCntrl.enablePlayerName()
            loginCntrl.startClock()
            if !client.sendSlotSettingsToServer()  {
                debugPrint("GuiManager.serverSlotFound cannot send slot settings to server")
                self.serverDeselected()
            } else {
                debugPrint("GuiManager.serverSlotFound gamestate \(gameState.rawValue)")
                if (quickConnectBool) {
                    debugPrint("GuiManager.serverSlotFound calling autologin)")
                    self.quickConnectAutoLogin()
                }
            }
        case .serverSlotFound, .loginAccepted:
            debugPrint("GuiManager.serverSlotFound unexpectedGameState \(gameState.rawValue)")
        }
    }
    @objc func iDied() {
        //restore cursor if needed
        if NSCursor.current == NSCursor.crosshair {
            NSCursor.crosshair.pop()
        }
        keyMapPanel.close()  // remove help screen
        gameCntrl.stopGame()
        self.loginComplete()
    }
    @objc func loginComplete() {
        switch gameState {
        case .noServerSelected, .serverSelected, .serverConnected, .outfitAccepted:
            debugPrint("GuiManager.loginComplete unexpected gameState \(gameState) resetting")
            self.serverDeselected()
            menuCntrl.raiseMenu(self)
        case .loginAccepted: // when outfit is not accepted try again
            debugPrint("GuiManager.loginComplete login not accepted try again")
        case .serverSlotFound:
            gameState = .loginAccepted
            menuCntrl.disableLogin() //cannot login twice
            localServerCntrl.disableLogin()
            selectServerCntrl.disableLogin()
            loginCntrl.disablePlayerName()
            self.setTheme()
            menuCntrl.raiseOutfit(self)
            outfitCntrl.setInstructionFieldToDefault()
            // when we receive status messages, outfitCntrl updates the textfield
            // only as long as we are in outfit!!!
            notificationCenter?.addObserver(outfitCntrl, selector: #selector(OutfitMenuController.setInstructionField), name: "SP_WARNING", object: nil, useLocks: false, useMainRunLoop: true)
            if quickConnectBool {
                self.quickConnectPickTeamShip()
            }
        case .gameActive: // if we are killed we get back here
            outfitCntrl.setInstructionFieldToDefault()
            // when we receive status messages, outfitCntrl updates the textfield
            // only as long as we are in outfit!!!
            notificationCenter?.addObserver(outfitCntrl, selector: #selector(OutfitMenuController.setInstructionField), name: "SP_WARNING", object: nil, useLocks: false, useMainRunLoop: true)
            gameState = .loginAccepted
            menuCntrl.raiseOutfit(self)
        }
    }
    @objc func outfitAccepted() {
        switch gameState {
    case .noServerSelected, .serverSelected, .serverConnected, .outfitAccepted, .serverSlotFound, .gameActive:
            debugPrint("GuiManager.outfitAccepted unexpected gameState \(gameState.rawValue) resetting")
            self.serverDeselected()
            menuCntrl.setCanPlay(false)
            menuCntrl.raiseMenu(self)
        case .loginAccepted:
            gameState = .outfitAccepted
            notificationCenter?.removeObserver(outfitCntrl, name: "SP_WARNING")
            outfitCntrl.setInstructionFieldToDefault()
            menuCntrl.setCanPlay(true)
            self.gameEntered()
        }
    }
    func gameEntered() {
        switch gameState {
    case .noServerSelected, .serverSelected, .serverConnected, .loginAccepted, .serverSlotFound, .gameActive:
            debugPrint("GuiManager.gameEntered unexpected gameState \(gameState.rawValue) resetting")
            self.serverDeselected()
            menuCntrl.raiseMenu(self)
        case .outfitAccepted:
            // let the games begin, but first setup all the data
            // we require
            // -----------------------------------------------------
            // set the featurelist of this server (current settings)
            guard let featureList = client.communication().featureList() else {
                debugPrint("GuiManager.gameEntered unable to get featurelist resetting")
                self.serverDeselected()
                menuCntrl.raiseMenu(self)
                return
            }
            gameCntrl.gameView().setFeatureList(featureList)
            gameCntrl.mapView()?.setFeatureList(featureList)
            // save the keymap if it was changed
            settingsCntrl.actionKeyMap().writeToDefaultFileIfChanged()
           self.fillKeyMapPanel()
            soundPlayerActiveTheme?.setVolumeFx(settingsCntrl.fxLevel())
            soundPlayerActiveTheme?.setVolumeMusic(settingsCntrl.musicLevel())
            // go and play
            menuCntrl.raiseGame(self)
            gameCntrl.startGame()
            gameState = .gameActive
            // a kill or error will get us out of the game
            soundPlayerActiveTheme?.playSoundEffect("ENTER_SHIP_SOUND")
            notificationCenter?.postNotificationName("GM_GAME_ENTERED")
            if firstGame {
                self.showKeyMapPanel()
                firstGame = false
            }
            self.quickConnectComplete()
            
        }
    }
    @objc func commError() {
        switch gameState {
        case .noServerSelected, .serverSelected: // queued events
            break
        case .serverConnected, .loginAccepted, .serverSlotFound, .gameActive, .outfitAccepted:
            debugPrint("GuiManager.commError unexpected gameState \(gameState.rawValue) resetting")
            keyMapPanel.close()
            self.serverDeselected()
            menuCntrl.disableLogin()
            menuCntrl.raiseMenu(self)
        }
    }
    func setTheme() {
        // we are not yet setting the mapview to a themed painter
        // can do so in the future if desired
        // TODO theme counting weird, should use enumeration
        let theme = settingsCntrl.graphicsModel() + 1 // we start counting at 1, graphicsModel at 0
        let shouldSpeak = settingsCntrl.voiceEnabled()
        let accel = settingsCntrl.accelerate()
        
        if theme != activeTheme {
            debugPrint("GuiManager.setThem to theme \(theme)")
            switch theme {
            case 1:
                gameCntrl.setPainter(painterTheme1)
                painterActiveTheme = painterTheme1
                soundPlayerActiveTheme?.unSubscribeToNotifications()
                soundPlayerActiveTheme = soundPlayerTheme1
                soundPlayerActiveTheme?.subscribeToNotifications()
            case 2:
                gameCntrl.setPainter(painterTheme2)
                painterActiveTheme = painterTheme2
                soundPlayerActiveTheme?.unSubscribeToNotifications()
                soundPlayerActiveTheme = soundPlayerTheme2
                soundPlayerActiveTheme?.subscribeToNotifications()
            case 3:
                gameCntrl.setPainter(painterTheme3)
                painterActiveTheme = painterTheme3
                soundPlayerActiveTheme?.unSubscribeToNotifications()
                soundPlayerActiveTheme = soundPlayerTheme3
                soundPlayerActiveTheme?.subscribeToNotifications()
            default:
                debugPrint("GuiManager.setTheme ERROR unknown theme \(theme)")
            }
            activeTheme = theme
            gameCntrl.setSpeakComputerMessages(shouldSpeak)
            painterActiveTheme?.setAccelerate(accel)
            // add voice commands
            gameCntrl.setListenToVoiceCommands(settingsCntrl.voiceCommands())
        }
        guard let fxLevel = settingsCntrl?.fxLevel() else {
            debugPrint("GuiManager.setTheme ERROR unable to determine fxLevel")
            return
        }
        soundPlayerActiveTheme?.setVolumeFx(fxLevel)
        outfitCntrl.setActivePainter(painterActiveTheme)
        
        if fxLevel == 0.0 {
            // special case disable all sound
            soundPlayerActiveTheme?.unSubscribeToNotifications()
            debugPrint("GuiManager.setTheme silencing sound")
        }
    }
    func setUpKeyMapPanel() {
        if helpWindowCntrl == nil {
            helpWindowCntrl = LLHUDWindowController()
            let windowSize = NSSize(width: 325.0, height: 765.0)
            helpWindowCntrl?.createWindowWithTextField(with: windowSize)
        }
    }
    @objc func showKeyMapPanel() {
        /*if keyMapPanel.isVisible {
            keyMapPanel.close()
        } else {
            keyMapPanel.orderFront(self)
        }*/
        if helpWindowCntrl?.window().isVisible ?? false {
            if keyMapMode == 1 {
                // refill panel
                self.fillKeyMapPanel()
                // and show
                helpWindowCntrl?.window()?.orderFront(self)
                keyMapMode = 2
            } else {
                helpWindowCntrl?.window().close()
                keyMapMode = 0
            }
        } else {
            //refill panel
            if helpWindowCntrl == nil {
                // should not get here but just in case
                self.setUpKeyMapPanel()
            }
            self.fillKeyMapPanel()
            helpWindowCntrl?.window().orderFront(self)
            keyMapMode = 1
        }
    }
    func fillKeyMapPanel() {
        debugPrint("GuiManager.fillKeyMapPanel")
        var result = ""
        if showActionKeys {
            // we were showing action, so lets show distress
            guard let keyMap = settingsCntrl.distressKeyMap() else {
                debugPrint("GuiManager.fillKeyMapPanel ERROR unable to get keyMap")
                return
            }
            guard let actionKeys = keyMap.allKeys() as? [Int32] else {
                debugPrint("GuiManager.actionKeys ERROR unable to coerce type")
                return
            }
            // distress macros
            // TODO we need strict typing for allKeys
            for action in actionKeys {
                if let description = keyMap.description(forAction: action) {
                    result += "\(keyMap.key(forAction: action)) - \(description)\n"
                }
            }
            showActionKeys = false
        } else {
            guard let keyMap = settingsCntrl.actionKeyMap() else {
                debugPrint("GuiManager.fillKeyMapPanel ERROR unable to get keyMap")
                return
            }
            guard let actionKeys = keyMap.allKeys() as? [Int32] else {
                debugPrint("GuiManager.actionKeys ERROR unable to coerce type")
                return
            }

            // add the actions
            //[result appendString:@"-----------Controls-----------\n"];
            for action in actionKeys {
                if let description = keyMap.description(forAction: action) {
                    result += "\(keyMap.key(forAction: action)) - \(description)\n"
                }
            }
            showActionKeys = true
        }
        helpWindowCntrl?.textField()?.stringValue = result
    }
}
