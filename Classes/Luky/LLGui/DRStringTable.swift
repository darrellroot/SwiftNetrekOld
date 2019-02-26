//
//  DRStringTable.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/25/19.
//

import Cocoa

class DRStringTable: NSView {

    override var isOpaque: Bool {
        return true
    }

    var hasChangedVal: Bool = false
    var columns: [DRStringList] = []
    let notificationCenter = LLNotificationCenter.default()
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        var aRect = self.bounds
        let columnWidth = self.bounds.size.width / CGFloat(columns.count)
        aRect.size.width = columnWidth
        
        for column in columns {
            column.bounds = aRect
            column.draw(aRect)
            aRect.origin.x = aRect.origin.x + columnWidth
        }
        hasChangedVal = false
        super.draw(aRect)

    }
    override func awakeFromNib() {
        let list = DRStringList()
        list.frame = self.frame
        list.bounds = self.bounds
        list.awakeFromNib()
        columns.append(list)
    }
    @objc func disableSelection() {
        hasChangedVal = true
    }
    override var isFlipped: Bool {
        return true
    }
    @objc func hasChanged() -> Bool {
        return hasChangedVal
    }

    func mousePos() -> NSPoint {
        let mouseBase = self.window?.mouseLocationOutsideOfEventStream
        let mouseLocation = self.convert(mouseBase ?? NSPoint.zero, from: nil)
        if mouseLocation == NSPoint.zero {
            debugPrint("Warning: DRStringTable: mousePosition is nil")
        }
        return mouseLocation
    }
    override func mouseDown(with event: NSEvent) {
        //TODO shouldnt we get mouse position from event?
        let mousePosition = self.mousePos()
        let columnWidth = self.bounds.size.width / CGFloat(columns.count)
        let selectedColumn: Int = Int(mousePosition.x) / Int(columnWidth)
        for (index,column) in columns.enumerated() {
            if index == selectedColumn {
                let row = Int(mousePosition.y) / Int(column.rowHeight)
                column.setSelectedRow(row: row)
                self.newStringSelected(column.selectedString())
            } else {
                column.disableSelection()
            }
        }
        hasChangedVal = true
    }
    func newStringSelected(_ str: NSString) {
        notificationCenter?.postNotificationName("LL_STRING_TABLE_SELECTION", object: self, userInfo: str)
    }
    func emptyAllColumns() {
        for column in columns {
            column.emptyAllRows()
        }
    }
    func maxNrOfRows() -> Int {
        if let column = columns.first {
            return column.maxNrOfStrings()
        } else {
            debugPrint("Error: DRStringTable no columns, unable to calculate maxNrOfRows")
            return 0
        }
    }
    func setNrOfColumns(_ newNrOfColumns: Int) {
        guard newNrOfColumns > 0 else { return }
        var listBounds = self.bounds
        listBounds.size.width = CGFloat(Int(listBounds.size.width) / newNrOfColumns)
        // delete
        if newNrOfColumns < columns.count {
            for _ in newNrOfColumns ..< columns.count {
                columns.removeLast()
            }
        }
        // add
        if columns.count < newNrOfColumns {
            for _ in columns.count ..< newNrOfColumns {
                let newColumn = DRStringList()
                columns.append(newColumn)
            }
        }
        // set bounds of all
        for column in columns {
            column.frame = listBounds
            column.bounds = listBounds
            column.awakeFromNib()
            listBounds.origin.x = listBounds.origin.x + listBounds.size.width
        }
        hasChangedVal = true
    }
    func removeString(_ str: NSString,fromColumn column: Int) {
        guard column < columns.count && column > -1 else {
            debugPrint("Error: DRStringTable:removeString column \(column) does not exist")
            return
        }
        columns[column].removeString(str)
        hasChangedVal = true
    }
    func addString(_ str: NSString,toColumn column: Int) {
        guard column < columns.count && column > -1 else {
            debugPrint("Error: DRStringTable:addString column \(column) does not exist")
            return
        }
        columns[column].addString(str: str)
        hasChangedVal = true
    }
    func addString(_ str: NSString, withColor color: NSColor, toColumn column: Int) {
        guard column < columns.count && column > -1 else {
            debugPrint("Error: DRStringTable:addString column \(column) does not exist")
            return
        }
        columns[column].addString(str: str, withColor: color)
        hasChangedVal = true
    }
}
