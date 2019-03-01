//
//  ServerControllerNew.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/28/19.
//

import Foundation

class ServerControllerNew: ServerController {
    let cpuType: String
    let pathToResources = Bundle.main.resourcePath!
    var pathToExe = ""
    var pathToServer = ""
    var pathToPid = ""
    override init() {
        if LLSystemInformation.isPowerPC() {
            cpuType = "PPC"
        } else {
            cpuType = "INTEL"
        }

        super.init()
        pathToExe = "\(pathToResources)/PRECOMPILED/\(cpuType)/lib"
        pathToServer = "\(pathToExe)/newstartd"
        pathToPid = "\(pathToResources)/PRECOMPILED/"
    }
}
