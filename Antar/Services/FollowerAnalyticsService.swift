//
//  FollowerAnalyticsService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import Combine

class FollowerAnalyticsService: ObservableObject {
    static let shared = FollowerAnalyticsService()
    
    @Published var followerHistory: [UUID: [FollowerInsight]] = [:]
    
    private let userDefaultsKey = "followerInsightsHistory"
    
    private init() {
        loadHistory()
        generateMockHistoryIfNeeded()
    }
    
    // MARK: - Record Follower Data
    
    func recordFollowerData(for account: InstagramAccount) {
        let insight = FollowerInsight(
            accountId: account.id,
            timestamp: Date(),
            followersCount: account.followersCount,
            followingCount: account.followingCount
        )
        
        if followerHistory[account.id] != nil {
            followerHistory[account.id]?.append(insight)
        } else {
            followerHistory[account.id] = [insight]
        }
        
        saveHistory()
    }
    
    // MARK: - Get Analytics Data
    
    func getFollowerData(for accountId: UUID, timeframe: FollowerAnalyticsTimeframe) -> [FollowerDataPoint] {
        guard let history = followerHistory[accountId] else {
            return []
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Filter data based on timeframe
        let startDate: Date
        switch timeframe {
        case .day:
            startDate = calendar.date(byAdding: .hour, value: -24, to: now) ?? now
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredHistory = history.filter { $0.timestamp >= startDate }
        
        // Group data by time period
        var dataPoints: [FollowerDataPoint] = []
        let dateFormatter = DateFormatter()
        
        switch timeframe {
        case .day:
            // Group by hour
            dateFormatter.dateFormat = "ha"
            let groupedByHour = Dictionary(grouping: filteredHistory) { insight in
                calendar.startOfHour(for: insight.timestamp)
            }
            
            for hour in 0..<24 {
                guard let hourDate = calendar.date(byAdding: .hour, value: -hour, to: now) else { continue }
                let hourStart = calendar.startOfHour(for: hourDate)
                
                if let insights = groupedByHour[hourStart], let latest = insights.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    dataPoints.append(FollowerDataPoint(
                        date: hourStart,
                        count: latest.followersCount,
                        label: dateFormatter.string(from: hourStart)
                    ))
                }
            }
            
        case .week:
            // Group by day
            dateFormatter.dateFormat = "EEE"
            let groupedByDay = Dictionary(grouping: filteredHistory) { insight in
                calendar.startOfDay(for: insight.timestamp)
            }
            
            for day in 0..<7 {
                guard let dayDate = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: dayDate)
                
                if let insights = groupedByDay[dayStart], let latest = insights.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    dataPoints.append(FollowerDataPoint(
                        date: dayStart,
                        count: latest.followersCount,
                        label: dateFormatter.string(from: dayStart)
                    ))
                } else {
                    // Use previous day's data if no data for this day
                    if let previousPoint = dataPoints.last {
                        dataPoints.append(FollowerDataPoint(
                            date: dayStart,
                            count: previousPoint.count,
                            label: dateFormatter.string(from: dayStart)
                        ))
                    }
                }
            }
            
        case .month:
            // Group by day
            dateFormatter.dateFormat = "MMM d"
            let groupedByDay = Dictionary(grouping: filteredHistory) { insight in
                calendar.startOfDay(for: insight.timestamp)
            }
            
            for day in 0..<30 {
                guard let dayDate = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: dayDate)
                
                if let insights = groupedByDay[dayStart], let latest = insights.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    dataPoints.append(FollowerDataPoint(
                        date: dayStart,
                        count: latest.followersCount,
                        label: dateFormatter.string(from: dayStart)
                    ))
                } else {
                    // Use previous day's data if no data for this day
                    if let previousPoint = dataPoints.last {
                        dataPoints.append(FollowerDataPoint(
                            date: dayStart,
                            count: previousPoint.count,
                            label: dateFormatter.string(from: dayStart)
                        ))
                    }
                }
            }
        }
        
        return dataPoints.reversed() // Return chronologically
    }
    
    func getFollowingData(for accountId: UUID, timeframe: FollowerAnalyticsTimeframe) -> [FollowerDataPoint] {
        guard let history = followerHistory[accountId] else {
            return []
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Filter data based on timeframe
        let startDate: Date
        switch timeframe {
        case .day:
            startDate = calendar.date(byAdding: .hour, value: -24, to: now) ?? now
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        let filteredHistory = history.filter { $0.timestamp >= startDate }
        
        // Group data by time period
        var dataPoints: [FollowerDataPoint] = []
        let dateFormatter = DateFormatter()
        
        switch timeframe {
        case .day:
            // Group by hour
            dateFormatter.dateFormat = "ha"
            let groupedByHour = Dictionary(grouping: filteredHistory) { insight in
                calendar.startOfHour(for: insight.timestamp)
            }
            
            for hour in 0..<24 {
                guard let hourDate = calendar.date(byAdding: .hour, value: -hour, to: now) else { continue }
                let hourStart = calendar.startOfHour(for: hourDate)
                
                if let insights = groupedByHour[hourStart], let latest = insights.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    dataPoints.append(FollowerDataPoint(
                        date: hourStart,
                        count: latest.followingCount,
                        label: dateFormatter.string(from: hourStart)
                    ))
                }
            }
            
        case .week:
            // Group by day
            dateFormatter.dateFormat = "EEE"
            let groupedByDay = Dictionary(grouping: filteredHistory) { insight in
                calendar.startOfDay(for: insight.timestamp)
            }
            
            for day in 0..<7 {
                guard let dayDate = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: dayDate)
                
                if let insights = groupedByDay[dayStart], let latest = insights.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    dataPoints.append(FollowerDataPoint(
                        date: dayStart,
                        count: latest.followingCount,
                        label: dateFormatter.string(from: dayStart)
                    ))
                } else {
                    if let previousPoint = dataPoints.last {
                        dataPoints.append(FollowerDataPoint(
                            date: dayStart,
                            count: previousPoint.count,
                            label: dateFormatter.string(from: dayStart)
                        ))
                    }
                }
            }
            
        case .month:
            // Group by day
            dateFormatter.dateFormat = "MMM d"
            let groupedByDay = Dictionary(grouping: filteredHistory) { insight in
                calendar.startOfDay(for: insight.timestamp)
            }
            
            for day in 0..<30 {
                guard let dayDate = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: dayDate)
                
                if let insights = groupedByDay[dayStart], let latest = insights.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    dataPoints.append(FollowerDataPoint(
                        date: dayStart,
                        count: latest.followingCount,
                        label: dateFormatter.string(from: dayStart)
                    ))
                } else {
                    if let previousPoint = dataPoints.last {
                        dataPoints.append(FollowerDataPoint(
                            date: dayStart,
                            count: previousPoint.count,
                            label: dateFormatter.string(from: dayStart)
                        ))
                    }
                }
            }
        }
        
        return dataPoints.reversed()
    }
    
    // MARK: - Statistics
    
    func getFollowerGrowth(for accountId: UUID, timeframe: FollowerAnalyticsTimeframe) -> Int {
        let data = getFollowerData(for: accountId, timeframe: timeframe)
        guard data.count >= 2, let first = data.first, let last = data.last else {
            return 0
        }
        return last.count - first.count
    }
    
    func getFollowerGrowthPercentage(for accountId: UUID, timeframe: FollowerAnalyticsTimeframe) -> Double {
        let data = getFollowerData(for: accountId, timeframe: timeframe)
        guard data.count >= 2, let first = data.first, let last = data.last, first.count > 0 else {
            return 0.0
        }
        let growth = Double(last.count - first.count)
        return (growth / Double(first.count)) * 100.0
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(followerHistory.values.flatMap { $0 }) else {
            print("Failed to encode follower history")
            return
        }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let insights = try decoder.decode([FollowerInsight].self, from: data)
            
            // Group by account ID
            followerHistory = Dictionary(grouping: insights, by: { $0.accountId })
        } catch {
            print("Failed to load follower history: \(error)")
        }
    }
    
    // MARK: - Mock Data Generation
    
    func generateMockHistoryIfNeeded() {
        // Only generate if no data exists
        guard followerHistory.isEmpty else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Create mock account IDs (use UUIDs that match mock accounts)
        let mockAccountId = UUID()
        
        // Generate 30 days of mock data
        var insights: [FollowerInsight] = []
        var currentFollowers = 15000
        var currentFollowing = 850
        
        for day in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            
            // Simulate follower growth with some randomness
            let followerChange = Int.random(in: -10...50)
            currentFollowers += followerChange
            
            let followingChange = Int.random(in: -5...10)
            currentFollowing += followingChange
            
            let insight = FollowerInsight(
                accountId: mockAccountId,
                timestamp: date,
                followersCount: max(14000, currentFollowers), // Keep above 14k
                followingCount: max(800, currentFollowing)
            )
            insights.append(insight)
        }
        
        followerHistory[mockAccountId] = insights
        saveHistory()
    }
    
    func generateMockHistoryForAccount(_ account: InstagramAccount) {
        let calendar = Calendar.current
        let now = Date()
        
        var insights: [FollowerInsight] = []
        var currentFollowers = account.followersCount
        var currentFollowing = account.followingCount
        
        // Generate 30 days of historical data
        for day in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            
            // Work backwards from current count
            let followerChange = Int.random(in: -20...50)
            currentFollowers = max(currentFollowers - followerChange, account.followersCount - 500)
            
            let followingChange = Int.random(in: -5...10)
            currentFollowing = max(currentFollowing - followingChange, account.followingCount - 100)
            
            let insight = FollowerInsight(
                accountId: account.id,
                timestamp: date,
                followersCount: currentFollowers,
                followingCount: currentFollowing
            )
            insights.insert(insight, at: 0)
        }
        
        // Add current data
        let currentInsight = FollowerInsight(
            accountId: account.id,
            timestamp: now,
            followersCount: account.followersCount,
            followingCount: account.followingCount
        )
        insights.append(currentInsight)
        
        followerHistory[account.id] = insights
        saveHistory()
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func startOfHour(for date: Date) -> Date {
        let components = dateComponents([.year, .month, .day, .hour], from: date)
        return self.date(from: components) ?? date
    }
}
