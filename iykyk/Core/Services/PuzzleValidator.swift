//
//  PuzzleValidator.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import Foundation

struct ValidationIssue: Identifiable {
    let id = UUID()
    let message: String
}

struct PuzzleValidator {
    static func validate(_ puzzle: Puzzle) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        // Check group count
        if puzzle.groups.count != 4 {
            issues.append(ValidationIssue(message: "Puzzle must have exactly 4 groups (found \(puzzle.groups.count))"))
        }
        
        // Check group positions are 0-3 and unique
        let groupPositions = Set(puzzle.groups.map { $0.position })
        if groupPositions != Set(0...3) {
            issues.append(ValidationIssue(message: "Group positions must be 0-3 (unique and complete)"))
        }
        
        // Check each group has exactly 4 words
        for (index, group) in puzzle.groups.enumerated() {
            if group.words.count != 4 {
                issues.append(ValidationIssue(message: "Group \(index) must have exactly 4 words (found \(group.words.count))"))
            }
            
            // Check word positions within group are 0-3 and unique
            let wordPositions = Set(group.words.map { $0.position })
            if wordPositions != Set(0...3) {
                issues.append(ValidationIssue(message: "Group \(index) word positions must be 0-3 (unique and complete)"))
            }
            
            // Check for empty word text
            for word in group.words {
                if word.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    issues.append(ValidationIssue(message: "Group \(index) has empty words"))
                    break
                }
            }
            
            // Check for empty group title
            if group.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(ValidationIssue(message: "Group \(index) has no title"))
            }
        }
        
        // Check for duplicate words across entire puzzle
        let allWords = puzzle.groups.flatMap { $0.words.map { $0.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) } }
        let uniqueWords = Set(allWords.filter { !$0.isEmpty })
        if uniqueWords.count != allWords.filter({ !$0.isEmpty }).count {
            issues.append(ValidationIssue(message: "Puzzle contains duplicate words"))
        }
        
        return issues
    }
    
    static func isValid(_ puzzle: Puzzle) -> Bool {
        return validate(puzzle).isEmpty
    }
}

