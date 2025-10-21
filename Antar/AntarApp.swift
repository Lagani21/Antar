//
//  AntarApp.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

@main
struct AntarApp: App {
    @StateObject private var dataService = DataService.shared
    @StateObject private var mockDataService = MockDataService.shared
    @StateObject private var backgroundSync = BackgroundSyncService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataService)
                .environmentObject(mockDataService)
                .environmentObject(backgroundSync)
                .onOpenURL { url in
                    // Handle Instagram OAuth callback
                    handleIncomingURL(url)
                }
                .onAppear {
                    // Start background sync when app launches
                    backgroundSync.startPeriodicSync()
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Check if this is an Instagram callback
        if url.scheme == "antarapp" && url.host == "instagram-callback" {
            // The InstagramAuthService will handle the callback automatically
            // through the ASWebAuthenticationSession
            print("Received Instagram OAuth callback: \(url)")
        }
    }
}
