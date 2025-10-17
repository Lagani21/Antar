//
//  InstagramAPIConfig.example.swift
//  Antar
//
//  This is an example configuration file.
//  Copy this file to InstagramAPIConfig.swift and fill in your credentials.
//
//  DO NOT commit your actual credentials to version control!
//

import Foundation

// Example configuration - rename this struct when copying
struct InstagramAPIConfigExample {
    // MARK: - Instagram App Credentials
    // Get these from: https://developers.facebook.com/apps/
    
    static let appId = "YOUR_INSTAGRAM_APP_ID"
    static let appSecret = "YOUR_INSTAGRAM_APP_SECRET"
    static let redirectUri = "antarapp://instagram-callback"
    
    // MARK: - OAuth Endpoints
    static let authorizationURL = "https://api.instagram.com/oauth/authorize"
    static let tokenURL = "https://api.instagram.com/oauth/access_token"
    
    // MARK: - Graph API Endpoints
    static let graphAPIBaseURL = "https://graph.instagram.com"
    
    // MARK: - Scopes
    static let scopes = [
        "instagram_basic",
        "instagram_content_publish",
        "pages_show_list",
        "pages_read_engagement"
    ]
    
    static var scopeString: String {
        scopes.joined(separator: ",")
    }
    
    // MARK: - Helper Methods
    static func authorizationURLWithState(_ state: String) -> URL? {
        var components = URLComponents(string: authorizationURL)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: appId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: state)
        ]
        return components?.url
    }
}
