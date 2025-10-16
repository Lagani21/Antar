//
//  CalendarView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar Header
                CalendarHeaderView(currentMonth: $currentMonth)
                
                // Calendar Grid
                CalendarGridView(
                    selectedDate: $selectedDate,
                    currentMonth: currentMonth,
                    posts: mockDataService.posts
                )
                
                // Posts for Selected Date
                SelectedDatePostsView(
                    selectedDate: selectedDate,
                    posts: mockDataService.posts
                )
            }
            .navigationTitle("Calendar")
            .background(Color.antarBase)
        }
    }
}

struct CalendarHeaderView: View {
    @Binding var currentMonth: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button(action: { previousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.antarDark)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: currentMonth))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: { nextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.antarDark)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.antarButton)
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private let calendar = Calendar.current
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let currentMonth: Date
    let posts: [MockPost]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            posts: postsForDate(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthInterval.end {
            if calendar.isDate(currentDate, equalTo: monthInterval.start, toGranularity: .month) {
                days.append(currentDate)
            } else if days.count < 42 {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    private func postsForDate(_ date: Date) -> [MockPost] {
        posts.filter { post in
            let postDate = post.scheduledTime ?? post.publishedTime
            return postDate != nil && calendar.isDate(postDate!, inSameDayAs: date)
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let posts: [MockPost]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .white : (isSelected ? .antarDark : .primary))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isToday ? Color.antarDark : (isSelected ? Color.antarDark.opacity(0.2) : Color.clear))
                )
            
            // Post indicators
            HStack(spacing: 2) {
                ForEach(Array(posts.prefix(3)), id: \.id) { post in
                    Circle()
                        .fill(post.status.color)
                        .frame(width: 4, height: 4)
                }
            }
            
            if posts.count > 3 {
                Text("+\(posts.count - 3)")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
    }
}

struct SelectedDatePostsView: View {
    let selectedDate: Date
    let posts: [MockPost]
    
    private let calendar = Calendar.current
    
    var body: some View {
        let dayPosts = posts.filter { post in
            let postDate = post.scheduledTime ?? post.publishedTime
            return postDate != nil && calendar.isDate(postDate!, inSameDayAs: selectedDate)
        }
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Posts for \(formatSelectedDate(selectedDate))")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !dayPosts.isEmpty {
                    Text("\(dayPosts.count) post\(dayPosts.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.antarDark.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if dayPosts.isEmpty {
                Text("No posts scheduled for this date")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(dayPosts) { post in
                    CalendarPostCard(post: post)
                }
            }
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
        .padding()
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

struct CalendarPostCard: View {
    let post: MockPost
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(post.status.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.caption.isEmpty ? "No caption" : post.caption)
                    .font(.callout)
                    .lineLimit(2)
                
                HStack {
                    Text(post.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(post.status.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(post.status.color.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    if let time = post.scheduledTime ?? post.publishedTime {
                        Text(formatPostTime(time))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.antarButton)
        .cornerRadius(8)
    }
    
    private func formatPostTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
        .environmentObject(MockDataService.shared)
}
