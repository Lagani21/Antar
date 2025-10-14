//
//  MockDataService.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import Foundation
import SwiftUI
import Combine

class MockDataService: ObservableObject {
    static let shared = MockDataService()
    
    @Published var accounts: [InstagramAccount] = []
    @Published var posts: [MockPost] = []
    @Published var activeAccount: InstagramAccount?
    
    private init() {
        generateMockData()
    }
    
    func generateMockData() {
        // Create mock Instagram accounts
        let account1 = InstagramAccount(
            username: "travel_explorer",
            displayName: "Travel Explorer",
            followersCount: 15420,
            followingCount: 892,
            isActive: true
        )
        
        let account2 = InstagramAccount(
            username: "foodie_adventures",
            displayName: "Foodie Adventures",
            followersCount: 8234,
            followingCount: 456
        )
        
        accounts = [account1, account2]
        activeAccount = account1
        
        // Generate mock posts
        generateMockPosts(for: account1.id)
    }
    
    private func generateMockPosts(for accountId: UUID) {
        let now = Date()
        let calendar = Calendar.current
        
        // Published posts (past dates)
        let publishedCaptions = [
            "Exploring the beautiful streets of Paris 🇫🇷✨",
            "Sunset views that take your breath away 🌅",
            "Coffee and croissants make everything better ☕🥐",
            "Adventure awaits around every corner 🗺️"
        ]
        
        for i in 0..<4 {
            let daysAgo = Int.random(in: 2...30)
            let publishedDate = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
            
            let post = MockPost(
                caption: publishedCaptions[i],
                mediaUrls: ["photo.\(i+1)"],
                status: .published,
                publishedTime: publishedDate,
                likesCount: Int.random(in: 150...2500),
                commentsCount: Int.random(in: 10...150),
                sharesCount: Int.random(in: 5...80),
                reach: Int.random(in: 1000...10000),
                impressions: Int.random(in: 1500...15000),
                accountId: accountId
            )
            posts.append(post)
        }
        
        // Draft posts
        let draftCaptions = [
            "Working on something amazing 💭",
            "Draft thoughts and ideas 📝"
        ]
        
        for i in 0..<2 {
            let post = MockPost(
                caption: draftCaptions[i],
                mediaUrls: ["photo.\(i+5)"],
                status: .draft,
                accountId: accountId
            )
            posts.append(post)
        }
    }
    
    var totalPosts: Int { posts.count }
    var draftPosts: [MockPost] { posts.filter { $0.status == .draft } }
    var publishedPosts: [MockPost] { posts.filter { $0.status == .published } }
    var scheduledPosts: [MockPost] { posts.filter { $0.status == .scheduled } }
    
    func addPost(_ post: MockPost) {
        posts.append(post)
    }
}
