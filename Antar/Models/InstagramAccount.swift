//
//  InstagramAccount.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import Foundation

struct InstagramAccount: Identifiable, Codable {
    let id: UUID
    var instagramUserId: String?  // Instagram's user ID
    var username: String
    var displayName: String
    var profileImageUrl: String?
    var followersCount: Int
    var followingCount: Int
    var isActive: Bool
    var connectedAt: Date
    var accessToken: String?  // OAuth access token (stored in keychain)
    var tokenExpiresAt: Date?  // Token expiration date
    
    init(
        id: UUID = UUID(),
        instagramUserId: String? = nil,
        username: String,
        displayName: String,
        profileImageUrl: String? = nil,
        followersCount: Int = 0,
        followingCount: Int = 0,
        isActive: Bool = false,
        connectedAt: Date = Date(),
        accessToken: String? = nil,
        tokenExpiresAt: Date? = nil
    ) {
        self.id = id
        self.instagramUserId = instagramUserId
        self.username = username
        self.displayName = displayName
        self.profileImageUrl = profileImageUrl
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.isActive = isActive
        self.connectedAt = connectedAt
        self.accessToken = accessToken
        self.tokenExpiresAt = tokenExpiresAt
    }
    
    var isTokenValid: Bool {
        guard let expiresAt = tokenExpiresAt else { return false }
        return Date() < expiresAt
    }
}
