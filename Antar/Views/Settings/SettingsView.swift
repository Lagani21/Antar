//
//  SettingsView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @StateObject private var authService = InstagramAuthService.shared
    @StateObject private var apiService = InstagramAPIService.shared
    @StateObject private var followerAnalytics = FollowerAnalyticsService.shared
    
    @State private var isSwitching = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                            if authService.isAuthenticating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Connecting...")
                                    .foregroundColor(.antarDark)
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.antarDark)
                                Text("Add Instagram Account")
                                    .foregroundColor(.antarDark)
                            }
                        }
                    }
                    .disabled(authService.isAuthenticating)
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
        .alert("Connection Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
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
        // Start Instagram OAuth flow
        authService.authenticate { result in
            switch result {
            case .success(let account):
                // Add the account to our data service
                var newAccount = account
                
                // If this is the first account, make it active
                if mockDataService.accounts.isEmpty {
                    newAccount.isActive = true
                    mockDataService.activeAccount = newAccount
                } else {
                    newAccount.isActive = false
                }
                
                mockDataService.accounts.append(newAccount)
                
                // Fetch user media for the new account
                if let accessToken = account.accessToken {
                    fetchAccountData(accessToken: accessToken, accountId: account.id)
                }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func fetchAccountData(accessToken: String, accountId: UUID) {
        // Fetch user media
        apiService.fetchUserMedia(accessToken: accessToken) { result in
            switch result {
            case .success(let media):
                print("Fetched \(media.count) media items")
                // TODO: Convert Instagram media to MockPost format and add to mockDataService
                
            case .failure(let error):
                print("Failed to fetch media: \(error.localizedDescription)")
            }
        }
        
        // Fetch follower insights
        apiService.fetchFollowerInsights(accessToken: accessToken) { result in
            switch result {
            case .success(let insights):
                print("Fetched follower insights: \(insights.followerCount) followers")
                // Record the data for analytics
                if let account = mockDataService.accounts.first(where: { $0.id == accountId }) {
                    followerAnalytics.recordFollowerData(for: account)
                }
                
            case .failure(let error):
                print("Failed to fetch follower insights: \(error.localizedDescription)")
                // Still record current follower count from profile
                if let account = mockDataService.accounts.first(where: { $0.id == accountId }) {
                    followerAnalytics.recordFollowerData(for: account)
                }
            }
        }
    }
}

struct AccountRowView: View {
    let account: InstagramAccount
    let isActive: Bool
    let isSwitching: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
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
                        
                        HStack(spacing: 4) {
                            Text("\(formatNumber(account.followersCount)) followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(formatNumber(account.followingCount)) following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
            
            // Analytics Link (only show for active account)
            if isActive {
                NavigationLink(destination: FollowerAnalyticsView(account: account)) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundColor(.antarDark)
                        
                        Text("View Analytics")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.antarDark)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
            }
        }
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
