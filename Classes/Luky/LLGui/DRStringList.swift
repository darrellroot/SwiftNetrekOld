//
//  DRStringList.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/25/19.
//

import Cocoa

class DRStringList: NSView {

    override var isOpaque: Bool {
        return true
    }
    let notificationCenter = LLNotificationCenter.default()
    var hasChangedVal = false
    //let font = NSFont(name: "Helvetica", size: 9.0)
    var selectedRow: Int? = nil
    var stringList: [NSAttributedString] = []
    var name: NSString = ""  //identifier
    let normalAttribute = [NSAttributedString.Key.foregroundColor: NSColor.orange, NSAttributedString.Key.font: NSFont(name: "Helvetica", size: 9.0)!]
    
    var rowHeight: CGFloat = 20.0
    let boxColor = NSColor.brown
    
    override var isFlipped: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        //func drawRect(aRect: NSRect) {
        NSColor.white.set()
        //NSFrameRect(aRect)
        var point: NSPoint = self.bounds.origin
        point.x = point.x + 1
        
        for (i,string) in stringList.enumerated() {
            if i == selectedRow {
                let box = NSRect(x: point.x, y: point.y, width: self.bounds.size.width - 2, height: rowHeight)
                boxColor.set()
                let boxPath = NSBezierPath(rect: box)
                boxPath.stroke()
                let alphaBoxColor = boxColor.withAlphaComponent(0.3)
                alphaBoxColor.set()
                boxPath.fill()
            }
            string.draw(at: point)
            point.y = point.y + rowHeight
        }
        self.hasChangedVal = false
    }
    
    override func awakeFromNib() {
        rowHeight = "testString".size(withAttributes: normalAttribute).height
    }
    func maxNrOfStrings() -> Int {
        var max: Int = 1
        //DispatchQueue.main.sync {
            max = Int(self.bounds.height / rowHeight)
        //}
        return max
    }
    func addString(str: NSString) {
        self.addString(str: str, withColor: NSColor.white)
    }
    func addString(str: NSString, withColor: NSColor) {
        var attributes = normalAttribute
        attributes.updateValue(withColor, forKey: NSAttributedString.Key.foregroundColor)
        let attributedString = NSAttributedString(string: str as String, attributes: attributes)
        stringList.append(attributedString)
        if stringList.count > self.maxNrOfStrings() && stringList.count > 0 {
            for i in 1..<stringList.count {
                stringList[i-1] = stringList[i]
            }
        }
        hasChangedVal = true
    }
    func setIdentifier(newName: NSString) {
        self.name = newName
    }
    
    func mousePos() -> NSPoint {
        let mouseBase = self.window?.mouseLocationOutsideOfEventStream ?? NSPoint.zero
        if mouseBase == NSPoint.zero {
            debugPrint("Warning LLStringList mouseBase is cgzero")
        }
        let mouseLocation = self.convert(mouseBase, from: nil)
        return mouseLocation
    }
    // TODO, should return optional once swift migration complete
    func selectedString() -> NSString {
        if let selectedRow = selectedRow, selectedRow < stringList.count {
            return stringList[selectedRow].string as NSString
        } else {
            return "" as NSString
        }
    }
    func setSelectedRow(row: Int) {
        if row < stringList.count && row > -1 {
            selectedRow = row
            self.newStringSelected(selectedString()) // for derived classes
        }
        self.hasChangedVal = true
    }
    @objc func hasChanged() -> Bool {
        return hasChangedVal
    }
    
    func newStringSelected(_ str: NSString) {
        // to be overwritten
        notificationCenter?.postNotificationName("LL_STRING_LIST_SELECTION", object: self, userInfo: str)
    }
    func removeString(_ str: NSString) {
        for (index,attributedString) in stringList.enumerated() {
            if attributedString.string == String(str) {
                stringList.remove(at: index)
                hasChangedVal = true
                return
            }
        }
    }
    @objc func emptyAllRows() {
        stringList = []
        hasChangedVal = true
    }
    @objc func disableSelection() {
        selectedRow = nil
        hasChangedVal = true
    }
}
