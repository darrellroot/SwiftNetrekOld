//
//  GameController.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/28/19.
//

import Foundation
import AppKit

class GameController: NSObject, NSSpeechSynthesizerDelegate {
    
    var forceBarUpdate = false
    let notificationCenter = LLNotificationCenter.default()
    let universe = Universe.defaultInstance()
    var shouldSpeak = false
    var synth: NSSpeechSynthesizer!
    var voiceCntrl: MTVoiceController?
    var frameCount = 0
    var frameRate: Float = 0.0
    let framesPerFullUpdateDashboard = 10
    
    var totalFrameRate: Float = 0.0
    var sampleCount: Int32 = 0
    
    @IBOutlet weak var shieldBar: LLBar!
    @IBOutlet weak var speedBar: LLBar!
    @IBOutlet weak var hullBar: LLBar!
    @IBOutlet weak var fuelBar: LLBar!
    @IBOutlet weak var torpsBar: LLBar!
    @IBOutlet weak var phasersBar: LLBar!
    @IBOutlet weak var eTempBar: LLBar!
    @IBOutlet weak var wTempBar: LLBar!
    @IBOutlet weak var armiesBar: LLBar!
    @IBOutlet weak var shieldValue: NSTextField!
    @IBOutlet weak var speedValue: NSTextField!
    @IBOutlet weak var hullValue: NSTextField!
    @IBOutlet weak var fuelValue: NSTextField!
    @IBOutlet weak var eTempValue: NSTextField!
    @IBOutlet weak var wTempValue: NSTextField!
    @IBOutlet weak var gameView: DRGameView?
    @IBOutlet weak var mapView: MapView?
    @IBOutlet weak var messages: MessagesListView?
    @IBOutlet weak var playerList: PlayerListView?
    @IBOutlet weak var messageTextField: NSTextField?


    override func awakeFromNib() {
        notificationCenter?.addObserver(self, selector: #selector(newMessage), name: "SP_WARNING", object: nil, useLocks: false, useMainRunLoop: true)
        notificationCenter?.addObserver(self, selector: #selector(newMessage), name: "PM_WARNING", object: nil, useLocks: false, useMainRunLoop: false)
        notificationCenter?.addObserver(self, selector: #selector(newInfoMessage), name: "GV_MODE_INFO", object: nil, useLocks: false, useMainRunLoop: false)
        notificationCenter?.addObserver(self, selector: #selector(queueFull), name: "SP_QUEUE")
        armiesBar?.setDiscrete(true)
        torpsBar?.setDiscrete(true)
        
        let bars = [shieldBar, speedBar, hullBar, fuelBar, torpsBar, phasersBar, eTempBar, wTempBar, armiesBar]
        for bar in bars {
            bar?.setAlpha(1.0)
            bar?.setShowBackGround(true) // I think should be false
        }
        synth = NSSpeechSynthesizer(voice: nil)
        if synth == nil {
            debugPrint("GameController.awakeFromNib ERROR cannot initialize speech synthesizer")
        }
        synth.delegate = self
        voiceCntrl = MTVoiceController()
    }
    @objc func queueFull() {
        self.newMessage("This server is full, please select a different server")
    }
    func getGameView() -> DRGameView {
        return gameView!
    }
    func getMapView() -> MapView {
        return mapView!
    }
    func setSpeakComputerMessages(_ speak: Bool) {
        shouldSpeak = speak
    }
    func setListenToVoiceCommands(_ listen: Bool) {
        voiceCntrl?.setEnableListening(listen)
    }
    func repaint(_ timeSinceLastPaint: Float) {
        if frameCount >= framesPerFullUpdateDashboard {
            frameCount = 0
            forceBarUpdate = true
        } else {
            forceBarUpdate = false
        }
        frameCount = frameCount + 1
        frameRate = 1.0 / timeSinceLastPaint
        if frameRate < 0 {
            frameRate = 0
        }
        self.updateDashboard((universe?.playerThatIsMe())!)
        if messages?.hasChanged() ?? false {
            messages?.setNeedsDisplay(messages!.bounds)
        }
        if playerList?.hasChanged() ?? forceBarUpdate {
            playerList?.setNeedsDisplay(playerList!.bounds)
        }
        if frameCount == 0 {
            // update mapView every 10 frames
            mapView?.setNeedsDisplay((mapView?.bounds)!)
        }
        gameView?.setNeedsDisplay((gameView?.bounds)!)
    }
    @objc func newInfoMessage(_ message: String) {
        if messageTextField?.stringValue == message {
            return // no need to update
        } else {
            messageTextField?.stringValue = message
        }
    }
    @objc func newMessage(_ message: NSString) {
        if shouldSpeak && !synth.isSpeaking {
            debugPrint("GameController.newMessage speaking message \(message)")
            guard message != "Server sending PING packets at 2 second intervals" else {
                return
            }
            if message == "Our computers limit us to having 8 live torpedos at a time captain!" {
                synth.startSpeaking("Out of torpedoes")
            } else {
                synth.startSpeaking(message as String)
            }
        }
    }
    func updateBar(_ bar: LLBar, andTextValue field: NSTextField?, withValue value: Int32, max maxValue: Int32, inverseWarning inverse: Bool) {
        self.updateBar(bar, andTextValue: field, withValue: value, max: maxValue, tempMax: maxValue, inverseWarning: inverse)
    }
    func updateBar(_ bar: LLBar, andTextValue field: NSTextField?, withValue value: Int32, max maxValue: Int32, tempMax: Int32, inverseWarning inverse: Bool) {
        // andTextValue is nil for armies and torps
        if bar.max() != Float(maxValue) || forceBarUpdate {
            field?.stringValue = "\(value) \(tempMax)"
            bar.setMax(Float(maxValue))
            if inverse {
                bar.setCritical(Float(maxValue) * 0.5)
                bar.setWarning(Float(maxValue) * 0.3)
            } else {
                bar.setCritical(Float(maxValue) * 0.3)
                bar.setWarning(Float(maxValue) * 0.5)
            }
            bar.setNeedsDisplay(bar.bounds)
        }
        if (bar.tempMax() != Float(tempMax)) || forceBarUpdate {
            bar.setTempMax(Float(tempMax))
            bar.setNeedsDisplay(bar.bounds)
            field?.stringValue = "\(value) \(tempMax)"
        }
        bar.setValue(Float(value))
        bar.setNeedsDisplay(bar.bounds)
    }
    func updateDashboard(_ me: Player) {
        guard me.isMe() else { return }
        self.updateBar(hullBar, andTextValue: hullValue, withValue: me.hull(), max: me.ship().maxHull(), inverseWarning: false)
        self.updateBar(shieldBar, andTextValue: shieldValue, withValue: me.shield(), max: me.ship().maxShield(), inverseWarning: false)
        self.updateBar(fuelBar, andTextValue: fuelValue, withValue: me.fuel(), max: me.ship().maxFuel(), inverseWarning: false)
        self.updateBar(eTempBar, andTextValue: eTempValue, withValue: me.engineTemp() / 10, max: me.ship().maxEngineTemp() / 10, inverseWarning: true)
        self.updateBar(wTempBar, andTextValue: wTempValue, withValue: me.weaponTemp() / 10, max: me.ship().maxWeaponTemp() / 10, inverseWarning: true)
        self.updateBar(speedBar, andTextValue: speedValue, withValue: me.speed(), max: me.ship().maxSpeed(), inverseWarning: true)
        // special max armies is depended on the players kills
        self.updateBar(armiesBar, andTextValue: nil, withValue: me.armies(), max: me.maxArmies(), inverseWarning: false)
        self.updateBar(torpsBar, andTextValue: nil, withValue: me.availableTorps(), max: me.maxTorps(), inverseWarning: false)

        // abusing phaser bar to show frame rate
        totalFrameRate = frameRate + totalFrameRate
        sampleCount = sampleCount + 1
        
        if forceBarUpdate {
            guard sampleCount != 0 else { return }
            let averageFrameRate = Int32(totalFrameRate) / sampleCount
            self.updateBar(phasersBar, andTextValue: nil, withValue: averageFrameRate, max: Int32(50.0), inverseWarning: false)
            totalFrameRate = 0.0
            sampleCount = 0
        }
    }
    func setPainter(_ newPainter: PainterFactory) {
        gameView?.setPainter(newPainter)
    }
    func stopGame() {
        gameView?.stopTrackingMouse()
        mapView?.stopTrackingMouse()
        // The optimizations may prevent sibling subviews from being displayed in the correct order—which matters only if the subviews
        // overlap. You should always set flag to YES if there are no overlapping subviews within the NSWindow. The default is NO.
    }
    func startGame() {
        gameView?.startTrackingMouse()
        mapView?.startTrackingMouse()
    }
}
