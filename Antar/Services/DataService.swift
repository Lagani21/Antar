//
//  DataService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import SwiftUI
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var accounts: [InstagramAccount] = []
    @Published var posts: [MockPost] = []
    @Published var activeAccount: InstagramAccount?
    @Published var isLoading = false
    @Published var lastRefreshDate: Date?
    
    private let mockDataService = MockDataService.shared
    private let instagramAPIService = InstagramAPIService.shared
    private let followerAnalyticsService = FollowerAnalyticsService.shared
    private let persistenceService = DataPersistenceService.shared
    private let errorHandlingService = ErrorHandlingService.shared
    
    private init() {
        // Load cached data first
        loadCachedData()
        
        // Then load fresh data if needed
        if persistenceService.shouldRefreshData() {
            loadInitialData()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadCachedData() {
        // Load cached accounts
        accounts = persistenceService.loadAccounts()
        
        // Load cached posts
        posts = persistenceService.loadPosts()
        
        // Load cached follower history
        followerAnalyticsService.followerHistory = persistenceService.loadFollowerHistory()
        
        // Set active account
        if let activeAccountId = persistenceService.loadActiveAccountId(),
           let account = accounts.first(where: { $0.id == activeAccountId }) {
            activeAccount = account
        } else if !accounts.isEmpty {
            activeAccount = accounts.first
        }
        
        // Load last refresh date
        lastRefreshDate = persistenceService.loadLastRefreshDate()
        
        print("Loaded cached data: \(accounts.count) accounts, \(posts.count) posts")
    }
    
    func loadInitialData() {
        if InstagramAPIConfig.isConfigured {
            // Try to load real data first
            loadRealData()
        } else {
            // Fall back to mock data
            loadMockData()
        }
    }
    
    func refreshData() {
        isLoading = true
        
        if InstagramAPIConfig.isConfigured {
            loadRealData()
        } else {
            loadMockData()
        }
        
        // Save data after loading
        saveData()
    }
    
    private func loadMockData() {
        // Use existing mock data service
        accounts = mockDataService.accounts
        posts = mockDataService.posts
        activeAccount = mockDataService.activeAccount
        isLoading = false
        lastRefreshDate = Date()
        
        // Save mock data
        saveData()
    }
    
    private func loadRealData() {
        // Load real Instagram data
        Task {
            await loadInstagramAccounts()
            await loadInstagramPosts()
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.lastRefreshDate = Date()
                self.saveData()
            }
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        persistenceService.saveAccounts(accounts)
        persistenceService.savePosts(posts)
        persistenceService.saveFollowerHistory(followerAnalyticsService.followerHistory)
        
        if let activeAccount = activeAccount {
            persistenceService.saveActiveAccountId(activeAccount.id)
        }
        
        if let lastRefresh = lastRefreshDate {
            persistenceService.saveLastRefreshDate(lastRefresh)
        }
        
        print("Saved data: \(accounts.count) accounts, \(posts.count) posts")
    }
    
    // MARK: - Instagram Account Management
    
    func addInstagramAccount(_ account: InstagramAccount) {
        DispatchQueue.main.async {
            // Check if account already exists
            if let existingIndex = self.accounts.firstIndex(where: { $0.instagramUserId == account.instagramUserId }) {
                // Update existing account
                self.accounts[existingIndex] = account
            } else {
                // Add new account
                self.accounts.append(account)
            }
            
            // Set as active if it's the first account
            if self.activeAccount == nil {
                self.activeAccount = account
            }
            
            // Generate follower analytics history
            self.followerAnalyticsService.generateMockHistoryForAccount(account)
            
            // Save updated data
            self.saveData()
        }
    }
    
    func switchToAccount(_ account: InstagramAccount) {
        DispatchQueue.main.async {
            self.activeAccount = account
            // Load posts for the selected account
            Task {
                await self.loadPostsForAccount(account)
                self.saveData()
            }
        }
    }
    
    // MARK: - Instagram API Integration
    
    @MainActor
    private func loadInstagramAccounts() async {
        // This would load accounts from stored tokens
        // For now, we'll use mock data but with real Instagram integration ready
        accounts = mockDataService.accounts
        activeAccount = mockDataService.activeAccount
    }
    
    @MainActor
    private func loadInstagramPosts() async {
        guard let activeAccount = activeAccount else { return }
        
        guard let accessToken = activeAccount.accessToken else {
            posts = mockDataService.posts
            return
        }
        
        return await withCheckedContinuation { continuation in
            instagramAPIService.fetchUserMedia(accessToken: accessToken) { result in
                switch result {
                case .success(let instagramPosts):
                    let convertedPosts = instagramPosts.map { instagramPost in
                        MockPost(
                            caption: instagramPost.caption ?? "",
                            mediaUrls: instagramPost.mediaUrl != nil ? [instagramPost.mediaUrl!] : [],
                            status: .published,
                            publishedTime: self.parseInstagramTimestamp(instagramPost.timestamp),
                            likesCount: instagramPost.likeCount ?? 0,
                            commentsCount: instagramPost.commentsCount ?? 0,
                            sharesCount: 0, // Instagram API doesn't provide shares count
                            reach: 0, // Would need Instagram Insights API
                            impressions: 0, // Would need Instagram Insights API
                            accountId: activeAccount.id,
                            contentType: instagramPost.mediaType == "VIDEO" ? .reel : .post
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.posts = convertedPosts
                    }
                    
                case .failure(let error):
                    print("Failed to load Instagram posts: \(error)")
                    self.errorHandlingService.handleError(error, context: "instagram_posts")
                    DispatchQueue.main.async {
                        self.posts = self.mockDataService.posts
                    }
                }
                continuation.resume()
            }
        }
    }
    
    @MainActor
    private func loadPostsForAccount(_ account: InstagramAccount) async {
        guard let accessToken = account.accessToken else {
            posts = generateMockPostsForAccount(account)
            return
        }
        
        return await withCheckedContinuation { continuation in
            instagramAPIService.fetchUserMedia(accessToken: accessToken) { result in
                switch result {
                case .success(let instagramPosts):
                    let convertedPosts = instagramPosts.map { instagramPost in
                        MockPost(
                            caption: instagramPost.caption ?? "",
                            mediaUrls: instagramPost.mediaUrl != nil ? [instagramPost.mediaUrl!] : [],
                            status: .published,
                            publishedTime: self.parseInstagramTimestamp(instagramPost.timestamp),
                            likesCount: instagramPost.likeCount ?? 0,
                            commentsCount: instagramPost.commentsCount ?? 0,
                            sharesCount: 0,
                            reach: 0,
                            impressions: 0,
                            accountId: account.id,
                            contentType: instagramPost.mediaType == "VIDEO" ? .reel : .post
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.posts = convertedPosts
                    }
                    
                case .failure(let error):
                    print("Failed to load posts for account: \(error)")
                    self.errorHandlingService.handleError(error, context: "instagram_posts")
                    DispatchQueue.main.async {
                        self.posts = self.generateMockPostsForAccount(account)
                    }
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseInstagramTimestamp(_ timestampString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: timestampString) ?? Date()
    }
    
    private func generateMockPostsForAccount(_ account: InstagramAccount) -> [MockPost] {
        // Generate mock posts similar to MockDataService
        var mockPosts: [MockPost] = []
        let calendar = Calendar.current
        let now = Date()
        
        let postCaptions = [
            "Exploring the beautiful streets of Paris",
            "Sunset views that take your breath away",
            "Coffee and croissants make everything better",
            "Adventure awaits around every corner",
            "Hidden gems in the city",
            "Morning vibes"
        ]
        
        for i in 0..<6 {
            let daysAgo = Int.random(in: 2...30)
            let publishedDate = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
            
            var post = MockPost(
                caption: postCaptions[i],
                mediaUrls: ["photo.\(i+1)"],
                status: .published,
                publishedTime: publishedDate,
                likesCount: Int.random(in: 500...1500),
                commentsCount: Int.random(in: 50...200),
                sharesCount: Int.random(in: 20...100),
                reach: Int.random(in: 5000...15000),
                impressions: Int.random(in: 8000...20000),
                accountId: account.id,
                contentType: .post
            )
            
            // Generate engagement series
            post.weekSeries = generateSeries(count: 7, labels: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], base: post)
            post.monthSeries = generateSeries(count: 4, labels: ["W1","W2","W3","W4"], base: post, divisor: 6)
            post.yearSeries = generateSeries(count: 12, labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"], base: post, divisor: 40)
            
            mockPosts.append(post)
        }
        
        return mockPosts
    }
    
    private func generateSeries(count: Int, labels: [String], base: MockPost, divisor: Int = 1) -> [EngagementPoint] {
        var series: [EngagementPoint] = []
        
        for i in 0..<count {
            let likes = max(1, base.likesCount / divisor + Int.random(in: -50...50))
            let comments = max(0, base.commentsCount / divisor + Int.random(in: -10...10))
            let shares = max(0, base.sharesCount / divisor + Int.random(in: -5...5))
            
            series.append(EngagementPoint(
                id: UUID(),
                label: labels[i],
                likes: likes,
                comments: comments,
                shares: shares
            ))
        }
        
        return series
    }
    
    // MARK: - Data Source Detection
    
    var isUsingRealData: Bool {
        return InstagramAPIConfig.isConfigured && !accounts.isEmpty
    }
    
    var dataSourceDescription: String {
        if InstagramAPIConfig.isConfigured {
            return accounts.isEmpty ? "Connecting to Instagram..." : "Live Instagram Data"
        } else {
            return "Demo Data (Configure Instagram API for real data)"
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        persistenceService.clearAllData()
        accounts.removeAll()
        posts.removeAll()
        activeAccount = nil
        lastRefreshDate = nil
        followerAnalyticsService.followerHistory.removeAll()
        print("Cleared all cached data")
    }
    
    func clearPostsCache() {
        persistenceService.clearPostsCache()
        posts.removeAll()
        print("Cleared posts cache")
    }
    
    func getCacheSize() -> String {
        return persistenceService.getCacheSize()
    }
    
    func forceRefresh() {
        persistenceService.saveLastRefreshDate(Date.distantPast) // Force refresh
        refreshData()
    }
}
