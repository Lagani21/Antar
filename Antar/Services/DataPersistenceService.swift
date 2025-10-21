//
//  DataPersistenceService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import Combine

class DataPersistenceService: ObservableObject {
    static let shared = DataPersistenceService()
    
    private let userDefaults = UserDefaults.standard
    private let keychainService = KeychainService.shared
    
    // MARK: - Keys
    private enum Keys {
        static let accounts = "instagram_accounts"
        static let activeAccountId = "active_account_id"
        static let lastRefreshDate = "last_refresh_date"
        static let posts = "instagram_posts"
        static let followerHistory = "follower_history"
    }
    
    private init() {}
    
    // MARK: - Account Persistence
    
    func saveAccounts(_ accounts: [InstagramAccount]) {
        do {
            let data = try JSONEncoder().encode(accounts)
            userDefaults.set(data, forKey: Keys.accounts)
            print("Saved \(accounts.count) accounts to UserDefaults")
        } catch {
            print("Failed to save accounts: \(error)")
        }
    }
    
    func loadAccounts() -> [InstagramAccount] {
        guard let data = userDefaults.data(forKey: Keys.accounts) else {
            return []
        }
        
        do {
            let accounts = try JSONDecoder().decode([InstagramAccount].self, from: data)
            print("Loaded \(accounts.count) accounts from UserDefaults")
            return accounts
        } catch {
            print("Failed to load accounts: \(error)")
            return []
        }
    }
    
    func saveActiveAccountId(_ accountId: UUID?) {
        if let accountId = accountId {
            userDefaults.set(accountId.uuidString, forKey: Keys.activeAccountId)
        } else {
            userDefaults.removeObject(forKey: Keys.activeAccountId)
        }
    }
    
    func loadActiveAccountId() -> UUID? {
        guard let accountIdString = userDefaults.string(forKey: Keys.activeAccountId) else {
            return nil
        }
        return UUID(uuidString: accountIdString)
    }
    
    // MARK: - Posts Persistence
    
    func savePosts(_ posts: [MockPost]) {
        do {
            let data = try JSONEncoder().encode(posts)
            userDefaults.set(data, forKey: Keys.posts)
            print("Saved \(posts.count) posts to UserDefaults")
        } catch {
            print("Failed to save posts: \(error)")
        }
    }
    
    func loadPosts() -> [MockPost] {
        guard let data = userDefaults.data(forKey: Keys.posts) else {
            return []
        }
        
        do {
            let posts = try JSONDecoder().decode([MockPost].self, from: data)
            print("Loaded \(posts.count) posts from UserDefaults")
            return posts
        } catch {
            print("Failed to load posts: \(error)")
            return []
        }
    }
    
    // MARK: - Follower History Persistence
    
    func saveFollowerHistory(_ history: [UUID: [FollowerInsight]]) {
        do {
            // Convert to a serializable format
            let serializableHistory = history.mapValues { insights in
                insights.map { insight in
                    SerializableFollowerInsight(
                        id: insight.id,
                        accountId: insight.accountId,
                        timestamp: insight.timestamp,
                        followersCount: insight.followersCount,
                        followingCount: insight.followingCount
                    )
                }
            }
            
            let data = try JSONEncoder().encode(serializableHistory)
            userDefaults.set(data, forKey: Keys.followerHistory)
            print("Saved follower history for \(history.count) accounts")
        } catch {
            print("Failed to save follower history: \(error)")
        }
    }
    
    func loadFollowerHistory() -> [UUID: [FollowerInsight]] {
        guard let data = userDefaults.data(forKey: Keys.followerHistory) else {
            return [:]
        }
        
        do {
            let serializableHistory = try JSONDecoder().decode([UUID: [SerializableFollowerInsight]].self, from: data)
            
            // Convert back to FollowerInsight objects
            let history = serializableHistory.mapValues { serializableInsights in
                serializableInsights.map { serializable in
                    FollowerInsight(
                        id: serializable.id,
                        accountId: serializable.accountId,
                        timestamp: serializable.timestamp,
                        followersCount: serializable.followersCount,
                        followingCount: serializable.followingCount
                    )
                }
            }
            
            print("Loaded follower history for \(history.count) accounts")
            return history
        } catch {
            print("Failed to load follower history: \(error)")
            return [:]
        }
    }
    
    // MARK: - Cache Management
    
    func saveLastRefreshDate(_ date: Date) {
        userDefaults.set(date, forKey: Keys.lastRefreshDate)
    }
    
    func loadLastRefreshDate() -> Date? {
        return userDefaults.object(forKey: Keys.lastRefreshDate) as? Date
    }
    
    func shouldRefreshData() -> Bool {
        guard let lastRefresh = loadLastRefreshDate() else {
            return true
        }
        
        // Refresh if data is older than 1 hour
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return lastRefresh < oneHourAgo
    }
    
    // MARK: - Clear Cache
    
    func clearAllData() {
        userDefaults.removeObject(forKey: Keys.accounts)
        userDefaults.removeObject(forKey: Keys.activeAccountId)
        userDefaults.removeObject(forKey: Keys.posts)
        userDefaults.removeObject(forKey: Keys.followerHistory)
        userDefaults.removeObject(forKey: Keys.lastRefreshDate)
        print("Cleared all cached data")
    }
    
    func clearPostsCache() {
        userDefaults.removeObject(forKey: Keys.posts)
        print("Cleared posts cache")
    }
    
    // MARK: - Storage Size Management
    
    func getCacheSize() -> String {
        let accountsSize = userDefaults.data(forKey: Keys.accounts)?.count ?? 0
        let postsSize = userDefaults.data(forKey: Keys.posts)?.count ?? 0
        let historySize = userDefaults.data(forKey: Keys.followerHistory)?.count ?? 0
        
        let totalBytes = accountsSize + postsSize + historySize
        
        if totalBytes < 1024 {
            return "\(totalBytes) bytes"
        } else if totalBytes < 1024 * 1024 {
            return "\(totalBytes / 1024) KB"
        } else {
            return "\(totalBytes / (1024 * 1024)) MB"
        }
    }
}

// MARK: - Serializable Models

private struct SerializableFollowerInsight: Codable {
    let id: UUID
    let accountId: UUID
    let timestamp: Date
    let followersCount: Int
    let followingCount: Int
}
