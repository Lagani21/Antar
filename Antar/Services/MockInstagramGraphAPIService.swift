//
//  MockInstagramGraphAPIService.swift
//  Antar
//
//  Simulates Instagram Graph API for portfolio/demo purposes
//  Shows realistic request/response flow without requiring real credentials
//

import Foundation
import SwiftUI
import Combine

// MARK: - API Request/Response Models

struct APIRequest: Identifiable {
    let id: UUID
    let timestamp: Date
    let method: String // GET, POST, DELETE
    let endpoint: String
    let headers: [String: String]
    let body: [String: Any]?
    let description: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), method: String, endpoint: String, headers: [String: String] = [:], body: [String: Any]? = nil, description: String) {
        self.id = id
        self.timestamp = timestamp
        self.method = method
        self.endpoint = endpoint
        self.headers = headers
        self.body = body
        self.description = description
    }
}

struct APIResponse: Identifiable {
    let id: UUID
    let requestId: UUID
    let timestamp: Date
    let statusCode: Int
    let headers: [String: String]
    let body: String // JSON string
    let description: String
}

// MARK: - API Request Logger

class APIRequestLogger: ObservableObject {
    static let shared = APIRequestLogger()
    
    @Published var requests: [APIRequest] = []
    @Published var responses: [APIResponse] = []
    @Published var isEnabled: Bool = true
    
    private init() {}
    
    func logRequest(_ request: APIRequest) {
        guard isEnabled else { return }
        DispatchQueue.main.async {
            self.requests.append(request)
        }
    }
    
    func logResponse(_ response: APIResponse) {
        guard isEnabled else { return }
        DispatchQueue.main.async {
            self.responses.append(response)
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.requests.removeAll()
            self.responses.removeAll()
        }
    }
    
    func getRequestHistory() -> [(APIRequest, APIResponse?)] {
        return requests.map { request in
            let response = responses.first { $0.requestId == request.id }
            return (request, response)
        }
    }
}

// MARK: - Mock Instagram Graph API Service

class MockInstagramGraphAPIService: ObservableObject {
    static let shared = MockInstagramGraphAPIService()
    
    private let logger = APIRequestLogger.shared
    private let baseURL = "https://graph.instagram.com"
    
    @Published var isProcessing = false
    
    private init() {}
    
    // MARK: - Simulate Network Delay
    
    private func simulateNetworkDelay() async {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000)) // 0.5-1.5 seconds
    }
    
    // MARK: - 1. Get User Profile
    
    func getUserProfile(userId: String = "me", accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<[String: Any], Error> {
        let endpoint = "\(baseURL)/\(userId)"
        let request = APIRequest(
            method: "GET",
            endpoint: endpoint + "?fields=id,username,account_type,media_count",
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: nil,
            description: "Fetch user profile information"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let responseData: [String: Any] = [
            "id": "17841405793187218",
            "username": "demo_user",
            "account_type": "BUSINESS",
            "media_count": 42
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: responseData),
            description: "User profile retrieved successfully"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(responseData)
    }
    
    // MARK: - 2. Get User Media
    
    func getUserMedia(userId: String = "me", accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<[[String: Any]], Error> {
        let endpoint = "\(baseURL)/\(userId)/media"
        let request = APIRequest(
            method: "GET",
            endpoint: endpoint + "?fields=id,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count",
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: nil,
            description: "Fetch user's media posts"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let mediaItems: [[String: Any]] = [
            [
                "id": "17895695668004550",
                "caption": "Beautiful sunset 🌅",
                "media_type": "IMAGE",
                "media_url": "https://picsum.photos/400/400?random=1",
                "permalink": "https://www.instagram.com/p/demo1/",
                "timestamp": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                "like_count": 1234,
                "comments_count": 56
            ],
            [
                "id": "17895695668004551",
                "caption": "Coffee time ☕️",
                "media_type": "IMAGE",
                "media_url": "https://picsum.photos/400/400?random=2",
                "permalink": "https://www.instagram.com/p/demo2/",
                "timestamp": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-172800)),
                "like_count": 892,
                "comments_count": 32
            ],
            [
                "id": "17895695668004552",
                "caption": "Travel vibes ✈️",
                "media_type": "IMAGE",
                "media_url": "https://picsum.photos/400/400?random=3",
                "permalink": "https://www.instagram.com/p/demo3/",
                "timestamp": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-259200)),
                "like_count": 2156,
                "comments_count": 89
            ]
        ]
        
        let responseData: [String: Any] = [
            "data": mediaItems,
            "paging": [
                "cursors": [
                    "before": "QVFIUjRtc3FBZ0J5...",
                    "after": "QVFIUkhvdF9WaG1B..."
                ],
                "next": "\(baseURL)/\(userId)/media?after=QVFIUkhvdF9WaG1B..."
            ]
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: responseData),
            description: "Retrieved \(mediaItems.count) media items"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(mediaItems)
    }
    
    // MARK: - 3. Get Media Insights
    
    func getMediaInsights(mediaId: String, accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<[String: Any], Error> {
        let endpoint = "\(baseURL)/\(mediaId)/insights"
        let request = APIRequest(
            method: "GET",
            endpoint: endpoint + "?metric=engagement,impressions,reach,saved",
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: nil,
            description: "Fetch insights for media post"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let insightsData: [String: Any] = [
            "data": [
                ["name": "engagement", "period": "lifetime", "values": [["value": 1456]]],
                ["name": "impressions", "period": "lifetime", "values": [["value": 8932]]],
                ["name": "reach", "period": "lifetime", "values": [["value": 7234]]],
                ["name": "saved", "period": "lifetime", "values": [["value": 234]]]
            ]
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: insightsData),
            description: "Media insights retrieved successfully"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(insightsData)
    }
    
    // MARK: - 4. Create Media Container (Step 1 of Publishing)
    
    func createMediaContainer(imageUrl: String, caption: String, userId: String = "me", accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<String, Error> {
        let endpoint = "\(baseURL)/\(userId)/media"
        let requestBody: [String: Any] = [
            "image_url": imageUrl,
            "caption": caption,
            "access_token": accessToken
        ]
        
        let request = APIRequest(
            method: "POST",
            endpoint: endpoint,
            headers: [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json"
            ],
            body: requestBody,
            description: "Create media container for publishing"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let containerId = "17895695668\(Int.random(in: 100000...999999))"
        let responseData: [String: Any] = [
            "id": containerId
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: responseData),
            description: "Media container created: \(containerId)"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(containerId)
    }
    
    // MARK: - 5. Publish Media Container (Step 2 of Publishing)
    
    func publishMediaContainer(containerId: String, userId: String = "me", accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<String, Error> {
        let endpoint = "\(baseURL)/\(userId)/media_publish"
        let requestBody: [String: Any] = [
            "creation_id": containerId,
            "access_token": accessToken
        ]
        
        let request = APIRequest(
            method: "POST",
            endpoint: endpoint,
            headers: [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json"
            ],
            body: requestBody,
            description: "Publish media container to Instagram"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let mediaId = "17895695669\(Int.random(in: 100000...999999))"
        let responseData: [String: Any] = [
            "id": mediaId
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: responseData),
            description: "Media published successfully: \(mediaId)"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(mediaId)
    }
    
    // MARK: - 6. Get Account Insights
    
    func getAccountInsights(userId: String = "me", accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<[String: Any], Error> {
        let endpoint = "\(baseURL)/\(userId)/insights"
        let request = APIRequest(
            method: "GET",
            endpoint: endpoint + "?metric=impressions,reach,profile_views,follower_count&period=day",
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: nil,
            description: "Fetch account-level insights"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let insightsData: [String: Any] = [
            "data": [
                ["name": "impressions", "period": "day", "values": [["value": 12456, "end_time": ISO8601DateFormatter().string(from: Date())]]],
                ["name": "reach", "period": "day", "values": [["value": 9832, "end_time": ISO8601DateFormatter().string(from: Date())]]],
                ["name": "profile_views", "period": "day", "values": [["value": 456, "end_time": ISO8601DateFormatter().string(from: Date())]]],
                ["name": "follower_count", "period": "day", "values": [["value": 15234, "end_time": ISO8601DateFormatter().string(from: Date())]]]
            ]
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: insightsData),
            description: "Account insights retrieved successfully"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(insightsData)
    }
    
    // MARK: - 7. Delete Media
    
    func deleteMedia(mediaId: String, accessToken: String = "DEMO_ACCESS_TOKEN") async -> Result<Bool, Error> {
        let endpoint = "\(baseURL)/\(mediaId)"
        let request = APIRequest(
            method: "DELETE",
            endpoint: endpoint,
            headers: ["Authorization": "Bearer \(accessToken)"],
            body: nil,
            description: "Delete media post"
        )
        
        logger.logRequest(request)
        isProcessing = true
        
        await simulateNetworkDelay()
        
        let responseData: [String: Any] = [
            "success": true
        ]
        
        let response = APIResponse(
            id: UUID(),
            requestId: request.id,
            timestamp: Date(),
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: jsonString(from: responseData),
            description: "Media deleted successfully"
        )
        
        logger.logResponse(response)
        isProcessing = false
        
        return .success(true)
    }
    
    // MARK: - Helper Methods
    
    private func jsonString(from dictionary: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
    
    // MARK: - Complete Publishing Flow Demo
    
    func demonstratePublishingFlow(imageUrl: String, caption: String) async -> Result<String, Error> {
        // Step 1: Create container
        let containerResult = await createMediaContainer(imageUrl: imageUrl, caption: caption)
        
        guard case .success(let containerId) = containerResult else {
            return .failure(NSError(domain: "MockAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create container"]))
        }
        
        // Step 2: Publish container
        let publishResult = await publishMediaContainer(containerId: containerId)
        
        guard case .success(let mediaId) = publishResult else {
            return .failure(NSError(domain: "MockAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to publish media"]))
        }
        
        return .success(mediaId)
    }
}

