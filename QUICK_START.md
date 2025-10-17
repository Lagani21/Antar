# Quick Start Guide - Instagram Integration

## 🚀 Getting Started

Your Antar app now has Instagram API integration! Here's how to get it running:

## Quick Setup (5 minutes)

### 1. Configure Xcode Project Settings

Open your Xcode project and:

1. Select the **Antar** target
2. Go to the **Info** tab
3. Under **URL Types**, add:
   - **Identifier**: `com.antar.instagram`
   - **URL Schemes**: `antarapp`

### 2. Add Your Instagram App Credentials

1. Copy the example config:
   ```bash
   cd Antar/Services
   # The InstagramAPIConfig.swift file is already there
   ```

2. Open `Antar/Services/InstagramAPIConfig.swift` and update:
   ```swift
   static let appId = "YOUR_INSTAGRAM_APP_ID"
   static let appSecret = "YOUR_INSTAGRAM_APP_SECRET"
   ```

### 3. Test the Connection

1. Run the app in Xcode
2. Navigate to **Settings** tab
3. Tap **"Add Instagram Account"**
4. Sign in with your Instagram credentials
5. Authorize the app

## 📋 What Was Added

### New Services

1. **KeychainService** - Secure token storage
   - Location: `Antar/Services/KeychainService.swift`
   - Stores access tokens securely in iOS Keychain

2. **InstagramAPIConfig** - API configuration
   - Location: `Antar/Services/InstagramAPIConfig.swift`
   - Contains app credentials and endpoints
   - ⚠️ **IMPORTANT**: This file is gitignored to protect your credentials

3. **InstagramAuthService** - OAuth authentication
   - Location: `Antar/Services/InstagramAuthService.swift`
   - Handles the entire OAuth flow
   - Uses ASWebAuthenticationSession for secure auth

4. **InstagramAPIService** - API interactions
   - Location: `Antar/Services/InstagramAPIService.swift`
   - Fetches user profile, media, insights
   - Handles content publishing

### Updated Files

1. **InstagramAccount.swift** - Added token fields
2. **SettingsView.swift** - Integrated OAuth flow
3. **AntarApp.swift** - Added URL handling

## 🔧 Features Available

### ✅ Currently Implemented

- ✅ Instagram OAuth authentication
- ✅ Secure token storage in Keychain
- ✅ User profile fetching
- ✅ Media/posts fetching
- ✅ Media insights retrieval
- ✅ Content publishing (container creation)
- ✅ Multiple account support
- ✅ Account switching
- ✅ Token expiration handling

### 🔄 Ready to Extend

- Instagram Stories API
- Carousel posts
- Video posts
- Post scheduling
- Analytics dashboard
- Comments management
- Direct messages (if approved)

## 📱 How to Use

### Connect an Instagram Account

```swift
// The UI handles this, but programmatically:
InstagramAuthService.shared.authenticate { result in
    switch result {
    case .success(let account):
        print("Connected: @\(account.username)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Fetch User Media

```swift
InstagramAPIService.shared.fetchUserMedia(
    accessToken: account.accessToken
) { result in
    switch result {
    case .success(let media):
        // Display media
    case .failure(let error):
        // Handle error
    }
}
```

### Publish Content

```swift
// Step 1: Create container
InstagramAPIService.shared.createMediaContainer(
    imageUrl: "https://example.com/image.jpg",
    caption: "My caption",
    accessToken: token
) { result in
    // Step 2: Publish container
    if case .success(let containerId) = result {
        InstagramAPIService.shared.publishMediaContainer(
            containerId: containerId,
            accessToken: token
        ) { publishResult in
            // Content published!
        }
    }
}
```

## 🔐 Security Notes

1. **Never commit credentials**: `InstagramAPIConfig.swift` is in `.gitignore`
2. **Tokens are secure**: Stored in iOS Keychain, never in UserDefaults
3. **HTTPS only**: All API calls use secure HTTPS
4. **Token expiration**: Handled automatically with user prompts

## 📖 Need More Details?

See the full setup guide: [INSTAGRAM_SETUP_GUIDE.md](INSTAGRAM_SETUP_GUIDE.md)

## 🐛 Troubleshooting

### "Invalid Redirect URI"
- Check Xcode URL scheme is exactly `antarapp`
- Verify Facebook App settings have `antarapp://instagram-callback`

### "Invalid Client ID"
- Make sure you're using the **Instagram App ID**, not Facebook App ID
- Check for typos in `InstagramAPIConfig.swift`

### Authentication Window Doesn't Open
- Verify URL scheme is configured in Xcode
- Check internet connection
- Ensure credentials are correct

### "This app is in Development Mode"
- This is normal during development
- Add test users in Facebook App dashboard
- Submit for review when ready for production

## 🎯 Next Steps

1. ✅ Set up your Facebook/Instagram App (see INSTAGRAM_SETUP_GUIDE.md)
2. ✅ Add credentials to `InstagramAPIConfig.swift`
3. ✅ Configure Xcode URL scheme
4. ✅ Test authentication
5. 🔄 Implement post scheduling
6. 🔄 Add analytics dashboard
7. 🔄 Submit for Instagram App Review (for production)

## 💡 Tips

- **Test Users**: Add test users in Facebook App dashboard for testing
- **Mock Data**: Keep using `MockDataService` during development
- **Rate Limits**: Instagram limits to 200 API calls per hour per user
- **Business Accounts**: Some features require Instagram Business accounts
- **Token Refresh**: Tokens expire after 60 days, implement refresh logic

## 📞 Support

Having issues? Check:
- [Instagram Basic Display API Docs](https://developers.facebook.com/docs/instagram-basic-display-api)
- [Instagram Graph API Docs](https://developers.facebook.com/docs/instagram-api)
- Facebook Developer Community

---

**Ready to connect your Instagram account?** Just run the app and go to Settings! 🎉

