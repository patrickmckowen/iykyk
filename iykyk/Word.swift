//
//  Word.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/23/24.
//

import Foundation
import SwiftData

@Model
final class Word {
    var id: UUID
    var text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
