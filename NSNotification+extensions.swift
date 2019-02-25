//
//  NSNotification+extensions.swift
//  SwiftNetrek
//
//  Created by Darrell Root on 2/24/19.
//

import Foundation
// this doesn't work, attempt to fix a notification problem
@objc public extension NSNotification {
    public static var SP_SOUNDS_CACHED: String {
        return "SP_SOUNDS_CACHED"
    }
}
