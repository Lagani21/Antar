//
//  SettingsView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var isSwitching = false
    
    var body: some View {
        NavigationView {
            List {
                // Accounts Section
                Section("Instagram Accounts") {
                    ForEach(mockDataService.accounts) { account in
                        AccountRowView(
                            account: account,
                            isActive: account.id == mockDataService.activeAccount?.id,
                            isSwitching: isSwitching,
                            onTap: {
                                if account.id != mockDataService.activeAccount?.id {
                                    switchAccount(to: account)
                                }
                            }
                        )
                    }
                    
                    Button(action: { addAccount() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.antarDark)
                            Text("Add Instagram Account")
                                .foregroundColor(.antarDark)
                        }
                    }
                }
                .listRowBackground(Color.antarButton)
                
                // App Settings
                Section("Preferences") {
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: Text("Appearance Settings")) {
                        Label("Appearance", systemImage: "paintbrush.fill")
                    }
                    
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy & Security", systemImage: "lock.fill")
                    }
                }
                .listRowBackground(Color.antarButton)
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/help")!) {
                        HStack {
                            Text("Help & Support")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listRowBackground(Color.antarButton)
        }
        .scrollContentBackground(.hidden)
        .background(Color.antarBase)
        .navigationTitle("Settings")
        .background(Color.antarBase)
        }
    }
    
    private func switchAccount(to account: InstagramAccount) {
        isSwitching = true
        
        // Simulate switching delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mockDataService.activeAccount = account
            // Filter posts for the selected account
            mockDataService.posts = mockDataService.posts.filter { $0.accountId == account.id }
            isSwitching = false
        }
    }
    
    private func addAccount() {
        // In a real app, this would trigger Instagram OAuth
        print("Add account tapped - would trigger Instagram OAuth")
    }
}

struct AccountRowView: View {
    let account: InstagramAccount
    let isActive: Bool
    let isSwitching: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile Image
                Circle()
                    .fill(LinearGradient(
                        colors: [.antarDark, .antarAccent1],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(account.username.prefix(1)).uppercased())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(account.username)")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(formatNumber(account.followersCount)) followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSwitching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.antarDark)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return "\(String(format: "%.1f", Double(number) / 1_000_000))M"
        } else if number >= 1_000 {
            return "\(String(format: "%.1f", Double(number) / 1_000))K"
        } else {
            return "\(number)"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MockDataService.shared)
}
