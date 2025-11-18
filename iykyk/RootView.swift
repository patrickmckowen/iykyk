//
//  RootView.swift
//  iykyk
//
//  Created by Patrick McKowen on 11/18/25.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("iykyk")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Foundation Ready")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("✓ Domain Models")
            Text("✓ Persistence Layer")
            Text("✓ Repository Pattern")
            Text("✓ Validation & Fixtures")
        }
        .padding()
    }
}

#Preview {
    RootView()
}

