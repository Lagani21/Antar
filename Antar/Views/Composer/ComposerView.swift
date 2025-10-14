//
//  ComposerView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct ComposerView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var caption = ""
    @State private var scheduledDate = Date()
    @State private var isScheduled = false
    @State private var showingDatePicker = false
    @Environment(\.dismiss) var dismiss
    
    private let characterLimit = 2200
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Media Placeholder
                    MediaPlaceholderView()
                    
                    // Caption Section
                    CaptionSectionView(caption: $caption, characterLimit: characterLimit)
                    
                    // Scheduling Section
                    SchedulingSectionView(
                        isScheduled: $isScheduled,
                        scheduledDate: $scheduledDate,
                        showingDatePicker: $showingDatePicker
                    )
                    
                    // Action Buttons
                    ActionButtonsView(
                        caption: caption,
                        isScheduled: isScheduled,
                        scheduledDate: scheduledDate,
                        mockDataService: mockDataService,
                        dismiss: dismiss
                    )
                }
                .padding()
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MediaPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Tap to add photos or videos")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
        )
    }
}

struct CaptionSectionView: View {
    @Binding var caption: String
    let characterLimit: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Caption")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(caption.count)/\(characterLimit)")
                    .font(.caption)
                    .foregroundColor(caption.count > characterLimit ? .red : .secondary)
            }
            
            TextEditor(text: $caption)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(caption.count > characterLimit ? Color.red : Color.clear, lineWidth: 1)
                )
            
            Button(action: { generateAICaption() }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate AI Caption")
                }
                .font(.callout)
                .foregroundColor(.blue)
            }
        }
    }
    
    private func generateAICaption() {
        let aiCaptions = [
            "✨ Embrace the journey, not just the destination 🌟",
            "Creating memories one adventure at a time 🌍✈️",
            "Living in the moment, loving every second 💫",
            "Dream big, travel far, live fully 🗺️❤️",
            "Chasing sunsets and making memories 🌅",
            "Not all who wander are lost 🌍",
            "The world is a book, and those who do not travel read only one page 📖"
        ]
        
        caption = aiCaptions.randomElement() ?? aiCaptions[0]
    }
}

struct SchedulingSectionView: View {
    @Binding var isScheduled: Bool
    @Binding var scheduledDate: Date
    @Binding var showingDatePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Schedule for later", isOn: $isScheduled)
                .font(.headline)
                .tint(.blue)
            
            if isScheduled {
                Button(action: { showingDatePicker = true }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(formatDateForDisplay(scheduledDate))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.callout)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showingDatePicker) {
                    DatePickerSheet(scheduledDate: $scheduledDate)
                }
            }
        }
    }
    
    private func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DatePickerSheet: View {
    @Binding var scheduledDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date & Time",
                    selection: $scheduledDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Schedule Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ActionButtonsView: View {
    let caption: String
    let isScheduled: Bool
    let scheduledDate: Date
    let mockDataService: MockDataService
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 12) {
            if isScheduled {
                Button(action: { schedulePost() }) {
                    Text("Schedule Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canSave ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSave)
            }
            
            Button(action: { saveAsDraft() }) {
                Text("Save as Draft")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            .disabled(!canSave)
        }
    }
    
    private var canSave: Bool {
        !caption.isEmpty
    }
    
    private func schedulePost() {
        let post = MockPost(
            caption: caption,
            status: .scheduled,
            scheduledTime: scheduledDate,
            accountId: mockDataService.activeAccount?.id ?? UUID()
        )
        mockDataService.posts.append(post)
        dismiss()
    }
    
    private func saveAsDraft() {
        let post = MockPost(
            caption: caption,
            status: .draft,
            accountId: mockDataService.activeAccount?.id ?? UUID()
        )
        mockDataService.posts.append(post)
        dismiss()
    }
}

#Preview {
    ComposerView()
        .environmentObject(MockDataService.shared)
}
