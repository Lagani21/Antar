//
//  DashboardView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var mockDataService: MockDataService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Account Name (full width)
                    if let account = mockDataService.activeAccount {
                        AccountNameCard(account: account)
                    }
                    
                    // 2. Followers & Following buttons
                    FollowButtonsView(account: mockDataService.activeAccount)
                    
                    // 3. Posts & Drafts buttons
                    PostsButtonsView()
                    
                    // 4. Recent Activity
                    RecentActivityView()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Account Name Card (Full Width)
struct AccountNameCard: View {
    let account: InstagramAccount
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(account.username.prefix(1)).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(account.username)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(account.displayName)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(.green)
                .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Followers & Following Buttons
struct FollowButtonsView: View {
    let account: InstagramAccount?
    
    var body: some View {
        HStack(spacing: 12) {
            FollowButton(
                title: "Followers",
                count: account?.followersCount ?? 0,
                icon: "person.2.fill",
                color: .blue
            )
            
            FollowButton(
                title: "Following",
                count: account?.followingCount ?? 0,
                icon: "person.fill",
                color: .green
            )
        }
    }
}

struct FollowButton: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(formatNumber(count))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Posts & Drafts Buttons
struct PostsButtonsView: View {
    @EnvironmentObject var mockDataService: MockDataService
    
    var body: some View {
        HStack(spacing: 12) {
            PostButton(
                title: "Posts",
                count: mockDataService.publishedPosts.count,
                icon: "photo.stack.fill",
                color: .purple
            )
            
            PostButton(
                title: "Drafts",
                count: mockDataService.draftPosts.count,
                icon: "doc.text.fill",
                color: .orange
            )
        }
    }
}

struct PostButton: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Activity
struct RecentActivityView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var activities: [ActivityItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            if activities.isEmpty {
                Text("No recent activity")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(activities) { activity in
                    ActivityCard(activity: activity)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            generateMockActivities()
        }
    }
    
    private func generateMockActivities() {
        let mockActivities = [
            ActivityItem(
                id: UUID(),
                type: .like,
                message: "New like on 'Exploring Paris' post",
                timeAgo: "2 minutes ago",
                icon: "heart.fill",
                color: .red
            ),
            ActivityItem(
                id: UUID(),
                type: .comment,
                message: "New comment from @travelbuddy",
                timeAgo: "5 minutes ago",
                icon: "message.fill",
                color: .blue
            ),
            ActivityItem(
                id: UUID(),
                type: .follow,
                message: "New follower: @adventure_seeker",
                timeAgo: "12 minutes ago",
                icon: "person.badge.plus.fill",
                color: .green
            ),
            ActivityItem(
                id: UUID(),
                type: .post,
                message: "Post 'Sunset Views' published successfully",
                timeAgo: "1 hour ago",
                icon: "checkmark.circle.fill",
                color: .purple
            )
        ]
        
        activities = mockActivities
    }
}

struct ActivityItem: Identifiable {
    let id: UUID
    let type: ActivityType
    let message: String
    let timeAgo: String
    let icon: String
    let color: Color
}

enum ActivityType {
    case like, comment, follow, post
}

struct ActivityCard: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.title3)
                .foregroundColor(activity.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.message)
                    .font(.callout)
                    .foregroundColor(.primary)
                
                Text(activity.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helper Functions
func formatNumber(_ number: Int) -> String {
    if number >= 1_000_000 {
        return "\(String(format: "%.1f", Double(number) / 1_000_000))M"
    } else if number >= 1_000 {
        return "\(String(format: "%.1f", Double(number) / 1_000))K"
    } else {
        return "\(number)"
    }
}

#Preview {
    DashboardView()
        .environmentObject(MockDataService.shared)
}