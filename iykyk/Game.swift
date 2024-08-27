//
//  Game.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/23/24.
//

import Foundation
import SwiftData

@Model
final class Game {
    var id: UUID
    var threads: [Thread]

    var allWords: [Word] {
        threads.flatMap { $0.words }
    }

    init(id: UUID = UUID(), threads: [Thread] = []) {
        self.id = id
        self.threads = threads
        if threads.isEmpty {
            self.threads = Difficulty.allCases.map { difficulty in
                Thread(name: "", words: [Word(text: ""), Word(text: ""), Word(text: ""), Word(text: "")], difficulty: difficulty)
            }
        }
    }
}
