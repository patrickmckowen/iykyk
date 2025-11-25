//
//  Date+RelativeFormat.swift
//  iykyk
//
//  Relative date formatting for library cards.
//

import Foundation

extension Date {
    /// Returns a human-readable relative time string.
    /// Examples: "2m ago", "1h ago", "Yesterday", "Nov 24"
    func relativeFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        
        // Future dates or very recent (within a minute)
        if let minutes = components.minute, minutes < 1 {
            return "Just now"
        }
        
        // Minutes ago (up to 59 minutes)
        if let minutes = components.minute, let hours = components.hour,
           hours == 0, minutes >= 1, minutes < 60 {
            return "\(minutes)m ago"
        }
        
        // Hours ago (up to 23 hours)
        if let hours = components.hour, let days = components.day,
           days == 0, hours >= 1, hours < 24 {
            return "\(hours)h ago"
        }
        
        // Yesterday
        if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        // Within the last week
        if let days = components.day, days >= 2, days < 7 {
            return "\(days) days ago"
        }
        
        // Older than a week: show abbreviated date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}

