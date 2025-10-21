//
//  ErrorHandlingService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import Combine

class ErrorHandlingService: ObservableObject {
    static let shared = ErrorHandlingService()
    
    @Published var lastError: AppError?
    @Published var errorCount: Int = 0
    @Published var isRetrying: Bool = false
    
    private var retryAttempts: [String: Int] = [:]
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 2.0
    
    private init() {}
    
    // MARK: - Error Types
    
    enum AppError: LocalizedError, Identifiable {
        case networkError(String)
        case apiError(String)
        case authenticationError(String)
        case dataError(String)
        case configurationError(String)
        case rateLimitError(String)
        case unknownError(String)
        
        var id: String {
            switch self {
            case .networkError(let message):
                return "network_\(message.hashValue)"
            case .apiError(let message):
                return "api_\(message.hashValue)"
            case .authenticationError(let message):
                return "auth_\(message.hashValue)"
            case .dataError(let message):
                return "data_\(message.hashValue)"
            case .configurationError(let message):
                return "config_\(message.hashValue)"
            case .rateLimitError(let message):
                return "rate_\(message.hashValue)"
            case .unknownError(let message):
                return "unknown_\(message.hashValue)"
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .networkError(let message):
                return "Network Error: \(message)"
            case .apiError(let message):
                return "API Error: \(message)"
            case .authenticationError(let message):
                return "Authentication Error: \(message)"
            case .dataError(let message):
                return "Data Error: \(message)"
            case .configurationError(let message):
                return "Configuration Error: \(message)"
            case .rateLimitError(let message):
                return "Rate Limit Error: \(message)"
            case .unknownError(let message):
                return "Unknown Error: \(message)"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .networkError:
                return "Check your internet connection and try again."
            case .apiError:
                return "There was an issue with the Instagram API. Please try again later."
            case .authenticationError:
                return "Please reconnect your Instagram account in Settings."
            case .dataError:
                return "There was an issue processing the data. Please refresh."
            case .configurationError:
                return "Please check your Instagram API configuration in Settings."
            case .rateLimitError:
                return "Too many requests. Please wait a moment and try again."
            case .unknownError:
                return "An unexpected error occurred. Please try again."
            }
        }
        
        var severity: ErrorSeverity {
            switch self {
            case .networkError, .rateLimitError:
                return .warning
            case .apiError, .dataError:
                return .error
            case .authenticationError, .configurationError:
                return .critical
            case .unknownError:
                return .error
            }
        }
    }
    
    enum ErrorSeverity {
        case warning
        case error
        case critical
        
        var color: String {
            switch self {
            case .warning:
                return "orange"
            case .error:
                return "red"
            case .critical:
                return "purple"
            }
        }
    }
    
    // MARK: - Error Handling
    
    func handleError(_ error: Error, context: String = "") {
        let appError = convertToAppError(error)
        let errorKey = "\(context)_\(appError.id)"
        
        DispatchQueue.main.async {
            self.lastError = appError
            self.errorCount += 1
            
            print("Error in \(context): \(appError.localizedDescription)")
            
            // Log error for debugging
            self.logError(appError, context: context)
        }
        
        // Auto-retry for certain error types
        if shouldAutoRetry(appError) {
            scheduleRetry(for: errorKey, context: context)
        }
    }
    
    private func convertToAppError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // Convert common error types
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError("No internet connection")
            case .timedOut:
                return .networkError("Request timed out")
            case .cannotConnectToHost:
                return .networkError("Cannot connect to server")
            default:
                return .networkError(urlError.localizedDescription)
            }
        }
        
        if let instagramError = error as? InstagramAPIService.APIError {
            switch instagramError {
            case .invalidToken, .unauthorized:
                return .authenticationError(instagramError.localizedDescription)
            case .invalidURL:
                return .configurationError("Invalid API URL")
            case .networkError(let message):
                return .networkError(message)
            case .decodingError:
                return .dataError("Failed to decode response")
            case .rateLimitExceeded:
                return .rateLimitError("Rate limit exceeded")
            }
        }
        
        if let authError = error as? InstagramAuthService.AuthError {
            switch authError {
            case .notConfigured:
                return .configurationError("Instagram API not configured")
            case .invalidURL, .invalidState, .invalidResponse:
                return .apiError(authError.localizedDescription)
            case .networkError(let message):
                return .networkError(message)
            case .cancelled:
                return .unknownError("Authentication cancelled")
            }
        }
        
        return .unknownError(error.localizedDescription)
    }
    
    private func shouldAutoRetry(_ error: AppError) -> Bool {
        switch error {
        case .networkError, .rateLimitError:
            return true
        case .apiError, .dataError:
            return true
        case .authenticationError, .configurationError:
            return false
        case .unknownError:
            return false
        }
    }
    
    private func scheduleRetry(for errorKey: String, context: String) {
        let currentAttempts = retryAttempts[errorKey] ?? 0
        
        guard currentAttempts < maxRetryAttempts else {
            print("Max retry attempts reached for \(errorKey)")
            return
        }
        
        retryAttempts[errorKey] = currentAttempts + 1
        
        DispatchQueue.main.async {
            self.isRetrying = true
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
            DispatchQueue.main.async {
                self.isRetrying = false
            }
            
            // Trigger retry based on context
            self.performRetry(for: context)
        }
    }
    
    private func performRetry(for context: String) {
        switch context {
        case "instagram_auth":
            // Retry authentication
            InstagramAuthService.shared.authenticate { _ in }
        case "instagram_posts":
            // Retry posts loading
            DataService.shared.refreshData()
        case "instagram_profile":
            // Retry profile loading
            DataService.shared.refreshData()
        default:
            // Generic retry
            DataService.shared.refreshData()
        }
    }
    
    // MARK: - Error Logging
    
    private func logError(_ error: AppError, context: String) {
        let logEntry = """
        [\(Date())] Error in \(context):
        Type: \(error)
        Description: \(error.localizedDescription)
        Recovery: \(error.recoverySuggestion ?? "No suggestion")
        Severity: \(error.severity)
        """
        
        print(logEntry)
        
        // In a production app, you might want to send this to a logging service
        // like Crashlytics, Sentry, or your own analytics service
    }
    
    // MARK: - Error Recovery
    
    func clearError() {
        DispatchQueue.main.async {
            self.lastError = nil
        }
    }
    
    func resetErrorCount() {
        DispatchQueue.main.async {
            self.errorCount = 0
            self.retryAttempts.removeAll()
        }
    }
    
    func manualRetry(for context: String) {
        retryAttempts.removeValue(forKey: context)
        performRetry(for: context)
    }
    
    // MARK: - Error State
    
    var hasRecentError: Bool {
        guard let lastError = lastError else { return false }
        
        // Consider error "recent" if it occurred within the last 5 minutes
        // This would require storing timestamps, but for now we'll use a simple approach
        return errorCount > 0
    }
    
    var shouldShowErrorAlert: Bool {
        return lastError?.severity == .critical || lastError?.severity == .error
    }
}
