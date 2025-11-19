//
//  PuzzleWord.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation
import SwiftData

@Model
final class PuzzleWord {
    var id: UUID
    var text: String
    var position: Int
    
    var group: PuzzleGroup?
    
    init(id: UUID = UUID(), text: String = "", position: Int) {
        self.id = id
        self.text = text
        self.position = position
    }
}

