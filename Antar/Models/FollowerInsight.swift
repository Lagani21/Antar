//
//  FollowerInsight.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation

struct FollowerInsight: Identifiable, Codable {
    let id: UUID
    let accountId: UUID
    let timestamp: Date
    let followersCount: Int
    let followingCount: Int
    
    init(
        id: UUID = UUID(),
        accountId: UUID,
        timestamp: Date = Date(),
        followersCount: Int,
        followingCount: Int
    ) {
        self.id = id
        self.accountId = accountId
        self.timestamp = timestamp
        self.followersCount = followersCount
        self.followingCount = followingCount
    }
}

struct FollowerDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let count: Int
    let label: String
    
    init(id: UUID = UUID(), date: Date, count: Int, label: String) {
        self.id = id
        self.date = date
        self.count = count
        self.label = label
    }
}

enum FollowerAnalyticsTimeframe: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    
    var numberOfDataPoints: Int {
        switch self {
        case .day: return 24 // Hourly data for 24 hours
        case .week: return 7  // Daily data for 7 days
        case .month: return 30 // Daily data for 30 days
        }
    }
    
    var dateComponentUnit: Calendar.Component {
        switch self {
        case .day: return .hour
        case .week: return .day
        case .month: return .day
        }
    }
}

