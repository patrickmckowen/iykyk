//
//  Item.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/21/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
