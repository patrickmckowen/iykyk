//
//  PuzzleNumberingService.swift
//  iykyk
//
//  Created by AI Assistant on 11/22/25.
//

import Foundation

/// Manages per-device puzzle sequence numbers.
/// Numbers are monotonically increasing and never reused, even if puzzles are deleted.
enum PuzzleNumberingService {
    private static let nextSequenceKey = "nextPuzzleSequenceNumber"
    
    /// Returns the next available sequence number and increments the stored counter.
    static func nextSequenceNumber() -> Int {
        let defaults = UserDefaults.standard
        let current = defaults.integer(forKey: nextSequenceKey)
        
        // If the key has never been set, start at 1
        let next = current == 0 ? 1 : current
        let following = next + 1
        
        defaults.set(following, forKey: nextSequenceKey)
        
        return next
    }
    
    /// Ensures the stored counter is at least `minimumNextValue`.
    /// Useful when backfilling existing puzzles so we don't reuse numbers.
    static func ensureNextSequenceNumber(atLeast minimumNextValue: Int) {
        let defaults = UserDefaults.standard
        let current = defaults.integer(forKey: nextSequenceKey)
        
        if current < minimumNextValue {
            defaults.set(minimumNextValue, forKey: nextSequenceKey)
        }
    }
}


