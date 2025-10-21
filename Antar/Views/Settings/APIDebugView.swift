//
//  APIDebugView.swift
//  Antar
//
//  Displays API request/response flow for portfolio demonstration
//

import SwiftUI

struct APIDebugView: View {
    @StateObject private var logger = APIRequestLogger.shared
    @StateObject private var mockAPI = MockInstagramGraphAPIService.shared
    
    @State private var selectedRequest: APIRequest?
    @State private var showingPublishDemo = false
    @State private var demoImageUrl = "https://picsum.photos/1080/1080"
    @State private var demoCaption = "Check out this amazing demo post! 🚀 #Instagram #API #Demo"
    @State private var publishResult: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with controls
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("API Request Monitor")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("\(logger.requests.count) requests logged")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { logger.clear() }) {
                            Label("Clear", systemImage: "trash")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Demo Actions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            DemoButton(
                                title: "Get Profile",
                                icon: "person.circle.fill",
                                color: .blue
                            ) {
                                Task {
                                    _ = await mockAPI.getUserProfile()
                                }
                            }
                            
                            DemoButton(
                                title: "Get Media",
                                icon: "photo.stack.fill",
                                color: .purple
                            ) {
                                Task {
                                    _ = await mockAPI.getUserMedia()
                                }
                            }
                            
                            DemoButton(
                                title: "Get Insights",
                                icon: "chart.bar.fill",
                                color: .orange
                            ) {
                                Task {
                                    _ = await mockAPI.getMediaInsights(mediaId: "17895695668004550")
                                }
                            }
                            
                            DemoButton(
                                title: "Publish Post",
                                icon: "square.and.arrow.up.fill",
                                color: .green
                            ) {
                                showingPublishDemo = true
                            }
                            
                            DemoButton(
                                title: "Account Insights",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .pink
                            ) {
                                Task {
                                    _ = await mockAPI.getAccountInsights()
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color.antarButton)
                
                // Request/Response List
                if logger.requests.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(logger.getRequestHistory(), id: \.0.id) { request, response in
                            RequestResponseRow(request: request, response: response)
                                .onTapGesture {
                                    selectedRequest = request
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.antarBase)
            .sheet(item: $selectedRequest) { request in
                RequestDetailView(
                    request: request,
                    response: logger.responses.first { $0.requestId == request.id }
                )
            }
            .sheet(isPresented: $showingPublishDemo) {
                PublishDemoView(
                    imageUrl: $demoImageUrl,
                    caption: $demoCaption,
                    publishResult: $publishResult
                )
            }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No API Requests Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Tap any demo button above to simulate an Instagram Graph API request")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.antarBase)
    }
}

// MARK: - Demo Button

struct DemoButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 100, height: 70)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Request/Response Row

struct RequestResponseRow: View {
    let request: APIRequest
    let response: APIResponse?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Method Badge
                Text(request.method)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(methodColor(request.method))
                    .cornerRadius(4)
                
                // Status Badge
                if let response = response {
                    Text("\(response.statusCode)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(response.statusCode))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Timestamp
                Text(timeAgo(from: request.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(request.description)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            // Endpoint
            Text(request.endpoint)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            // Response description
            if let response = response {
                Text(response.description)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func methodColor(_ method: String) -> Color {
        switch method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }
    
    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .purple
        default: return .gray
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "\(seconds)s ago"
        } else if seconds < 3600 {
            return "\(seconds / 60)m ago"
        } else {
            return "\(seconds / 3600)h ago"
        }
    }
}

// MARK: - Request Detail View

struct RequestDetailView: View {
    let request: APIRequest
    let response: APIResponse?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Request Section
                    DetailSection(title: "REQUEST") {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Method", value: request.method, color: .blue)
                            DetailRow(label: "Endpoint", value: request.endpoint, color: .primary)
                            DetailRow(label: "Time", value: formatDate(request.timestamp), color: .secondary)
                            
                            if !request.headers.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Headers")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    ForEach(Array(request.headers.keys.sorted()), id: \.self) { key in
                                        HStack {
                                            Text(key)
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.secondary)
                                            Text(":")
                                                .foregroundColor(.secondary)
                                            Text(request.headers[key] ?? "")
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            if let body = request.body {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Body")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(formatJSON(body))
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Response Section
                    if let response = response {
                        DetailSection(title: "RESPONSE") {
                            VStack(alignment: .leading, spacing: 12) {
                                DetailRow(
                                    label: "Status",
                                    value: "\(response.statusCode) \(statusText(response.statusCode))",
                                    color: response.statusCode < 300 ? .green : .red
                                )
                                DetailRow(label: "Time", value: formatDate(response.timestamp), color: .secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Body")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        Text(response.body)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.primary)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .frame(maxHeight: 300)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.antarBase)
            .navigationTitle("Request Details")
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func statusText(_ code: Int) -> String {
        switch code {
        case 200: return "OK"
        case 201: return "Created"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 500: return "Internal Server Error"
        default: return ""
        }
    }
    
    private func formatJSON(_ dictionary: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            content
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.antarButton)
                .cornerRadius(12)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

// MARK: - Publish Demo View

struct PublishDemoView: View {
    @Binding var imageUrl: String
    @Binding var caption: String
    @Binding var publishResult: String?
    
    @StateObject private var mockAPI = MockInstagramGraphAPIService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isPublishing = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Simulate Post Publishing")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("This will demonstrate the 2-step Instagram publishing flow")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Preview
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Image URL
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Image URL")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextField("https://...", text: $imageUrl)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                    }
                    .padding(.horizontal)
                    
                    // Caption
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caption")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $caption)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Publish Button
                    Button(action: publishPost) {
                        HStack {
                            if isPublishing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Publishing...")
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Publish to Instagram")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.antarDark, .antarAccent1],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isPublishing)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if let result = publishResult {
                        Text(result)
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    // Flow Explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Publishing Flow")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        FlowStep(number: 1, title: "Create Media Container", description: "POST to /me/media with image_url and caption")
                        FlowStep(number: 2, title: "Publish Container", description: "POST to /me/media_publish with creation_id")
                        FlowStep(number: 3, title: "Get Media ID", description: "Receive published media ID in response")
                    }
                    .padding()
                    .background(Color.antarButton)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(Color.antarBase)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Success!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Post published successfully! Check the API log to see the request/response flow.")
            }
        }
    }
    
    private func publishPost() {
        isPublishing = true
        publishResult = nil
        
        Task {
            let result = await mockAPI.demonstratePublishingFlow(imageUrl: imageUrl, caption: caption)
            
            await MainActor.run {
                isPublishing = false
                
                switch result {
                case .success(let mediaId):
                    publishResult = "✅ Published! Media ID: \(mediaId)"
                    showSuccess = true
                case .failure(let error):
                    publishResult = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct FlowStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.antarDark)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    APIDebugView()
}

