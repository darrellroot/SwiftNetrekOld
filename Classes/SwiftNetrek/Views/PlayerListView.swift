//
//  PlayerListView.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/25/19.
//

import Cocoa

class PlayerListView: DRStringTable {

    var universe: Universe!
    let setNrOfColumns = 2
    override func awakeFromNib() {
        universe = Universe.defaultInstance()
        
        notificationCenter!.addObserver(self, selector: #selector(refreshData), name: "SP_PLAYER_INFO", object: nil, useLocks: false, useMainRunLoop: true)
        //NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: "SP_PLAYER_INFO"), object: nil)
        self.setNrOfColumns(2)
        
        notificationCenter?.addObserver(self, selector: #selector(disableSelection), name: "MV_MESSAGE_SELECTION")
        
    }
    
    private func getColumn(player: Player) -> Int {
        switch player.team().teamId() {
        case TEAM_FED:
            return 0
        case TEAM_KLI:
            return 0
        case TEAM_ROM:
            return 1
        case TEAM_ORI:
            return 1
        case TEAM_IND:
            return 1
        default:
            debugPrint("PlayerListView addPlayer illegal team \(player.team().teamId())")
            return 0
        }
    }
    func addPlayer(player: Player) {
        let column = getColumn(player: player)
        self.addString(player.nameWithRankAndKillIndicatorAndShipType() as NSString, withColor: player.team().colorForTeam(), toColumn: column)
    }
    func removePlayer(player: Player) {
        let column = getColumn(player: player)
        self.removeString(player.nameWithRankAndKillIndicatorAndShipType() as NSString,fromColumn: column)
    }
    @objc func refreshData() {
        self.emptyAllColumns()
        for i in 0..<UNIVERSE_MAX_PLAYERS {
            if let player = universe.player(withId: i) {
                if player.status() != PLAYER_FREE {
                    addPlayer(player: player)
                }
            }
        }
        hasChangedVal = true
    }
    override func newStringSelected(_ str: NSString) {
        notificationCenter?.postNotificationName("PV_PLAYER_SELECTION", object: self, userInfo: str)
    }
    
}

