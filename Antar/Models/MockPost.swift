//
//  MockPost.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import Foundation
import SwiftUI

enum PostStatus: String, Codable {
    case draft
    case scheduled
    case published
    
    var color: Color {
        switch self {
        case .draft:
            return .antarAccent2
        case .scheduled:
            return .antarAccent1
        case .published:
            return .antarDark
        }
    }
}

struct MockPost: Identifiable, Codable {
    let id: UUID
    var caption: String
    var mediaUrls: [String]
    var status: PostStatus
    var scheduledTime: Date?
    var publishedTime: Date?
    var likesCount: Int
    var commentsCount: Int
    var sharesCount: Int
    var reach: Int
    var impressions: Int
    var accountId: UUID
    var createdAt: Date
    var updatedAt: Date
    var contentType: ContentType = .post
    // Time-series engagement (used for analytics)
    var weekSeries: [EngagementPoint] = []
    var monthSeries: [EngagementPoint] = []
    var yearSeries: [EngagementPoint] = []
    
    init(
        id: UUID = UUID(),
        caption: String,
        mediaUrls: [String] = [],
        status: PostStatus,
        scheduledTime: Date? = nil,
        publishedTime: Date? = nil,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        sharesCount: Int = 0,
        reach: Int = 0,
        impressions: Int = 0,
        accountId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        contentType: ContentType = .post,
        weekSeries: [EngagementPoint] = [],
        monthSeries: [EngagementPoint] = [],
        yearSeries: [EngagementPoint] = []
    ) {
        self.id = id
        self.caption = caption
        self.mediaUrls = mediaUrls
        self.status = status
        self.scheduledTime = scheduledTime
        self.publishedTime = publishedTime
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.sharesCount = sharesCount
        self.reach = reach
        self.impressions = impressions
        self.accountId = accountId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.contentType = contentType
        self.weekSeries = weekSeries
        self.monthSeries = monthSeries
        self.yearSeries = yearSeries
    }
    
    var engagementRate: Double {
        guard reach > 0 else { return 0 }
        let totalEngagement = likesCount + commentsCount + sharesCount
        return (Double(totalEngagement) / Double(reach)) * 100
    }
}

struct EngagementPoint: Identifiable, Codable {
    let id: UUID = UUID()
    let label: String   // e.g., Mon, 1, Jan
    let likes: Int
    let comments: Int
    let shares: Int
}
