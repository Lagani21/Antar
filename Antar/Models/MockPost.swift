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
            return .gray
        case .scheduled:
            return .blue
        case .published:
            return .green
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
        updatedAt: Date = Date()
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
    }
    
    var engagementRate: Double {
        guard reach > 0 else { return 0 }
        let totalEngagement = likesCount + commentsCount + sharesCount
        return (Double(totalEngagement) / Double(reach)) * 100
    }
}
