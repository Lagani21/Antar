//
//  FollowerAnalyticsView.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import SwiftUI

struct FollowerAnalyticsView: View {
    let account: InstagramAccount
    
    @StateObject private var analyticsService = FollowerAnalyticsService.shared
    @State private var selectedTimeframe: FollowerAnalyticsTimeframe = .week
    @State private var selectedMetric: MetricType = .followers
    
    enum MetricType: String, CaseIterable {
        case followers = "Followers"
        case following = "Following"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Account Header
                accountHeader
                
                // Metric Selector
                metricSelector
                
                // Timeframe Selector
                timeframeSelector
                
                // Stats Cards
                statsCards
                
                // Chart
                chartView
                
                // Growth Insights
                growthInsights
            }
            .padding()
        }
        .background(Color.antarBase.ignoresSafeArea())
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Generate mock history if needed
            if analyticsService.followerHistory[account.id] == nil {
                analyticsService.generateMockHistoryForAccount(account)
            }
        }
    }
    
    // MARK: - Account Header
    
    private var accountHeader: some View {
        return HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(
                    colors: [.antarDark, .antarAccent1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(account.username.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(account.username)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(account.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(16)
    }
    
    // MARK: - Metric Selector
    
    private var metricSelector: some View {
        return Picker("Metric", selection: $selectedMetric) {
            ForEach(MetricType.allCases, id: \.self) { metric in
                Text(metric.rawValue).tag(metric)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    // MARK: - Timeframe Selector
    
    private var timeframeSelector: some View {
        return HStack(spacing: 12) {
            ForEach(FollowerAnalyticsTimeframe.allCases, id: \.self) { timeframe in
                Button(action: {
                    withAnimation {
                        selectedTimeframe = timeframe
                    }
                }) {
                    Text(timeframe.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .antarDark)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedTimeframe == timeframe ? Color.antarDark : Color.antarButton
                        )
                        .cornerRadius(20)
                }
            }
        }
    }
    
    // MARK: - Stats Cards
    
    private var statsCards: some View {
        return HStack(spacing: 12) {
            // Current Count
            StatCard(
                title: selectedMetric == .followers ? "Followers" : "Following",
                value: "\(formatNumber(currentCount))",
                icon: "person.2.fill",
                color: .antarAccent1
            )
            
            // Growth
            StatCard(
                title: "Growth",
                value: growthText,
                icon: growth >= 0 ? "arrow.up.right" : "arrow.down.right",
                color: growth >= 0 ? .green : .red
            )
            
            // Percentage
            StatCard(
                title: "Change",
                value: String(format: "%.1f%%", abs(growthPercentage)),
                icon: "percent",
                color: growthPercentage >= 0 ? .green : .red
            )
        }
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        return VStack(alignment: .leading, spacing: 12) {
            Text("Trend")
                .font(.headline)
                .foregroundColor(.primary)
            
            if dataPoints.isEmpty {
                EmptyChartView()
            } else {
                CustomLineChart(dataPoints: dataPoints)
                    .frame(height: 250)
            }
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(16)
    }
    
    // MARK: - Growth Insights
    
    private var growthInsights: some View {
        return VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.headline)
                .foregroundColor(.primary)
            
            if growth > 0 {
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "You gained \(abs(growth)) \(selectedMetric == .followers ? "followers" : "following") in the last \(selectedTimeframe.rawValue.lowercased())",
                    color: .green
                )
            } else if growth < 0 {
                InsightRow(
                    icon: "chart.line.downtrend.xyaxis",
                    text: "You lost \(abs(growth)) \(selectedMetric == .followers ? "followers" : "following") in the last \(selectedTimeframe.rawValue.lowercased())",
                    color: .red
                )
            } else {
                InsightRow(
                    icon: "minus.circle",
                    text: "No change in the last \(selectedTimeframe.rawValue.lowercased())",
                    color: .gray
                )
            }
            
            if selectedMetric == .followers && growth > 0 {
                InsightRow(
                    icon: "calendar",
                    text: String(format: "Average of %.1f new followers per day", Double(growth) / Double(selectedTimeframe.numberOfDataPoints)),
                    color: .antarAccent1
                )
            }
            
            if let peak = dataPoints.max(by: { $0.count < $1.count }) {
                InsightRow(
                    icon: "star.fill",
                    text: "Peak of \(formatNumber(peak.count)) on \(peak.date.formatted(date: .abbreviated, time: .omitted))",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    
    private var dataPoints: [FollowerDataPoint] {
        if selectedMetric == .followers {
            return analyticsService.getFollowerData(for: account.id, timeframe: selectedTimeframe)
        } else {
            return analyticsService.getFollowingData(for: account.id, timeframe: selectedTimeframe)
        }
    }
    
    private var currentCount: Int {
        selectedMetric == .followers ? account.followersCount : account.followingCount
    }
    
    private var growth: Int {
        analyticsService.getFollowerGrowth(for: account.id, timeframe: selectedTimeframe)
    }
    
    private var growthPercentage: Double {
        analyticsService.getFollowerGrowthPercentage(for: account.id, timeframe: selectedTimeframe)
    }
    
    private var growthText: String {
        let sign = growth >= 0 ? "+" : ""
        return "\(sign)\(growth)"
    }
    
    // MARK: - Helper Functions
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct EmptyChartView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No data available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Analytics will appear here once you start tracking your account")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
    }
}

struct CustomLineChart: View {
    let dataPoints: [FollowerDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let minValue = CGFloat(dataPoints.map { $0.count }.min() ?? 0)
            let maxValue = CGFloat(dataPoints.map { $0.count }.max() ?? 1)
            let range = maxValue - minValue
            
            ZStack(alignment: .bottomLeading) {
                // Background grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        Spacer()
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        Spacer()
                    }
                }
                
                // Area fill
                Path { path in
                    let points = dataPoints.enumerated().map { index, point -> CGPoint in
                        let x = (width / CGFloat(max(dataPoints.count - 1, 1))) * CGFloat(index)
                        let normalizedValue = range > 0 ? (CGFloat(point.count) - minValue) / range : 0.5
                        let y = height - (normalizedValue * height)
                        return CGPoint(x: x, y: y)
                    }
                    
                    guard let firstPoint = points.first else { return }
                    path.move(to: CGPoint(x: firstPoint.x, y: height))
                    path.addLine(to: firstPoint)
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    
                    if let lastPoint = points.last {
                        path.addLine(to: CGPoint(x: lastPoint.x, y: height))
                    }
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [.antarDark.opacity(0.2), .antarAccent1.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Line path
                Path { path in
                    let points = dataPoints.enumerated().map { index, point -> CGPoint in
                        let x = (width / CGFloat(max(dataPoints.count - 1, 1))) * CGFloat(index)
                        let normalizedValue = range > 0 ? (CGFloat(point.count) - minValue) / range : 0.5
                        let y = height - (normalizedValue * height)
                        return CGPoint(x: x, y: y)
                    }
                    
                    guard let firstPoint = points.first else { return }
                    path.move(to: firstPoint)
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [.antarDark, .antarAccent1],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 3
                )
                
                // Data point dots
                ForEach(dataPoints.enumerated().map { $0 }, id: \.offset) { index, point in
                    let x = (width / CGFloat(max(dataPoints.count - 1, 1))) * CGFloat(index)
                    let normalizedValue = range > 0 ? (CGFloat(point.count) - minValue) / range : 0.5
                    let y = height - (normalizedValue * height)
                    
                    Circle()
                        .fill(Color.antarDark)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
        .background(Color.antarBase.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        FollowerAnalyticsView(
            account: InstagramAccount(
                username: "travel_explorer",
                displayName: "Travel Explorer",
                followersCount: 15420,
                followingCount: 892
            )
        )
    }
}