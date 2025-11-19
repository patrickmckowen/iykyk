//
//  TextSizePreferenceKey.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/19/25.
//

import SwiftUI

/// Preference key for reporting measured text size from a hidden Text view
struct TextSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

