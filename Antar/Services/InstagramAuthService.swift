//
//  InstagramAuthService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import SwiftUI
import AuthenticationServices
import Combine

class InstagramAuthService: NSObject, ObservableObject {
    static let shared = InstagramAuthService()
    
    @Published var isAuthenticating = false
    @Published var authError: Error?
    
    private var authSession: ASWebAuthenticationSession?
    private var currentState: String?
    private var authCompletion: ((Result<InstagramAccount, Error>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    enum AuthError: LocalizedError {
        case invalidURL
        case invalidState
        case invalidResponse
        case networkError(String)
        case cancelled
        case notConfigured
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid authorization URL"
            case .invalidState:
                return "Invalid state parameter"
            case .invalidResponse:
                return "Invalid response from Instagram"
            case .networkError(let message):
                return "Network error: \(message)"
            case .cancelled:
                return "Authentication was cancelled"
            case .notConfigured:
                return "Instagram API credentials not configured. Please set up your Instagram App credentials."
            }
        }
    }
    
    // MARK: - OAuth Flow
    
    /// Start Instagram OAuth flow
    func authenticate(completion: @escaping (Result<InstagramAccount, Error>) -> Void) {
        // Check if API credentials are configured
        guard InstagramAPIConfig.isConfigured else {
            completion(.failure(AuthError.notConfigured))
            return
        }
        
        // Generate random state for CSRF protection
        let state = UUID().uuidString
        currentState = state
        authCompletion = completion
        
        guard let authURL = InstagramAPIConfig.authorizationURLWithState(state) else {
            completion(.failure(AuthError.invalidURL))
            return
        }
        
        isAuthenticating = true
        
        // Start web authentication session
        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "antarapp"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isAuthenticating = false
                if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    completion(.failure(AuthError.cancelled))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let callbackURL = callbackURL else {
                self.isAuthenticating = false
                completion(.failure(AuthError.invalidResponse))
                return
            }
            
            // Handle the callback
            self.handleAuthCallback(callbackURL)
        }
        
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    // MARK: - Handle Callback
    
    private func handleAuthCallback(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            isAuthenticating = false
            authCompletion?(.failure(AuthError.invalidResponse))
            return
        }
        
        // Verify state parameter
        let state = components.queryItems?.first(where: { $0.name == "state" })?.value
        guard state == currentState else {
            isAuthenticating = false
            authCompletion?(.failure(AuthError.invalidState))
            return
        }
        
        // Get authorization code
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            isAuthenticating = false
            
            // Check for error in callback
            if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
                authCompletion?(.failure(AuthError.networkError(error)))
            } else {
                authCompletion?(.failure(AuthError.invalidResponse))
            }
            return
        }
        
        // Exchange code for access token
        exchangeCodeForToken(code)
    }
    
    // MARK: - Token Exchange
    
    private func exchangeCodeForToken(_ code: String) {
        guard let tokenURL = URL(string: InstagramAPIConfig.tokenURL) else {
            isAuthenticating = false
            authCompletion?(.failure(AuthError.invalidURL))
            return
        }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "client_id": InstagramAPIConfig.appId,
            "client_secret": InstagramAPIConfig.appSecret,
            "grant_type": "authorization_code",
            "redirect_uri": InstagramAPIConfig.redirectUri,
            "code": code
        ]
        
        let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.isAuthenticating = false
                    self.authCompletion?(.failure(AuthError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    self.isAuthenticating = false
                    self.authCompletion?(.failure(AuthError.invalidResponse))
                    return
                }
                
                do {
                    let tokenResponse = try JSONDecoder().decode(InstagramTokenResponse.self, from: data)
                    
                    // Fetch user profile with the access token
                    self.fetchUserProfile(accessToken: tokenResponse.accessToken, userId: tokenResponse.userId)
                    
                } catch {
                    self.isAuthenticating = false
                    self.authCompletion?(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch User Profile
    
    private func fetchUserProfile(accessToken: String, userId: String) {
        let fields = "id,username,account_type,media_count"
        let urlString = "\(InstagramAPIConfig.graphAPIBaseURL)/me?fields=\(fields)&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            isAuthenticating = false
            authCompletion?(.failure(AuthError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                if let error = error {
                    self.authCompletion?(.failure(AuthError.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    self.authCompletion?(.failure(AuthError.invalidResponse))
                    return
                }
                
                do {
                    let profile = try JSONDecoder().decode(InstagramUserProfile.self, from: data)
                    
                    // Calculate token expiration (Instagram tokens typically expire in 60 days)
                    let expiresAt = Calendar.current.date(byAdding: .day, value: 60, to: Date())
                    
                    // Create InstagramAccount object
                    let account = InstagramAccount(
                        instagramUserId: profile.id,
                        username: profile.username,
                        displayName: profile.username,
                        followersCount: 0, // Will be fetched separately
                        followingCount: 0,
                        isActive: true,
                        connectedAt: Date(),
                        accessToken: accessToken,
                        tokenExpiresAt: expiresAt
                    )
                    
                    // Save token to keychain
                    do {
                        try KeychainService.shared.saveAccessToken(accessToken, forAccount: account.id.uuidString)
                    } catch {
                        print("Warning: Failed to save token to keychain: \(error)")
                    }
                    
                    self.authCompletion?(.success(account))
                    
                } catch {
                    self.authCompletion?(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Token Refresh
    
    /// Refresh an expired access token
    func refreshToken(for account: InstagramAccount, completion: @escaping (Result<String, Error>) -> Void) {
        // Note: Instagram Basic Display API doesn't support token refresh
        // You'll need to re-authenticate or use Instagram Graph API for business accounts
        completion(.failure(AuthError.networkError("Token refresh not supported. Please re-authenticate.")))
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension InstagramAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the key window using modern iOS approach
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            // Fallback: use any available window scene
            guard let anyWindowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else {
                // Last resort: create a basic window (this will show deprecation warning but is necessary)
                return UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            }
            return UIWindow(windowScene: anyWindowScene)
        }
        
        return windowScene.windows.first ?? UIWindow(windowScene: windowScene)
    }
}

