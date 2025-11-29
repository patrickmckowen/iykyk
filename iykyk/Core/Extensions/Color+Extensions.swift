//
//  Color+Extensions.swift
//  iykyk
//
//  Color utilities for animations.
//

import SwiftUI

extension Color {
    /// Interpolates between this color and another color based on progress (0-1).
    func interpolate(to target: Color, progress: CGFloat) -> Color {
        let clampedProgress = max(0, min(1, progress))
        
        // Resolve colors to their component values
        let fromComponents = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(target).cgColor.components ?? [0, 0, 0, 1]
        
        // Handle grayscale colors (2 components) vs RGB (4 components)
        let fromR = fromComponents.count >= 3 ? fromComponents[0] : fromComponents[0]
        let fromG = fromComponents.count >= 3 ? fromComponents[1] : fromComponents[0]
        let fromB = fromComponents.count >= 3 ? fromComponents[2] : fromComponents[0]
        let fromA = fromComponents.count >= 4 ? fromComponents[3] : (fromComponents.count >= 2 ? fromComponents[1] : 1)
        
        let toR = toComponents.count >= 3 ? toComponents[0] : toComponents[0]
        let toG = toComponents.count >= 3 ? toComponents[1] : toComponents[0]
        let toB = toComponents.count >= 3 ? toComponents[2] : toComponents[0]
        let toA = toComponents.count >= 4 ? toComponents[3] : (toComponents.count >= 2 ? toComponents[1] : 1)
        
        // Linear interpolation
        let r = fromR + (toR - fromR) * clampedProgress
        let g = fromG + (toG - fromG) * clampedProgress
        let b = fromB + (toB - fromB) * clampedProgress
        let a = fromA + (toA - fromA) * clampedProgress
        
        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

