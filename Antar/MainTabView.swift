//
//  MainTabView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var showingComposer = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            Button(action: { showingComposer = true }) {
                Text("Create")
            }
            .tabItem {
                Label("Create", systemImage: "plus.circle.fill")
            }
            .tag(2)
            .sheet(isPresented: $showingComposer) {
                ComposerView()
            }
            
            DraftsView()
                .tabItem {
                    Label("Drafts", systemImage: "doc.text")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .animation(nil, value: selectedTab)
    }
}

#Preview {
    MainTabView()
        .environmentObject(MockDataService.shared)
}