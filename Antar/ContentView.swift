//
//  ContentView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .background(Color.antarBase)
    }
}

#Preview {
    ContentView()
        .environmentObject(MockDataService.shared)
}
