//
//  BackgroundSyncService.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import Foundation
import BackgroundTasks
import UserNotifications
import Combine

class BackgroundSyncService: ObservableObject {
    static let shared = BackgroundSyncService()
    
    @Published var lastSyncDate: Date?
    @Published var isSyncing = false
    @Published var syncStatus: SyncStatus = .idle
    
    private let dataService = DataService.shared
    private let errorHandling = ErrorHandlingService.shared
    private let rateLimitService = APIRateLimitService.shared
    
    private var syncTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBackgroundTasks()
        loadSyncData()
    }
    
    // MARK: - Sync Status
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case failed(Error)
        case rateLimited
        case noData
        
        var description: String {
            switch self {
            case .idle:
                return "Ready to sync"
            case .syncing:
                return "Syncing data..."
            case .success:
                return "Sync completed successfully"
            case .failed(let error):
                return "Sync failed: \(error.localizedDescription)"
            case .rateLimited:
                return "Rate limited - waiting to retry"
            case .noData:
                return "No data to sync"
            }
        }
        
        var color: String {
            switch self {
            case .idle:
                return "gray"
            case .syncing:
                return "blue"
            case .success:
                return "green"
            case .failed:
                return "red"
            case .rateLimited:
                return "orange"
            case .noData:
                return "yellow"
            }
        }
    }
    
    // MARK: - Background Tasks Setup
    
    private func setupBackgroundTasks() {
        // Register background task identifier
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.antar.background-sync", using: nil) { task in
            self.handleBackgroundSync(task: task as! BGAppRefreshTask)
        }
        
        // Request background app refresh permission
        requestBackgroundAppRefreshPermission()
    }
    
    private func requestBackgroundAppRefreshPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Background app refresh permission granted")
            } else {
                print("Background app refresh permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Sync Management
    
    func startPeriodicSync() {
        // Stop existing timer
        stopPeriodicSync()
        
        // Start new timer - sync every 30 minutes
        syncTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.performSync()
        }
        
        print("Started periodic sync (every 30 minutes)")
    }
    
    func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
        print("Stopped periodic sync")
    }
    
    func performSync() {
        guard !isSyncing else {
            print("Sync already in progress")
            return
        }
        
        guard InstagramAPIConfig.isConfigured else {
            print("Instagram API not configured - skipping sync")
            syncStatus = .noData
            return
        }
        
        guard rateLimitService.canMakeRequest() else {
            print("Rate limited - skipping sync")
            syncStatus = .rateLimited
            return
        }
        
        isSyncing = true
        syncStatus = .syncing
        
        print("Starting background sync...")
        
        // Perform sync in background
        Task {
            await performBackgroundSync()
        }
    }
    
    @MainActor
    private func performBackgroundSync() async {
        do {
            // Refresh data from Instagram API
            dataService.refreshData()
            
            // Wait for data to load
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            
            // Check if sync was successful
            if dataService.posts.isEmpty && dataService.accounts.isEmpty {
                syncStatus = .noData
            } else {
                syncStatus = .success
                lastSyncDate = Date()
                saveSyncData()
                
                // Send success notification
                sendSyncNotification(success: true)
            }
            
        } catch {
            syncStatus = .failed(error)
            errorHandling.handleError(error, context: "background_sync")
            
            // Send failure notification
            sendSyncNotification(success: false)
        }
        
        isSyncing = false
        print("Background sync completed: \(syncStatus.description)")
    }
    
    // MARK: - Background Task Handling
    
    private func handleBackgroundSync(task: BGAppRefreshTask) {
        print("Handling background sync task")
        
        // Set expiration handler
        task.expirationHandler = {
            print("Background sync task expired")
            task.setTaskCompleted(success: false)
        }
        
        // Perform sync
        Task {
            await performBackgroundSync()
            
            // Schedule next background task
            scheduleBackgroundTask()
            
            // Complete the task
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.antar.background-sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1800) // 30 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled next background sync task")
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }
    
    // MARK: - Notifications
    
    private func sendSyncNotification(success: Bool) {
        let content = UNMutableNotificationContent()
        
        if success {
            content.title = "Sync Complete"
            content.body = "Your Instagram data has been updated"
            content.sound = .default
        } else {
            content.title = "Sync Failed"
            content.body = "Failed to update Instagram data"
            content.sound = .default
        }
        
        let request = UNNotificationRequest(
            identifier: "sync-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send sync notification: \(error)")
            }
        }
    }
    
    // MARK: - Sync Status
    
    func getSyncStatus() -> SyncStatusInfo {
        let timeSinceLastSync = lastSyncDate?.timeIntervalSinceNow ?? -Double.infinity
        let hoursSinceLastSync = abs(timeSinceLastSync) / 3600
        
        return SyncStatusInfo(
            status: syncStatus,
            lastSyncDate: lastSyncDate,
            hoursSinceLastSync: hoursSinceLastSync,
            isStale: hoursSinceLastSync > 2, // Consider data stale after 2 hours
            nextSyncTime: getNextSyncTime()
        )
    }
    
    private func getNextSyncTime() -> Date? {
        guard let lastSync = lastSyncDate else { return Date() }
        return lastSync.addingTimeInterval(1800) // 30 minutes
    }
    
    // MARK: - Data Persistence
    
    private func saveSyncData() {
        let syncData = SyncData(
            lastSyncDate: lastSyncDate,
            syncStatus: syncStatus.description
        )
        
        if let encoded = try? JSONEncoder().encode(syncData) {
            UserDefaults.standard.set(encoded, forKey: "sync_data")
        }
    }
    
    private func loadSyncData() {
        guard let data = UserDefaults.standard.data(forKey: "sync_data"),
              let syncData = try? JSONDecoder().decode(SyncData.self, from: data) else {
            return
        }
        
        lastSyncDate = syncData.lastSyncDate
    }
    
    // MARK: - Manual Sync
    
    func forceSync() {
        print("Force sync requested")
        performSync()
    }
    
    func clearSyncData() {
        lastSyncDate = nil
        syncStatus = .idle
        UserDefaults.standard.removeObject(forKey: "sync_data")
        print("Cleared sync data")
    }
}

// MARK: - Supporting Types

struct SyncStatusInfo {
    let status: BackgroundSyncService.SyncStatus
    let lastSyncDate: Date?
    let hoursSinceLastSync: Double
    let isStale: Bool
    let nextSyncTime: Date?
    
    var statusMessage: String {
        if isStale {
            return "Data is stale - sync recommended"
        } else {
            return status.description
        }
    }
}

struct SyncData: Codable {
    let lastSyncDate: Date?
    let syncStatus: String
}
