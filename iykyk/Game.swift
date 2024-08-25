//
//  Game.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/23/24.
//

import Foundation

struct Game: Identifiable {
    let id = UUID()
    var threads: [Thread]

    var allWords: [Word] {
        threads.flatMap { $0.words }
    }

    init() {
        threads = Difficulty.allCases.map { difficulty in
            Thread(name: "", words: [Word(text: ""), Word(text: ""), Word(text: ""), Word(text: "")], difficulty: difficulty)
        }
    }
}
