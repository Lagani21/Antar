//
//  InstagramAPIService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import Combine

class InstagramAPIService: ObservableObject {
    static let shared = InstagramAPIService()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private init() {}
    
    enum APIError: LocalizedError {
        case invalidURL
        case invalidToken
        case networkError(String)
        case decodingError
        case unauthorized
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .invalidToken:
                return "Invalid or expired access token"
            case .networkError(let message):
                return "Network error: \(message)"
            case .decodingError:
                return "Failed to decode response"
            case .unauthorized:
                return "Unauthorized. Please reconnect your account."
            }
        }
    }
    
    // MARK: - Fetch Follower Insights
    
    func fetchFollowerInsights(accessToken: String, completion: @escaping (Result<InstagramFollowerInsights, Error>) -> Void) {
        // Note: This requires Instagram Graph API (Business accounts only)
        // For Basic Display API, we can only get the current follower count from the profile
        
        let metric = "follower_count,follows_count"
        let period = "day"
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/me/insights?metric=\(metric)&period=\(period)&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(APIError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.networkError("Invalid response")))
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(APIError.unauthorized))
                    return
                }
                
                // Note: This endpoint might not be available for all account types
                // Fallback to profile data if this fails
                if httpResponse.statusCode == 400 || httpResponse.statusCode == 403 {
                    completion(.failure(APIError.networkError("Insights not available. Business account required.")))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.networkError("No data received")))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(InstagramFollowerInsightsResponse.self, from: data)
                    
                    var insights = InstagramFollowerInsights()
                    for item in response.data {
                        if let value = item.values.first?.value {
                            switch item.name {
                            case "follower_count":
                                insights.followerCount = value
                            case "follows_count":
                                insights.followsCount = value
                            default:
                                break
                            }
                        }
                    }
                    
                    completion(.success(insights))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch User Profile
    
    func fetchUserProfile(accessToken: String, completion: @escaping (Result<InstagramUserProfile, Error>) -> Void) {
        let fields = "id,username,account_type,media_count"
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/me?fields=\(fields)&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion(.failure(APIError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.networkError("Invalid response")))
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(APIError.unauthorized))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.networkError("No data received")))
                    return
                }
                
                do {
                    let profile = try JSONDecoder().decode(InstagramUserProfile.self, from: data)
                    completion(.success(profile))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch User Media
    
    func fetchUserMedia(accessToken: String, completion: @escaping (Result<[InstagramMedia], Error>) -> Void) {
        let fields = "id,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count"
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/me/media?fields=\(fields)&access_token=\(accessToken)&limit=25"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion(.failure(APIError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.networkError("Invalid response")))
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(APIError.unauthorized))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.networkError("No data received")))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(InstagramMediaResponse.self, from: data)
                    completion(.success(response.data))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Media Insights
    
    func fetchMediaInsights(mediaId: String, accessToken: String, completion: @escaping (Result<InstagramMediaInsights, Error>) -> Void) {
        let metrics = "engagement,impressions,reach,saved"
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/\(mediaId)/insights?metric=\(metrics)&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(APIError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.networkError("Invalid response")))
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(APIError.unauthorized))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.networkError("No data received")))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(InstagramInsightsResponse.self, from: data)
                    
                    // Parse insights from response
                    var insights = InstagramMediaInsights()
                    for item in response.data {
                        if let value = item.values.first?.value {
                            switch item.name {
                            case "engagement":
                                insights.engagement = value
                            case "impressions":
                                insights.impressions = value
                            case "reach":
                                insights.reach = value
                            case "saved":
                                insights.saved = value
                            default:
                                break
                            }
                        }
                    }
                    
                    completion(.success(insights))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Publish Media (Container Creation)
    
    func createMediaContainer(imageUrl: String, caption: String, accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/me/media"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "image_url", value: imageUrl),
            URLQueryItem(name: "caption", value: caption),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        guard let finalURL = components?.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(APIError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.networkError("No data received")))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(MediaContainerResponse.self, from: data)
                    completion(.success(response.id))
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Publish Media Container
    
    func publishMediaContainer(containerId: String, accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/me/media_publish"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "creation_id", value: containerId),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        guard let finalURL = components?.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(APIError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.networkError("No data received")))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(MediaPublishResponse.self, from: data)
                    completion(.success(response.id))
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
}

// MARK: - API Response Models

struct InstagramMediaResponse: Codable {
    let data: [InstagramMedia]
    let paging: Paging?
    
    struct Paging: Codable {
        let cursors: Cursors?
        let next: String?
        
        struct Cursors: Codable {
            let before: String?
            let after: String?
        }
    }
}

struct InstagramMedia: Codable, Identifiable {
    let id: String
    let caption: String?
    let mediaType: String
    let mediaUrl: String?
    let thumbnailUrl: String?
    let permalink: String
    let timestamp: String
    let likeCount: Int?
    let commentsCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, caption, permalink, timestamp
        case mediaType = "media_type"
        case mediaUrl = "media_url"
        case thumbnailUrl = "thumbnail_url"
        case likeCount = "like_count"
        case commentsCount = "comments_count"
    }
}

struct InstagramMediaInsights {
    var engagement: Int = 0
    var impressions: Int = 0
    var reach: Int = 0
    var saved: Int = 0
}

struct InstagramInsightsResponse: Codable {
    let data: [InsightData]
    
    struct InsightData: Codable {
        let name: String
        let period: String
        let values: [InsightValue]
        
        struct InsightValue: Codable {
            let value: Int
        }
    }
}

struct MediaContainerResponse: Codable {
    let id: String
}

struct MediaPublishResponse: Codable {
    let id: String
}

struct InstagramFollowerInsights {
    var followerCount: Int = 0
    var followsCount: Int = 0
}

struct InstagramFollowerInsightsResponse: Codable {
    let data: [InsightData]
    
    struct InsightData: Codable {
        let name: String
        let period: String
        let values: [InsightValue]
        
        struct InsightValue: Codable {
            let value: Int
        }
    }
}

