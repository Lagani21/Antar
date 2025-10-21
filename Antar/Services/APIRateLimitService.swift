//
//  APIRateLimitService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import Combine

class APIRateLimitService: ObservableObject {
    static let shared = APIRateLimitService()
    
    @Published var isRateLimited = false
    @Published var rateLimitResetTime: Date?
    @Published var remainingRequests: Int?
    @Published var quotaUsed: Double = 0.0 // Percentage of quota used
    
    // MARK: - Rate Limit Tracking
    
    private var requestHistory: [Date] = []
    private var dailyRequestCount = 0
    private var hourlyRequestCount = 0
    private var lastRequestTime: Date?
    
    // MARK: - Instagram API Limits
    // Instagram Basic Display API limits
    private let dailyLimit = 200 // requests per day
    private let hourlyLimit = 25  // requests per hour
    private let perMinuteLimit = 5 // requests per minute
    
    private init() {
        loadRateLimitData()
    }
    
    // MARK: - Request Management
    
    func canMakeRequest() -> Bool {
        // Check if currently rate limited
        if isRateLimited {
            if let resetTime = rateLimitResetTime, Date() >= resetTime {
                // Rate limit has expired
                isRateLimited = false
                rateLimitResetTime = nil
            } else {
                return false
            }
        }
        
        // Check per-minute limit
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        let recentRequests = requestHistory.filter { $0 > oneMinuteAgo }
        
        if recentRequests.count >= perMinuteLimit {
            return false
        }
        
        // Check hourly limit
        let oneHourAgo = now.addingTimeInterval(-3600)
        let hourlyRequests = requestHistory.filter { $0 > oneHourAgo }
        
        if hourlyRequests.count >= hourlyLimit {
            return false
        }
        
        // Check daily limit
        let oneDayAgo = now.addingTimeInterval(-86400)
        let dailyRequests = requestHistory.filter { $0 > oneDayAgo }
        
        if dailyRequests.count >= dailyLimit {
            return false
        }
        
        return true
    }
    
    func recordRequest() {
        let now = Date()
        requestHistory.append(now)
        lastRequestTime = now
        
        // Clean up old requests (older than 24 hours)
        let oneDayAgo = now.addingTimeInterval(-86400)
        requestHistory.removeAll { $0 < oneDayAgo }
        
        // Update counters
        updateRequestCounts()
        
        // Save data
        saveRateLimitData()
    }
    
    func handleRateLimitResponse(headers: [String: String]) {
        // Parse rate limit headers from Instagram API response
        if let remaining = headers["X-RateLimit-Remaining"] {
            remainingRequests = Int(remaining)
        }
        
        if let resetTimeString = headers["X-RateLimit-Reset"] {
            if let resetTimestamp = Double(resetTimeString) {
                rateLimitResetTime = Date(timeIntervalSince1970: resetTimestamp)
            }
        }
        
        // If we're rate limited, set the flag
        if let remaining = remainingRequests, remaining <= 0 {
            isRateLimited = true
        }
        
        // Calculate quota usage
        updateQuotaUsage()
        
        // Save data
        saveRateLimitData()
    }
    
    // MARK: - Request Scheduling
    
    func scheduleRequest<T>(_ request: @escaping () -> AnyPublisher<T, Error>) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            if self.canMakeRequest() {
                self.recordRequest()
                request()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                promise(.failure(error))
                            }
                        },
                        receiveValue: { value in
                            promise(.success(value))
                        }
                    )
                    .store(in: &self.cancellables)
            } else {
                // Calculate delay until next request is allowed
                let delay = self.calculateNextRequestDelay()
                
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    self.scheduleRequest(request)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: { value in
                                promise(.success(value))
                            }
                        )
                        .store(in: &self.cancellables)
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func calculateNextRequestDelay() -> TimeInterval {
        let now = Date()
        
        // Check per-minute limit
        let oneMinuteAgo = now.addingTimeInterval(-60)
        let recentRequests = requestHistory.filter { $0 > oneMinuteAgo }
        
        if recentRequests.count >= perMinuteLimit {
            if let oldestRecent = recentRequests.min() {
                return 60 - now.timeIntervalSince(oldestRecent)
            }
        }
        
        // Check hourly limit
        let oneHourAgo = now.addingTimeInterval(-3600)
        let hourlyRequests = requestHistory.filter { $0 > oneHourAgo }
        
        if hourlyRequests.count >= hourlyLimit {
            if let oldestHourly = hourlyRequests.min() {
                return 3600 - now.timeIntervalSince(oldestHourly)
            }
        }
        
        // Default delay
        return 1.0
    }
    
    // MARK: - Quota Management
    
    private func updateRequestCounts() {
        let now = Date()
        
        // Update hourly count
        let oneHourAgo = now.addingTimeInterval(-3600)
        hourlyRequestCount = requestHistory.filter { $0 > oneHourAgo }.count
        
        // Update daily count
        let oneDayAgo = now.addingTimeInterval(-86400)
        dailyRequestCount = requestHistory.filter { $0 > oneDayAgo }.count
    }
    
    private func updateQuotaUsage() {
        // Calculate quota usage based on daily limit
        quotaUsed = Double(dailyRequestCount) / Double(dailyLimit) * 100.0
    }
    
    // MARK: - Status Information
    
    func getRateLimitStatus() -> RateLimitStatus {
        let now = Date()
        
        // Check per-minute status
        let oneMinuteAgo = now.addingTimeInterval(-60)
        let recentRequests = requestHistory.filter { $0 > oneMinuteAgo }
        let perMinuteRemaining = max(0, perMinuteLimit - recentRequests.count)
        
        // Check hourly status
        let oneHourAgo = now.addingTimeInterval(-3600)
        let hourlyRequests = requestHistory.filter { $0 > oneHourAgo }
        let hourlyRemaining = max(0, hourlyLimit - hourlyRequests.count)
        
        // Check daily status
        let oneDayAgo = now.addingTimeInterval(-86400)
        let dailyRequests = requestHistory.filter { $0 > oneDayAgo }
        let dailyRemaining = max(0, dailyLimit - dailyRequests.count)
        
        return RateLimitStatus(
            perMinuteRemaining: perMinuteRemaining,
            hourlyRemaining: hourlyRemaining,
            dailyRemaining: dailyRemaining,
            quotaUsed: quotaUsed,
            isRateLimited: isRateLimited,
            resetTime: rateLimitResetTime
        )
    }
    
    // MARK: - Data Persistence
    
    private func saveRateLimitData() {
        let data = RateLimitData(
            requestHistory: requestHistory,
            dailyRequestCount: dailyRequestCount,
            hourlyRequestCount: hourlyRequestCount,
            lastRequestTime: lastRequestTime,
            isRateLimited: isRateLimited,
            rateLimitResetTime: rateLimitResetTime,
            remainingRequests: remainingRequests,
            quotaUsed: quotaUsed
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "rate_limit_data")
        }
    }
    
    private func loadRateLimitData() {
        guard let data = UserDefaults.standard.data(forKey: "rate_limit_data"),
              let rateLimitData = try? JSONDecoder().decode(RateLimitData.self, from: data) else {
            return
        }
        
        requestHistory = rateLimitData.requestHistory
        dailyRequestCount = rateLimitData.dailyRequestCount
        hourlyRequestCount = rateLimitData.hourlyRequestCount
        lastRequestTime = rateLimitData.lastRequestTime
        isRateLimited = rateLimitData.isRateLimited
        rateLimitResetTime = rateLimitData.rateLimitResetTime
        remainingRequests = rateLimitData.remainingRequests
        quotaUsed = rateLimitData.quotaUsed
    }
    
    // MARK: - Reset Methods
    
    func resetRateLimit() {
        isRateLimited = false
        rateLimitResetTime = nil
        remainingRequests = nil
        saveRateLimitData()
    }
    
    func clearRequestHistory() {
        requestHistory.removeAll()
        dailyRequestCount = 0
        hourlyRequestCount = 0
        lastRequestTime = nil
        quotaUsed = 0.0
        saveRateLimitData()
    }
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Supporting Types

struct RateLimitStatus {
    let perMinuteRemaining: Int
    let hourlyRemaining: Int
    let dailyRemaining: Int
    let quotaUsed: Double
    let isRateLimited: Bool
    let resetTime: Date?
    
    var statusMessage: String {
        if isRateLimited {
            if let resetTime = resetTime {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return "Rate limited until \(formatter.string(from: resetTime))"
            } else {
                return "Rate limited - please wait"
            }
        } else {
            return "\(dailyRemaining) requests remaining today"
        }
    }
    
    var statusColor: String {
        if isRateLimited {
            return "red"
        } else if quotaUsed > 80 {
            return "orange"
        } else {
            return "green"
        }
    }
}

struct RateLimitData: Codable {
    let requestHistory: [Date]
    let dailyRequestCount: Int
    let hourlyRequestCount: Int
    let lastRequestTime: Date?
    let isRateLimited: Bool
    let rateLimitResetTime: Date?
    let remainingRequests: Int?
    let quotaUsed: Double
}
