//
//  InstagramAccount.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import Foundation

struct InstagramAccount: Identifiable, Codable {
    let id: UUID
    var username: String
    var displayName: String
    var profileImageUrl: String?
    var followersCount: Int
    var followingCount: Int
    var isActive: Bool
    var connectedAt: Date
    
    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        profileImageUrl: String? = nil,
        followersCount: Int = 0,
        followingCount: Int = 0,
        isActive: Bool = false,
        connectedAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.profileImageUrl = profileImageUrl
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.isActive = isActive
        self.connectedAt = connectedAt
    }
}
