//
//  DraftsView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct DraftsView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @State private var showingCreateDraft = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Create Draft Button
                Button(action: { showingCreateDraft = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Create Draft")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.antarDark)
                    .cornerRadius(12)
                }
                .padding()
                
                // Drafts List
                ScrollView {
                    if mockDataService.draftPosts.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Drafts")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Create a draft to save your ideas!")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(mockDataService.draftPosts) { post in
                                DraftCard(post: post)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Drafts")
            .background(Color.antarBase)
            .sheet(isPresented: $showingCreateDraft) {
                CreateDraftView()
                    .environmentObject(mockDataService)
            }
        }
    }
}

struct DraftCard: View {
    let post: MockPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail placeholder
            Rectangle()
                .fill(LinearGradient(
                    colors: [.antarDark.opacity(0.2), .antarAccent1.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 120)
                .cornerRadius(8)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: post.contentType.icon)
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(post.contentType.rawValue)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(post.caption.isEmpty ? "No caption" : post.caption)
                    .font(.callout)
                    .lineLimit(2)
                
                HStack {
                    Text(post.contentType.rawValue)
                        .font(.caption)
                        .foregroundColor(post.contentType == .post ? .antarDark : 
                                       post.contentType == .reel ? .antarAccent1 : .antarAccent2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((post.contentType == .post ? Color.antarDark : 
                                   post.contentType == .reel ? Color.antarAccent1 : Color.antarAccent2).opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(formatDraftDate(post.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

func formatDraftDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// MARK: - Create Draft View
struct CreateDraftView: View {
    @EnvironmentObject var mockDataService: MockDataService
    @Environment(\.dismiss) var dismiss
    @State private var selectedContentType: ContentType = .post
    @State private var caption = ""
    @State private var notepadText = ""
    @State private var hasMedia = false
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    
    private let characterLimit = 2200
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Content Type Selection
                    ContentTypeSelector(selectedType: $selectedContentType)
                    
                    // Media Section
                    MediaSectionView(
                        contentType: selectedContentType,
                        hasMedia: $hasMedia,
                        showingImagePicker: $showingImagePicker,
                        showingVideoPicker: $showingVideoPicker
                    )
                    
                    // Caption Section
                    CaptionSectionView(caption: $caption, characterLimit: characterLimit)
                    
                    // Notepad Section
                    NotepadSectionView(notepadText: $notepadText)
                    
                    // Save Draft Button
                    Button(action: { saveDraft() }) {
                        Text("Save Draft")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(canSave ? Color.antarDark : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle("Create Draft")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.antarBase)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var canSave: Bool {
        !caption.isEmpty || hasMedia || !notepadText.isEmpty
    }
    
    private func saveDraft() {
        let post = MockPost(
            caption: caption.isEmpty ? notepadText : caption,
            mediaUrls: hasMedia ? ["draft_media"] : [],
            status: .draft,
            accountId: mockDataService.activeAccount?.id ?? UUID(),
            contentType: selectedContentType
        )
        mockDataService.addPost(post)
        dismiss()
    }
}

// MARK: - Media Section View
struct MediaSectionView: View {
    let contentType: ContentType
    @Binding var hasMedia: Bool
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Media (Optional)")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: { showingImagePicker = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                            .font(.title2)
                        Text("Add Image")
                            .font(.caption)
                    }
                    .foregroundColor(.antarDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.antarDark.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: { showingVideoPicker = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "video.fill")
                            .font(.title2)
                        Text("Add Video")
                            .font(.caption)
                    }
                    .foregroundColor(.antarDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.antarDark.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            if hasMedia {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.antarAccent3)
                    Text("Media added")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Remove") {
                        hasMedia = false
                    }
                    .font(.caption)
                    .foregroundColor(.antarAccent1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.antarAccent3.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(hasMedia: $hasMedia)
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPickerView(hasMedia: $hasMedia)
        }
    }
}

// MARK: - Image Picker View
struct ImagePickerView: View {
    @Binding var hasMedia: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.antarDark)
                
                Text("Image Picker")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select an image for your draft")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Simulate Image Selection") {
                    hasMedia = true
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.antarDark)
                .cornerRadius(12)
                .padding()
            }
            .padding()
            .navigationTitle("Select Image")
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

// MARK: - Video Picker View
struct VideoPickerView: View {
    @Binding var hasMedia: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "video.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.antarDark)
                
                Text("Video Picker")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select a video for your draft")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Simulate Video Selection") {
                    hasMedia = true
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.antarDark)
                .cornerRadius(12)
                .padding()
            }
            .padding()
            .navigationTitle("Select Video")
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

#Preview {
    DraftsView()
        .environmentObject(MockDataService.shared)
}
