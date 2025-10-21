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
    
    private let mockGraphAPI = MockInstagramGraphAPIService.shared
    
    private init() {
        // Force regenerate data on each app launch
        generateMockData()
    }
    
    func refreshData() {
        generateMockData()
    }
    
    func generateMockData() {
        // Clear existing data
        posts.removeAll()
        accounts.removeAll()
        
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
        
        // Published POSTS
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
                accountId: accountId,
                contentType: .post
            )
            // Generate week/month/year engagement series
            post.weekSeries = generateSeries(count: 7, labels: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], base: post)
            post.monthSeries = generateSeries(count: 4, labels: ["W1","W2","W3","W4"], base: post, divisor: 6)
            post.yearSeries = generateSeries(count: 12, labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"], base: post, divisor: 40)
            posts.append(post)
        }
        
        // Published REELS
        let reelCaptions = [
            "Quick travel tips for your next adventure!",
            "Best cafes in the city - Part 1",
            "Day in my life as a traveler",
            "Hidden photography spots",
            "Travel hacks you need to know!"
        ]
        
        for i in 0..<5 {
            let daysAgo = Int.random(in: 1...20)
            let publishedDate = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
            
            let reel = MockPost(
                caption: reelCaptions[i],
                mediaUrls: ["reel.\(i+1)"],
                status: .published,
                publishedTime: publishedDate,
                likesCount: Int.random(in: 1500...3500),
                commentsCount: Int.random(in: 80...250),
                sharesCount: Int.random(in: 150...400),
                reach: Int.random(in: 15000...35000),
                impressions: Int.random(in: 20000...45000),
                accountId: accountId,
                contentType: .reel
            )
            posts.append(reel)
        }
        
        // Published STORIES
        let storyCaptions = [
            "Behind the scenes",
            "Quick update",
            "Today's mood",
            "Ask me anything"
        ]
        
        for i in 0..<4 {
            let hoursAgo = Int.random(in: 1...20)
            let publishedDate = calendar.date(byAdding: .hour, value: -hoursAgo, to: now)!
            
            let story = MockPost(
                caption: storyCaptions[i],
                mediaUrls: ["story.\(i+1)"],
                status: .published,
                publishedTime: publishedDate,
                likesCount: 0, // Stories don't have likes
                commentsCount: Int.random(in: 10...50),
                sharesCount: Int.random(in: 5...30),
                reach: Int.random(in: 3000...10000),
                impressions: Int.random(in: 4000...12000),
                accountId: accountId,
                contentType: .story
            )
            posts.append(story)
        }
        
        // Draft posts
        let draftCaptions = [
            "Working on something amazing",
            "Draft thoughts and ideas"
        ]
        
        for i in 0..<2 {
            let post = MockPost(
                caption: draftCaptions[i],
                mediaUrls: ["photo.\(i+20)"],
                status: .draft,
                accountId: accountId
            )
            posts.append(post)
        }
    }
    
    private func generateSeries(count: Int, labels: [String], base: MockPost, divisor: Int = 12) -> [EngagementPoint] {
        let likesBase = max(1, base.likesCount / divisor)
        let commentsBase = max(1, base.commentsCount / divisor)
        let sharesBase = max(1, base.sharesCount / divisor)
        return (0..<count).map { idx in
            EngagementPoint(
                label: labels.indices.contains(idx) ? labels[idx] : "\(idx+1)",
                likes: Int(Double(likesBase) * Double.random(in: 0.7...1.3)),
                comments: Int(Double(commentsBase) * Double.random(in: 0.7...1.3)),
                shares: Int(Double(sharesBase) * Double.random(in: 0.7...1.3))
            )
        }
    }
    
    var totalPosts: Int { posts.count }
    var draftPosts: [MockPost] { posts.filter { $0.status == .draft } }
    var publishedPosts: [MockPost] { posts.filter { $0.status == .published } }
    var scheduledPosts: [MockPost] { posts.filter { $0.status == .scheduled } }
    
    func addPost(_ post: MockPost) {
        posts.append(post)
    }
    
    // MARK: - Mock Graph API Integration
    
    /// Publishes a post using the Mock Instagram Graph API (demonstrates API flow)
    func publishPostWithMockAPI(imageUrl: String, caption: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let accountId = activeAccount?.id else {
            completion(.failure(NSError(domain: "MockDataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No active account"])))
            return
        }
        
        Task {
            // Use the mock Graph API to demonstrate publishing flow
            let result = await mockGraphAPI.demonstratePublishingFlow(imageUrl: imageUrl, caption: caption)
            
            await MainActor.run {
                switch result {
                case .success(let mediaId):
                    // Create a new published post in our local data
                    let newPost = MockPost(
                        caption: caption,
                        mediaUrls: [imageUrl],
                        status: .published,
                        publishedTime: Date(),
                        likesCount: 0,
                        commentsCount: 0,
                        sharesCount: 0,
                        reach: 0,
                        impressions: 0,
                        accountId: accountId,
                        contentType: .post
                    )
                    
                    self.posts.append(newPost)
                    completion(.success(mediaId))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetches user profile using Mock Graph API (demonstrates API flow)
    func fetchUserProfileWithMockAPI(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        Task {
            let result = await mockGraphAPI.getUserProfile()
            await MainActor.run {
                completion(result)
            }
        }
    }
    
    /// Fetches user media using Mock Graph API (demonstrates API flow)
    func fetchUserMediaWithMockAPI(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        Task {
            let result = await mockGraphAPI.getUserMedia()
            await MainActor.run {
                completion(result)
            }
        }
    }
    
    /// Fetches account insights using Mock Graph API (demonstrates API flow)
    func fetchAccountInsightsWithMockAPI(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        Task {
            let result = await mockGraphAPI.getAccountInsights()
            await MainActor.run {
                completion(result)
            }
        }
    }
    
    /// Fetches media insights using Mock Graph API (demonstrates API flow)
    func fetchMediaInsightsWithMockAPI(mediaId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        Task {
            let result = await mockGraphAPI.getMediaInsights(mediaId: mediaId)
            await MainActor.run {
                completion(result)
            }
        }
    }
}
