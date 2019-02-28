//
//  MapView.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/26/19.
//

import Cocoa

class MapView: DRGameView {

    var gameBounds = NSRect(x: 0, y: 0, width: Int(UNIVERSE_PIXEL_SIZE), height: Int(UNIVERSE_PIXEL_SIZE))
    var centerPoint = NSPoint(x: Int(UNIVERSE_PIXEL_SIZE)/2, y: Int(UNIVERSE_PIXEL_SIZE)/2)

    override func awakeFromNib() {
        super.awakeFromNib()
        step = step * 2
        self.setScaleFullView()
        self.painter = PainterFactoryForTac() as PainterFactory
        painter?.awakeFromNib()
        painter?.setSimplifyDrawing(true)
    }
    override func gamePointRepresentingCentreOfView() -> NSPoint {
        return centerPoint
    }
    override func keyDown(with event: NSEvent) {
        debugPrint("DRMapView.keydown entered")
        super.keyDown(with: event)
    }
    override func draw(_ aRect: NSRect) {
        painter?.draw(aRect, ofViewBounds: self.bounds, whichRepresentsGameBounds: gameBounds, withScale: Int32(scale))
    }
    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue != 0 {
            let candidateCenter = painter?.gamePoint(fromViewPoint: self.mousePos(), viewRect: self.bounds, gamePosInCentreOfView: self.gamePointRepresentingCentreOfView(), withScale: Int32(scale))
            if let candidateCenter = candidateCenter {
                centerPoint = candidateCenter
                if let candidateGameBounds = painter?.gameRectAround(self.gamePointRepresentingCentreOfView(), forView: self.bounds, withScale: Int32(scale)) {
                    gameBounds = candidateGameBounds
                }
            }
        } else {
            // fire torp
            super.mouseDown(with: event)
        }
    }
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        if let candidateGameBounds = painter?.gameRectAround(self.gamePointRepresentingCentreOfView(), forView: self.bounds, withScale: Int32(scale)) {
            gameBounds = candidateGameBounds
        }
    }
    override func otherMouseDown(with event: NSEvent) {
        //no phaser
        debugPrint("sorry no phaser firing on strategic screen")
    }
}


