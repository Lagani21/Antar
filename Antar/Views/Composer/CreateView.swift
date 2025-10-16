//
//  CreateView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

enum ContentType: String, CaseIterable, Codable {
    case post = "Post"
    case reel = "Reel"
    case story = "Story"
    
    var icon: String {
        switch self {
        case .post: return "square.and.pencil"
        case .reel: return "video.fill"
        case .story: return "circle.grid.3x3.fill"
        }
    }
}

struct CreateView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var selectedContentType: ContentType = .post
    @State private var caption = ""
    @State private var scheduledDate = Date()
    @State private var isScheduled = false
    @State private var showingDatePicker = false
    @State private var notepadText = ""
    
    private let characterLimit = 2200
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Content Type Selection
                    ContentTypeSelector(selectedType: $selectedContentType)
                    
                    // Media Placeholder
                    MediaPlaceholderView(contentType: selectedContentType)
                    
                    // Caption Section
                    CaptionSectionView(caption: $caption, characterLimit: characterLimit)
                    
                    // Notepad Section
                    NotepadSectionView(notepadText: $notepadText)
                    
                    // Scheduling Section
                    SchedulingSectionView(
                        isScheduled: $isScheduled,
                        scheduledDate: $scheduledDate,
                        showingDatePicker: $showingDatePicker
                    )
                    
                    // Action Buttons
                    ActionButtonsView(
                        caption: caption,
                        notepadText: notepadText,
                        isScheduled: isScheduled,
                        scheduledDate: scheduledDate,
                        contentType: selectedContentType,
                        mockDataService: mockDataService
                    )
                }
                .padding()
        }
        .navigationTitle("Create")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.antarBase)
        }
    }
}

struct ContentTypeSelector: View {
    @Binding var selectedType: ContentType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content Type")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(ContentType.allCases, id: \.self) { type in
                    ContentTypeCard(
                        type: type,
                        isSelected: selectedType == type
                    )
                    .onTapGesture {
                        selectedType = type
                    }
                }
            }
        }
    }
}

struct ContentTypeCard: View {
    let type: ContentType
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.system(size: 28))
                .foregroundColor(isSelected ? .white : .antarDark)
            
            Text(type.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(isSelected ? Color.antarDark : Color.antarButton)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.antarDark : Color.clear, lineWidth: 2)
        )
    }
}

struct MediaPlaceholderView: View {
    let contentType: ContentType
    
    var placeholderText: String {
        switch contentType {
        case .post:
            return "Tap to add photos or videos"
        case .reel:
            return "Tap to add a video for your reel"
        case .story:
            return "Tap to add photo or video for your story"
        }
    }
    
    var placeholderIcon: String {
        switch contentType {
        case .post:
            return "photo.on.rectangle.angled"
        case .reel:
            return "video.badge.plus"
        case .story:
            return "photo.stack"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: placeholderIcon)
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(placeholderText)
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color.antarButton)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.antarDark.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
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
                    .foregroundColor(caption.count > characterLimit ? .antarAccent1 : .secondary)
            }
            
            TextEditor(text: $caption)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.antarButton)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(caption.count > characterLimit ? Color.antarAccent1 : Color.clear, lineWidth: 1)
                )
            
            Button(action: { generateAICaption() }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate AI Caption")
                }
                .font(.callout)
                .foregroundColor(.antarDark)
            }
        }
    }
    
    private func generateAICaption() {
        let aiCaptions = [
            "Embrace the journey, not just the destination",
            "Creating memories one adventure at a time",
            "Living in the moment, loving every second ",
            "Dream big, travel far, live fully",
            "Chasing sunsets and making memories",
            "Not all who wander are lost",
            "The world is a book, and those who do not travel read only one page "
        ]
        
        caption = aiCaptions.randomElement() ?? aiCaptions[0]
    }
}

struct NotepadSectionView: View {
    @Binding var notepadText: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.antarDark)
                    Text("Notepad")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keep extra notes and draft ideas here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notepadText)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color.antarButton)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
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
                .tint(.antarDark)
            
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
                    .background(Color.antarButton)
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
    let notepadText: String
    let isScheduled: Bool
    let scheduledDate: Date
    let contentType: ContentType
    let mockDataService: MockDataService
    
    var scheduleButtonText: String {
        "Schedule \(contentType.rawValue)"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if isScheduled {
                Button(action: { schedulePost() }) {
                    Text(scheduleButtonText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canSave ? Color.antarDark : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSave)
            }
            
            Button(action: { saveAsDraft() }) {
                Text("Save as Draft")
                    .font(.headline)
                    .foregroundColor(.antarDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.antarDark.opacity(0.1))
                    .cornerRadius(12)
            }
            .disabled(!canSave)
        }
    }
    
    private var canSave: Bool {
        !caption.isEmpty || !notepadText.isEmpty
    }
    
    private func schedulePost() {
        let post = MockPost(
            caption: caption.isEmpty ? notepadText : caption,
            status: .scheduled,
            scheduledTime: scheduledDate,
            accountId: mockDataService.activeAccount?.id ?? UUID(),
            contentType: contentType
        )
        mockDataService.addPost(post)
    }
    
    private func saveAsDraft() {
        let post = MockPost(
            caption: caption.isEmpty ? notepadText : caption,
            status: .draft,
            accountId: mockDataService.activeAccount?.id ?? UUID(),
            contentType: contentType
        )
        mockDataService.addPost(post)
    }
}

#Preview {
    CreateView()
        .environmentObject(MockDataService.shared)
}

