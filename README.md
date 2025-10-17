# Antar - Instagram Management App

<div align="center">

📱 A powerful iOS app for managing your Instagram presence

**Schedule • Analyze • Engage**

</div>

---

## 🎯 About Antar

Antar is a comprehensive Instagram management application built with SwiftUI for iOS. Manage multiple Instagram accounts, schedule posts, analyze performance, and engage with your audience—all from one beautiful interface.

## ✨ Features

### 📊 Dashboard
- Real-time analytics overview
- Performance metrics
- Engagement tracking
- Content insights

### 📅 Content Calendar
- Visual post scheduling
- Drag-and-drop organization
- Multi-account support
- Timeline view

### ✍️ Post Composer
- Create posts, reels, and stories
- Caption editor with hashtag suggestions
- Image/video upload
- Schedule for optimal times

### 📈 Analytics
- Detailed post performance
- Follower growth tracking
- Engagement metrics
- Reach and impressions
- Historical data visualization

### 📝 Drafts
- Save work in progress
- Edit and refine content
- Schedule later

### ⚙️ Settings
- **Multiple account support**
- **Account switching**
- **Instagram OAuth integration**
- Preferences management

## 🔗 Instagram Integration

### ✅ Implemented Features

- **OAuth 2.0 Authentication** - Secure Instagram login
- **Multiple Account Support** - Manage multiple Instagram accounts
- **Secure Token Storage** - Keychain-based token management
- **User Profile Fetching** - Get account information
- **Media/Post Fetching** - Retrieve Instagram posts
- **Media Insights** - Access post analytics
- **Content Publishing** - Post to Instagram via API
- **Token Expiration Handling** - Automatic token validation

### 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│           Antar App (SwiftUI)           │
├─────────────────────────────────────────┤
│  Views          │  Services             │
│  • Settings     │  • InstagramAuth      │
│  • Dashboard    │  • InstagramAPI       │
│  • Calendar     │  • Keychain           │
│  • Composer     │  • MockData           │
├─────────────────────────────────────────┤
│         Instagram Graph API             │
│  • OAuth 2.0   • Media   • Insights     │
└─────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Xcode 14.0+
- iOS 15.0+
- Facebook Developer Account
- Instagram Account

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/antar.git
cd antar
```

### 2. Configure Instagram Integration

Follow the step-by-step guide:

📖 **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** - Complete setup checklist

Or quick setup:

📖 **[QUICK_START.md](QUICK_START.md)** - 5-minute setup guide

### 3. Run the App

```bash
open Antar.xcodeproj
# Select a simulator or device
# Press Cmd+R to run
```

## 📚 Documentation

### Setup & Configuration
- **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** - Step-by-step setup checklist
- **[QUICK_START.md](QUICK_START.md)** - Quick setup guide (5 min)
- **[INSTAGRAM_SETUP_GUIDE.md](INSTAGRAM_SETUP_GUIDE.md)** - Comprehensive setup guide

### Technical Documentation
- **[INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** - Technical implementation details
- **[Info.plist.template](Info.plist.template)** - Required iOS configuration

### Configuration Files
- **`InstagramAPIConfig.swift`** - API credentials and endpoints
- **`InstagramAPIConfig.example.swift`** - Template for credentials

## 🔐 Security

### Token Storage
- Access tokens stored in **iOS Keychain** (not UserDefaults)
- Automatic encryption by iOS
- Secure across app restarts

### OAuth Security
- CSRF protection with state parameters
- Uses Apple's `ASWebAuthenticationSession`
- No plaintext credential storage

### Credentials Protection
- `InstagramAPIConfig.swift` is gitignored
- Never commit API credentials
- Use environment variables for CI/CD

## 🛠️ Tech Stack

- **Language**: Swift 5.5+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Authentication**: ASWebAuthenticationSession
- **Networking**: URLSession
- **Secure Storage**: Keychain Services
- **Platform**: iOS 15.0+

## 📦 Project Structure

```
Antar/
├── Antar/
│   ├── Models/
│   │   ├── InstagramAccount.swift
│   │   └── MockPost.swift
│   ├── Services/
│   │   ├── KeychainService.swift
│   │   ├── InstagramAPIConfig.swift
│   │   ├── InstagramAuthService.swift
│   │   ├── InstagramAPIService.swift
│   │   └── MockDataService.swift
│   ├── Views/
│   │   ├── Dashboard/
│   │   ├── Calendar/
│   │   ├── Composer/
│   │   ├── Analytics/
│   │   ├── Drafts/
│   │   └── Settings/
│   ├── Extensions/
│   │   └── ColorScheme.swift
│   └── AntarApp.swift
├── Documentation/
│   ├── SETUP_CHECKLIST.md
│   ├── QUICK_START.md
│   ├── INSTAGRAM_SETUP_GUIDE.md
│   └── INTEGRATION_SUMMARY.md
└── README.md (this file)
```

## 🎨 Design System

### Colors
- **Primary**: Antar Dark (#1a1a1a-inspired)
- **Accents**: Gradient blues and purples
- **Background**: Soft neutral tones
- **Buttons**: High contrast for accessibility

### Typography
- System font (San Francisco)
- Dynamic type support
- Accessibility-friendly sizes

## 🧪 Testing

### Mock Data
The app includes a comprehensive mock data system:
- Sample accounts
- Sample posts, reels, stories
- Sample analytics data

Perfect for development without API calls.

### Real Data
Once configured, the app fetches real data from Instagram:
- Live account information
- Actual posts and media
- Real-time insights

## 🔄 Development Workflow

1. **Development**: Use `MockDataService` for quick iteration
2. **Testing**: Connect real Instagram account via Settings
3. **Production**: Submit for Instagram App Review

## 📈 Roadmap

### Current Version (v1.0)
- ✅ Instagram OAuth authentication
- ✅ Multiple account management
- ✅ Basic UI structure
- ✅ Mock data for development

### Next Version (v1.1)
- [ ] Post scheduling with Instagram API
- [ ] Real-time analytics dashboard
- [ ] Stories support
- [ ] Comment management

### Future Versions
- [ ] AI-powered caption generation
- [ ] Hashtag research
- [ ] Competitor analysis
- [ ] Team collaboration
- [ ] Direct message management

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## ⚠️ Instagram API Limitations

### Rate Limits
- 200 API calls per hour per user
- Be mindful of pagination

### Account Types
- **Personal accounts**: Basic profile and media access
- **Business accounts**: Full API access including insights

### App Review
- Production use requires Instagram App Review
- Provide clear use case and demo video
- Approval typically takes 1-2 weeks

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- Instagram Graph API
- Instagram Basic Display API
- SwiftUI and Apple frameworks
- Open source community

## 📞 Support

### Documentation
- Check [QUICK_START.md](QUICK_START.md) for setup
- Review [INSTAGRAM_SETUP_GUIDE.md](INSTAGRAM_SETUP_GUIDE.md) for details
- See [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md) for technical info

### Resources
- [Instagram API Docs](https://developers.facebook.com/docs/instagram-api)
- [Facebook Developer Community](https://developers.facebook.com/community/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Issues
- Check existing documentation first
- Review console logs for errors
- Verify credentials and configuration

## 🎯 Getting Started in 3 Steps

1. **📖 Read**: [QUICK_START.md](QUICK_START.md)
2. **⚙️ Configure**: Follow [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)
3. **🚀 Run**: Open in Xcode and press Cmd+R

## 💡 Pro Tips

- **Use Mock Data**: Keep using mock data during UI development
- **Test Users**: Add test Instagram accounts in Facebook App dashboard
- **Token Expiration**: Tokens last 60 days, implement refresh logic
- **Rate Limits**: Cache API responses to avoid hitting limits
- **Business Accounts**: Some features require Instagram Business accounts

---

<div align="center">

**Ready to manage your Instagram like a pro?**

⭐ Star this repo if you find it useful!

Built with ❤️ using SwiftUI

</div>

