//
//  AntarApp.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

@main
struct AntarApp: App {
    @StateObject private var mockDataService = MockDataService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mockDataService)
        }
    }
}
