//
//  DashboardView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var showingPostAnalytics = false
    @State private var showingReelAnalytics = false
    @State private var showingStoryAnalytics = false
    
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
                    
                    // 3. Content Type Analytics buttons
                    ContentAnalyticsButtonsView(
                        showingPostAnalytics: $showingPostAnalytics,
                        showingReelAnalytics: $showingReelAnalytics,
                        showingStoryAnalytics: $showingStoryAnalytics
                    )
                    
                    // 4. Recent Activity
                    RecentActivityView()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
        }
        .navigationTitle("Dashboard")
        .background(Color.antarBase)
            .sheet(isPresented: $showingPostAnalytics) {
                DebugAnalyticsView(contentType: .post)
                    .environmentObject(mockDataService)
            }
            .sheet(isPresented: $showingReelAnalytics) {
                DebugAnalyticsView(contentType: .reel)
                    .environmentObject(mockDataService)
            }
            .sheet(isPresented: $showingStoryAnalytics) {
                DebugAnalyticsView(contentType: .story)
                    .environmentObject(mockDataService)
            }
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
                    colors: [.antarDark, .antarAccent1],
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
                .fill(Color.antarAccent1)
                .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.antarButton)
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
                color: .antarDark
            )
            
            FollowButton(
                title: "Following",
                count: account?.followingCount ?? 0,
                icon: "person.fill",
                color: .antarAccent2
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
            .background(Color.antarButton)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Content Analytics Buttons
struct ContentAnalyticsButtonsView: View {
    @Binding var showingPostAnalytics: Bool
    @Binding var showingReelAnalytics: Bool
    @Binding var showingStoryAnalytics: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ContentAnalyticsButton(
                title: "Posts",
                icon: "square.and.pencil",
                color: .antarDark,
                action: { showingPostAnalytics = true }
            )
            
            ContentAnalyticsButton(
                title: "Reels",
                icon: "video.fill",
                color: .antarAccent1,
                action: { showingReelAnalytics = true }
            )
            
            ContentAnalyticsButton(
                title: "Stories",
                icon: "circle.grid.3x3.fill",
                color: .antarAccent2,
                action: { showingStoryAnalytics = true }
            )
        }
    }
}

struct ContentAnalyticsButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.antarButton)
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
        .background(Color.antarButton)
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
                color: .antarAccent1
            ),
            ActivityItem(
                id: UUID(),
                type: .comment,
                message: "New comment from @travelbuddy",
                timeAgo: "5 minutes ago",
                icon: "message.fill",
                color: .antarAccent2
            ),
            ActivityItem(
                id: UUID(),
                type: .follow,
                message: "New follower: @adventure_seeker",
                timeAgo: "12 minutes ago",
                icon: "person.badge.plus.fill",
                color: .antarAccent3
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

// MARK: - Full Analytics View
struct DebugAnalyticsView: View {
    let contentType: ContentType
    @EnvironmentObject var mockDataService: MockDataService
    @Environment(\.dismiss) var dismiss
    @State private var selectedPost: MockPost? = nil
    
    var filteredPosts: [MockPost] {
        mockDataService.publishedPosts.filter { $0.contentType == contentType }
    }
    
    var averageStats: (impressions: Int, likes: Int, comments: Int, shares: Int) {
        guard !filteredPosts.isEmpty else {
            return (0, 0, 0, 0)
        }
        
        let totalImpressions = filteredPosts.reduce(0) { $0 + $1.impressions }
        let totalLikes = filteredPosts.reduce(0) { $0 + $1.likesCount }
        let totalComments = filteredPosts.reduce(0) { $0 + $1.commentsCount }
        let totalShares = filteredPosts.reduce(0) { $0 + $1.sharesCount }
        
        let count = filteredPosts.count
        return (
            impressions: totalImpressions / count,
            likes: totalLikes / count,
            comments: totalComments / count,
            shares: totalShares / count
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Overall Average Performance (for Posts only)
                    if contentType == .post {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overall Average Performance")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            // Average Metrics Cards - Only Likes, Comments, Shares
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    AverageMetricCard(
                                        title: "Avg Likes",
                                        value: formatNumber(averageStats.likes),
                                        icon: "heart.fill",
                                        color: .antarAccent1
                                    )
                                    
                                    AverageMetricCard(
                                        title: "Avg Comments",
                                        value: formatNumber(averageStats.comments),
                                        icon: "message.fill",
                                        color: .antarAccent2
                                    )
                                }
                                
                                HStack(spacing: 12) {
                                    AverageMetricCard(
                                        title: "Avg Shares",
                                        value: formatNumber(averageStats.shares),
                                        icon: "arrowshape.turn.up.right.fill",
                                        color: .antarAccent3
                                    )
                                    
                                    // Empty space to maintain grid
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                        .background(Color.antarButton)
                        .cornerRadius(12)
                        
                        // 2. Most Viral Post (highest likes)
                        if let viralPost = filteredPosts.max(by: { $0.likesCount < $1.likesCount }) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Most Viral Post")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(
                                            colors: [.antarAccent1.opacity(0.3), .antarAccent2.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "flame.fill")
                                                .font(.title2)
                                                .foregroundColor(.antarAccent1)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viralPost.caption.isEmpty ? "Untitled Post" : viralPost.caption)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(2)
                                        
                                        HStack(spacing: 12) {
                                            Label("\(formatNumber(viralPost.likesCount))", systemImage: "heart.fill")
                                                .font(.caption)
                                                .foregroundColor(.antarAccent1)
                                            
                                            Label("\(formatNumber(viralPost.commentsCount))", systemImage: "message.fill")
                                                .font(.caption)
                                                .foregroundColor(.antarAccent2)
                                            
                                            Label("\(formatNumber(viralPost.sharesCount))", systemImage: "arrowshape.turn.up.right.fill")
                                                .font(.caption)
                                                .foregroundColor(.antarAccent3)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color.antarButton)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Individual Posts/Reels/Stories List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All \(contentType.rawValue)s")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        if filteredPosts.isEmpty {
                            Text("No \(contentType.rawValue.lowercased())s yet")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 40)
                        } else {
                            ForEach(filteredPosts) { post in
                                Button(action: {
                                    selectedPost = post
                                }) {
                                    ContentItemRow(post: post, contentType: contentType)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                }
                .padding()
            }
            .navigationTitle("\(contentType.rawValue) Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedPost) { post in
                DetailedAnalyticsView(post: post, contentType: contentType)
                    .environmentObject(mockDataService)
            }
        }
    }
}

struct AverageMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
    }
}

struct ContentItemRow: View {
    let post: MockPost
    let contentType: ContentType
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(
                    colors: [.antarDark.opacity(0.3), .antarAccent1.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: contentType.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.caption.isEmpty ? "Untitled \(contentType.rawValue)" : post.caption)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.caption)
                        Text(formatNumber(post.impressions))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.antarAccent1)
                        Text(formatNumber(post.likesCount))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message.fill")
                            .font(.caption)
                            .foregroundColor(.antarAccent2)
                        Text(formatNumber(post.commentsCount))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.antarBase.opacity(0.8))
        .cornerRadius(12)
    }
}

struct DetailedAnalyticsView: View {
    let post: MockPost
    let contentType: ContentType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Post Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    colors: [.antarDark.opacity(0.3), .antarAccent1.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: contentType.icon)
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(post.caption.isEmpty ? "Untitled \(contentType.rawValue)" : post.caption)
                                    .font(.headline)
                                    .lineLimit(3)
                                
                                if let publishedTime = post.publishedTime {
                                    Text("Published \(publishedTime.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.antarBase.opacity(0.8))
                    .cornerRadius(12)
                    
                    // Metrics Cards
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MetricCard(
                                title: "Impressions",
                                value: formatNumber(post.impressions),
                                icon: "eye.fill",
                                color: .antarDark
                            )
                            
                            MetricCard(
                                title: "Reach",
                                value: formatNumber(post.reach),
                                icon: "person.2.fill",
                                color: .purple
                            )
                        }
                        
                        HStack(spacing: 12) {
                            MetricCard(
                                title: "Likes",
                                value: formatNumber(post.likesCount),
                                icon: "heart.fill",
                                color: .antarAccent1
                            )
                            
                            MetricCard(
                                title: "Comments",
                                value: formatNumber(post.commentsCount),
                                icon: "message.fill",
                                color: .antarAccent2
                            )
                        }
                        
                        HStack(spacing: 12) {
                            MetricCard(
                                title: "Shares",
                                value: formatNumber(post.sharesCount),
                                icon: "arrowshape.turn.up.right.fill",
                                color: .orange
                            )
                            
                            MetricCard(
                                title: "Engagement",
                                value: String(format: "%.1f%%", post.engagementRate),
                                icon: "chart.line.uptrend.xyaxis",
                                color: .indigo
                            )
                        }
                    }
                    
                    // Individual Post Analytics: Likes, Comments, Shares by Day/Week/Month
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Engagement Analytics")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Likes breakdown
                        EngagementBreakdownView(
                            title: "Likes",
                            color: .antarAccent1,
                            icon: "heart.fill",
                            weekData: post.weekSeries.map { $0.likes },
                            monthData: post.monthSeries.map { $0.likes },
                            yearData: post.yearSeries.map { $0.likes },
                            labels: (week: post.weekSeries.map { $0.label }, month: post.monthSeries.map { $0.label }, year: post.yearSeries.map { $0.label })
                        )
                        
                        // Comments breakdown
                        EngagementBreakdownView(
                            title: "Comments",
                            color: .antarAccent2,
                            icon: "message.fill",
                            weekData: post.weekSeries.map { $0.comments },
                            monthData: post.monthSeries.map { $0.comments },
                            yearData: post.yearSeries.map { $0.comments },
                            labels: (week: post.weekSeries.map { $0.label }, month: post.monthSeries.map { $0.label }, year: post.yearSeries.map { $0.label })
                        )
                        
                        // Shares breakdown
                        EngagementBreakdownView(
                            title: "Shares",
                            color: .antarAccent3,
                            icon: "arrowshape.turn.up.right.fill",
                            weekData: post.weekSeries.map { $0.shares },
                            monthData: post.monthSeries.map { $0.shares },
                            yearData: post.yearSeries.map { $0.shares },
                            labels: (week: post.weekSeries.map { $0.label }, month: post.monthSeries.map { $0.label }, year: post.yearSeries.map { $0.label })
                        )
                    }
                    
                    // Performance Insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Performance Insights")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        let insights = generateInsights(for: post)
                        VStack(spacing: 8) {
                            ForEach(insights, id: \.self) { insight in
                                HStack {
                                    Text(insight)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.antarButton)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(contentType.rawValue) Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generateInsights(for post: MockPost) -> [String] {
        var result: [String] = []
        
        if post.engagementRate > 5 {
            result.append("High engagement rate")
        } else if post.engagementRate < 2 {
            result.append("Try adding more engaging content")
        }
        
        if post.impressions > post.reach * 2 {
            result.append("Good re-viewing rate")
        }
        
        if post.likesCount > post.impressions / 10 {
            result.append("Great like-to-impression ratio")
        }
        
        if post.commentsCount > post.likesCount / 5 {
            result.append("Strong community engagement")
        }
        
        if result.isEmpty {
            result.append("Keep posting consistently")
        }
        
        return result
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.antarBase.opacity(0.8))
        .cornerRadius(12)
    }
}

// MARK: - Timeframe + Charts (Posts only)
enum PostTimeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct SegmentedEngagementCharts: View {
    let posts: [MockPost]
    @State private var timeframe: PostTimeframe = .week

    private var series: [[EngagementPoint]] {
        let all: [[EngagementPoint]]
        switch timeframe {
        case .week:
            all = posts.map { $0.weekSeries }
        case .month:
            all = posts.map { $0.monthSeries }
        case .year:
            all = posts.map { $0.yearSeries }
        }
        return all
    }

    private var aggregated: [EngagementPoint] {
        guard let first = series.first, !first.isEmpty else { return [] }
        return first.indices.map { idx in
            let label = first[idx].label
            let likes = series.reduce(0) { $0 + ($1.indices.contains(idx) ? $1[idx].likes : 0) }
            let comments = series.reduce(0) { $0 + ($1.indices.contains(idx) ? $1[idx].comments : 0) }
            let shares = series.reduce(0) { $0 + ($1.indices.contains(idx) ? $1[idx].shares : 0) }
            return EngagementPoint(label: label, likes: likes, comments: comments, shares: shares)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Timeframe control
            HStack(spacing: 8) {
                ForEach(PostTimeframe.allCases, id: \.self) { tf in
                    Button(action: { timeframe = tf }) {
                        Text(tf.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(timeframe == tf ? .white : .antarDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(timeframe == tf ? Color.antarDark : Color.antarDark.opacity(0.1))
                            .cornerRadius(18)
                    }
                }
            }

            // Likes chart
            EngagementBarChart(points: aggregated, keyPath: \.likes, title: "Likes", color: .antarAccent1)
            // Comments chart
            EngagementBarChart(points: aggregated, keyPath: \.comments, title: "Comments", color: .antarAccent2)
            // Shares chart
            EngagementBarChart(points: aggregated, keyPath: \.shares, title: "Shares", color: .antarAccent3)
        }
        .padding(.horizontal)
    }
}

struct EngagementBarChart: View {
    let points: [EngagementPoint]
    let keyPath: KeyPath<EngagementPoint, Int>
    let title: String
    let color: Color

    private var total: Int { points.reduce(0) { $0 + $1[keyPath: keyPath] } }
    private var maxValue: CGFloat { CGFloat(points.map { $0[keyPath: keyPath] }.max() ?? 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("Total: \(formatNumber(total))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(points.indices, id: \.self) { idx in
                        let p = points[idx]
                        VStack(spacing: 6) {
                            Rectangle()
                                .fill(color.gradient)
                                .frame(width: 28, height: max(10, CGFloat(p[keyPath: keyPath]) / max(maxValue, 1) * 140))
                                .cornerRadius(6)
                            Text(p.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 28)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color.antarBase.opacity(0.8))
            .cornerRadius(10)
        }
    }
}

struct EngagementBreakdownView: View {
    let title: String
    let color: Color
    let icon: String
    let weekData: [Int]
    let monthData: [Int]
    let yearData: [Int]
    let labels: (week: [String], month: [String], year: [String])
    
    @State private var selectedTimeframe: TimeframeType = .day
    
    enum TimeframeType: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    
    private var currentData: [Int] {
        switch selectedTimeframe {
        case .day: return weekData
        case .week: return monthData
        case .month: return yearData
        }
    }
    
    private var currentLabels: [String] {
        switch selectedTimeframe {
        case .day: return labels.week
        case .week: return labels.month
        case .month: return labels.year
        }
    }
    
    private var total: Int {
        currentData.reduce(0, +)
    }
    
    private var maxValue: CGFloat {
        CGFloat(currentData.max() ?? 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and timeframe selector
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Timeframe selector
                HStack(spacing: 6) {
                    ForEach(TimeframeType.allCases, id: \.self) { tf in
                        Button(action: { selectedTimeframe = tf }) {
                            Text(tf.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTimeframe == tf ? .white : color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selectedTimeframe == tf ? color : color.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Chart
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(currentData.indices, id: \.self) { idx in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(color.gradient)
                                .frame(width: 24, height: max(8, CGFloat(currentData[idx]) / max(maxValue, 1) * 120))
                                .cornerRadius(4)
                            
                            Text(currentLabels[idx])
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color.antarBase.opacity(0.8))
            .cornerRadius(8)
            
            // Total
            HStack {
                Text("Total: \(formatNumber(total))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(MockDataService.shared)
}