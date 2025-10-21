//
//  InstagramSetupGuideView.swift
//  Antar
//
//  Created by Lagani Patel on 10/17/25.
//

import SwiftUI

struct InstagramSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instagram API Setup")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Follow these steps to connect your Instagram account with real data")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Steps
                    VStack(spacing: 16) {
                        SetupStepView(
                            stepNumber: 1,
                            title: "Create Instagram App",
                            description: "Go to Facebook Developers and create a new app",
                            action: "Open Facebook Developers",
                            url: "https://developers.facebook.com/apps/"
                        )
                        
                        SetupStepView(
                            stepNumber: 2,
                            title: "Add Instagram Basic Display",
                            description: "In your app dashboard, add the Instagram Basic Display product",
                            action: nil,
                            url: nil
                        )
                        
                        SetupStepView(
                            stepNumber: 3,
                            title: "Configure OAuth Settings",
                            description: "Add this redirect URI to your Instagram app settings",
                            action: "Copy Redirect URI",
                            url: "antarapp://instagram-callback",
                            isCodeBlock: true
                        )
                        
                        SetupStepView(
                            stepNumber: 4,
                            title: "Get Your Credentials",
                            description: "Copy your App ID and App Secret from the Instagram Basic Display settings",
                            action: nil,
                            url: nil
                        )
                        
                        SetupStepView(
                            stepNumber: 5,
                            title: "Update Configuration",
                            description: "Replace the placeholder values in InstagramAPIConfig.swift with your actual credentials",
                            action: "Open Config File",
                            url: nil
                        )
                    }
                    .padding(.horizontal)
                    
                    // Important Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Important Notes")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            NoteItem(text: "Never commit your actual credentials to version control")
                            NoteItem(text: "Keep your App Secret secure and private")
                            NoteItem(text: "Test with your own Instagram account first")
                            NoteItem(text: "Make sure your Instagram account is a Business or Creator account")
                        }
                    }
                    .padding()
                    .background(Color.antarButton)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Setup Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SetupStepView: View {
    let stepNumber: Int
    let title: String
    let description: String
    let action: String?
    let url: String?
    let isCodeBlock: Bool
    
    init(stepNumber: Int, title: String, description: String, action: String?, url: String?, isCodeBlock: Bool = false) {
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.action = action
        self.url = url
        self.isCodeBlock = isCodeBlock
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            Text("\(stepNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.antarDark)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let action = action, let url = url {
                    Button(action: {
                        if isCodeBlock {
                            UIPasteboard.general.string = url
                        } else {
                            if let url = URL(string: url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        HStack {
                            if isCodeBlock {
                                Image(systemName: "doc.on.doc")
                            } else {
                                Image(systemName: "arrow.up.right")
                            }
                            Text(action)
                        }
                        .font(.caption)
                        .foregroundColor(.antarDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.antarDark.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.antarButton)
        .cornerRadius(12)
    }
}

struct NoteItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    InstagramSetupGuideView()
}
