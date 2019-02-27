//
//  DRBaseView.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/26/19.
//

import Cocoa

class DRBaseView: NSView {

    var myCursorRect: NSView.TrackingRectTag?
    let notificationCenter = LLNotificationCenter.default()
    let universe = Universe.defaultInstance()
    let macroHandler = MTMacroHandler()
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.allocateGState()
        super.awakeFromNib()
    }
    @objc func setFeatureList(_ list: FeatureList) {
        macroHandler.setFeatureList(list)
    }
    override func viewDidMoveToWindow() {
        self.startTrackingMouse()
    }
    @objc func stopTrackingMouse() {
        if let myCursorRect = myCursorRect {
            self.removeTrackingRect(myCursorRect)
            self.myCursorRect = nil
        }
    }
    @objc func startTrackingMouse() {
        let mouseInView: Bool = NSPointInRect(self.mousePos(), self.bounds)
        myCursorRect = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: mouseInView)
        if mouseInView {
            //TODO possible crash here
            if let event = NSEvent(cgEvent: NSEvent.EventType.mouseEntered as! CGEvent) {
                self.mouseEntered(with: event)
            } else {
                debugPrint("Error DRBaseView:startTrackingMouse: unable to create nsevent")
            }
        }
    }
    override func mouseEntered(with event: NSEvent) {
        debugPrint("DRBaseView mouseEntered making myself first responder")
        self.window?.makeFirstResponder(self)
        NSCursor.crosshair.push()
        super.mouseEntered(with: event)
    }
    override func mouseExited(with event: NSEvent) {
        debugPrint("DRBaseView mouseExited resigning myself first responder")
        self.window?.resignFirstResponder()
        NSCursor.crosshair.pop()
    }
    func mousePos() -> NSPoint {
        guard let mouseBase = self.window?.mouseLocationOutsideOfEventStream else {
            return NSPoint.zero
        }
        let mouseLocation = self.convert(mouseBase, from: nil)
        return mouseLocation
    }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    override var isOpaque: Bool {
        return true
    }
    override var isFlipped: Bool {
        return true
    }
    override var acceptsFirstResponder: Bool {
        return true
    }
    override func becomeFirstResponder() -> Bool {
        self.setNeedsDisplay(self.bounds)
        debugPrint("DRBaseView became first responder")
        return true
    }
    override func resignFirstResponder() -> Bool {
        self.setNeedsDisplay(self.bounds)
        debugPrint("DRBaseView resigned first responder")
        return super.resignFirstResponder()
    }
}
