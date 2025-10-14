//
//  DraftsView.swift
//  Antar
//
//  Created by Lagani Patel on 10/13/25.
//

import SwiftUI

struct DraftsView: View {
    @EnvironmentObject var mockDataService: MockDataService
    
    var body: some View {
        NavigationView {
            ScrollView {
                if mockDataService.draftPosts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Drafts")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create a post and save it as a draft to see it here!")
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
            .navigationTitle("Drafts")
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
                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 120)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.7))
                )
            
            // Caption
            Text(post.caption.isEmpty ? "No caption" : post.caption)
                .font(.callout)
                .lineLimit(2)
            
            // Date
            Text(formatDraftDate(post.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
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

#Preview {
    DraftsView()
        .environmentObject(MockDataService.shared)
}
