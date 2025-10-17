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
                .onOpenURL { url in
                    // Handle Instagram OAuth callback
                    handleIncomingURL(url)
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
