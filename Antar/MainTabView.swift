//
//  MainTabView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var mockDataService: MockDataService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            CalendarView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            CreateView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            DraftsView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Drafts", systemImage: "doc.text")
                }
                .tag(3)
            
            SettingsView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.antarDark)
        .animation(nil, value: selectedTab)
        .background(Color.antarBase)
        .onAppear {
            // Set the background color for the entire app
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.backgroundColor = UIColor(Color.antarBase)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MockDataService.shared)
}