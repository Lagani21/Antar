# 🚀 Antar Setup Guide

Complete guide to set up your Antar Instagram management app with real Instagram API integration.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Setup (5 minutes)](#quick-setup-5-minutes)
3. [Detailed Setup](#detailed-setup)
4. [Mock API Demo (No Credentials Required)](#mock-api-demo-no-credentials-required)
5. [Troubleshooting](#troubleshooting)
6. [Next Steps](#next-steps)

---

## Prerequisites

Before you begin, ensure you have:

- ✅ **Xcode 14.0+** installed
- ✅ **iOS 15.0+** target device/simulator
- ✅ **Facebook Developer Account** (free)
- ✅ **Instagram Account** (Personal, Business, or Creator)
- ✅ **Internet connection**

---

## Quick Setup (5 minutes)

### Option A: Real Instagram API Setup

**Want to connect real Instagram accounts?** Follow these steps:

#### 1. Create Meta App (2 minutes)
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click **"Create App"** → **"Consumer"**
3. App Name: **"Antar"** (or your choice)
4. Contact Email: **Your email**
5. Click **"Create App"**

#### 2. Add Instagram Basic Display (1 minute)
1. In your app dashboard → **"Add Product"**
2. Find **"Instagram Basic Display"** → **"Set Up"**
3. Click **"Create New App"**

#### 3. Configure OAuth (1 minute)
In Instagram Basic Display settings:
- **Valid OAuth Redirect URIs**: `antarapp://instagram-callback`
- **Deauthorize Callback URL**: `https://yourdomain.com/deauth`
- **Data Deletion Request URL**: `https://yourdomain.com/deletion`
- Click **"Save Changes"**

#### 4. Get Your Credentials (30 seconds)
- Copy your **Instagram App ID**
- Click **"Show"** and copy your **Instagram App Secret**

#### 5. Configure Xcode Project (30 seconds)
1. Open `Antar.xcodeproj` in Xcode
2. Select **"Antar"** target → **"Info"** tab
3. Find **"URL Types"** → Click **"+"**
4. Configure:
   - **Identifier**: `com.antar.instagram`
   - **URL Schemes**: `antarapp`
   - **Role**: `Editor`

#### 6. Add Credentials (30 seconds)
1. Open `Antar/Services/InstagramAPIConfig.swift`
2. Replace:
   ```swift
   static let appId = "YOUR_INSTAGRAM_APP_ID"
   static let appSecret = "YOUR_INSTAGRAM_APP_SECRET"
   ```
3. Save the file

#### 7. Test It!
1. Run the app: **⌘R**
2. Go to **Settings** tab
3. Tap **"Add Instagram Account"**
4. Sign in with Instagram
5. Authorize the app
6. ✅ **Success!** Your account is connected

---

### Option B: Mock API Demo (No Setup Required!)

**Want to see the API in action without credentials?** Perfect for portfolios and demos!

The app includes a complete **Mock Instagram Graph API** that simulates real API calls. No setup required!

#### Access the Demo:
1. **Run the app**: Open in Xcode and press **⌘R**
2. **Navigate**: Settings tab → **"Developer & Demo"**
3. **Open**: **"API Request Monitor"**
4. **Try it**: Tap any colored demo button!

#### What You'll See:
- 🔵 **Get Profile** - Fetch user profile data
- 🟣 **Get Media** - Fetch user's posts
- 🟠 **Get Insights** - Fetch post analytics  
- 🟢 **Publish Post** - Complete 2-step publishing flow
- 🌸 **Account Insights** - Account-level metrics

#### Features:
- ✅ **Real-time request/response logging**
- ✅ **Full HTTP details** (headers, body, status codes)
- ✅ **Interactive request inspection**
- ✅ **Realistic Instagram API responses**
- ✅ **Network delay simulation**
- ✅ **Complete publishing workflow**

---

## Detailed Setup

### Step 1: Facebook Developer Account

#### Create Developer Account
1. Visit [Facebook Developers](https://developers.facebook.com/)
2. Click **"Get Started"**
3. Sign in with your Facebook account
4. Complete developer verification if prompted

#### Create Your App
1. Click **"My Apps"** → **"Create App"**
2. Select **"Consumer"** as app type
3. Fill in app details:
   - **App Name**: "Antar" (or your preferred name)
   - **App Contact Email**: Your email address
   - **App Purpose**: "Personal Use" or "Business"
4. Click **"Create App"**

### Step 2: Instagram Basic Display Setup

#### Add Instagram Product
1. In your app dashboard, click **"Add Product"**
2. Find **"Instagram Basic Display"** in the products list
3. Click **"Set Up"**
4. Scroll down to **"User Token Generator"**
5. Click **"Create New App"**

#### Configure OAuth Settings
1. In the Instagram Basic Display settings, scroll to **"OAuth Redirect URIs"**
2. Add the following URI: `antarapp://instagram-callback`
3. Add **Deauthorize Callback URL**: `https://yourdomain.com/deauth` (placeholder)
4. Add **Data Deletion Request URL**: `https://yourdomain.com/deletion` (placeholder)
5. Click **"Save Changes"**

#### Get Your Credentials
1. In the same Instagram Basic Display settings page, you'll find:
   - **Instagram App ID** - Copy this value
   - **Instagram App Secret** - Click **"Show"** and copy this value
2. **⚠️ Important**: Keep these credentials secure and never share them publicly

### Step 3: Xcode Project Configuration

#### Configure URL Scheme
1. Open your Xcode project: `Antar.xcodeproj`
2. Select the **"Antar"** target in the project navigator
3. Click the **"Info"** tab
4. Scroll down to **"URL Types"**
5. Click the **"+"** button to add a new URL type
6. Configure the URL type:
   - **Identifier**: `com.antar.instagram`
   - **URL Schemes**: `antarapp`
   - **Role**: `Editor`

#### Verify Build Settings
1. Go to **"Signing & Capabilities"** tab
2. Ensure a valid **Team** is selected
3. Verify the **Bundle Identifier** is unique
4. Check that **Deployment Target** is iOS 15.0 or higher

### Step 4: Add API Credentials

#### Update Configuration File
1. In Xcode, navigate to `Antar/Services/InstagramAPIConfig.swift`
2. Find these lines:
   ```swift
   static let appId = "YOUR_INSTAGRAM_APP_ID"
   static let appSecret = "YOUR_INSTAGRAM_APP_SECRET"
   ```
3. Replace with your actual credentials:
   ```swift
   static let appId = "1234567890123456"  // Your Instagram App ID
   static let appSecret = "abcdef1234567890abcdef1234567890"  // Your Instagram App Secret
   ```
4. Save the file

#### Security Check
1. Verify that `InstagramAPIConfig.swift` is in your `.gitignore` file
2. This prevents accidentally committing your credentials to version control

### Step 5: Build and Test

#### Build the Project
1. Select a simulator or device in Xcode
2. Press **⌘R** or click the **Run** button
3. The app should build and launch successfully

#### Test Authentication
1. In the running app, tap the **Settings** tab
2. Tap **"Add Instagram Account"**
3. An authentication window should open
4. Enter your Instagram credentials
5. Tap **"Authorize"**
6. You should be redirected back to the app
7. Your Instagram account should appear in the Settings list

---

## Mock API Demo (No Credentials Required!)

Perfect for **portfolio demonstrations**, **interviews**, and **development** without needing real Instagram credentials.

### What It Includes

#### Complete API Simulation
- **Instagram Graph API endpoints** - All major endpoints simulated
- **Realistic responses** - Proper Instagram data format
- **HTTP details** - Full request/response logging
- **Network delays** - Simulates real API timing
- **Error handling** - Shows how errors are handled

#### Interactive Demo Interface
- **Live request monitor** - See API calls in real-time
- **Request details** - Inspect full HTTP details
- **Color-coded methods** - GET (blue), POST (green), DELETE (red)
- **Status codes** - 200 (green), 400+ (red)
- **Timestamps** - "5s ago", "2m ago"

#### Supported Endpoints
1. **GET /me** - User profile
2. **GET /me/media** - User's posts
3. **GET /{media-id}/insights** - Post analytics
4. **GET /me/insights** - Account analytics
5. **POST /me/media** - Create media container
6. **POST /me/media_publish** - Publish media
7. **DELETE /{media-id}** - Delete post

### How to Access

1. **Run the app** in Xcode
2. **Navigate to Settings** tab
3. **Scroll to "Developer & Demo"** section
4. **Tap "API Request Monitor"**
5. **Try the demo buttons!**

### Demo Scenarios

#### Portfolio Demo (1 minute)
> "This app demonstrates Instagram Graph API integration. Even without production credentials, I've built a complete mock API system that simulates real Instagram endpoints. Watch as I fetch a user profile..." [Tap Get Profile] "You can see the complete HTTP request with OAuth headers and JSON response. The architecture supports all major Instagram operations."

#### Technical Deep Dive (3 minutes)
- Show request/response logging
- Demonstrate publishing flow (2-step process)
- Inspect full HTTP details
- Explain architectural decisions
- Show error handling

### Benefits for Development

#### No External Dependencies
- ✅ Works offline
- ✅ No API credentials needed
- ✅ No rate limits
- ✅ Consistent responses

#### Perfect for Learning
- ✅ Understand Instagram API patterns
- ✅ Learn OAuth 2.0 flow
- ✅ Practice async programming
- ✅ See real API response formats

#### Portfolio Ready
- ✅ Professional demonstration
- ✅ Shows API knowledge
- ✅ Interactive and engaging
- ✅ No setup required for viewers

---

## Troubleshooting

### Common Issues

#### "Invalid Redirect URI" Error
**Problem**: Instagram returns an error about invalid redirect URI.

**Solution**:
1. Check that the redirect URI in Facebook App settings is exactly: `antarapp://instagram-callback`
2. Verify the URL scheme in Xcode is exactly: `antarapp`
3. Make sure there are no extra spaces or characters

#### "Invalid Client ID" Error
**Problem**: Instagram says the client ID is invalid.

**Solution**:
1. Make sure you're using the **Instagram App ID**, not the Facebook App ID
2. Check that you copied the App ID correctly (no spaces or extra characters)
3. Verify the App ID is from the Instagram Basic Display section

#### Authentication Window Doesn't Open
**Problem**: Nothing happens when you tap "Add Instagram Account".

**Solution**:
1. Check that the URL scheme is configured in Xcode
2. Verify your App ID and Secret are correct
3. Make sure you have an internet connection
4. Try restarting the app

#### App Crashes on Authentication
**Problem**: The app crashes when trying to authenticate.

**Solution**:
1. Check the Xcode console for error messages
2. Verify all required imports are present
3. Make sure the URL scheme is properly configured
4. Check that your credentials are valid

### Debug Steps

#### Check Console Logs
1. In Xcode, open the **Debug Area** (View → Debug Area)
2. Look for error messages or warnings
3. Check for successful authentication messages

#### Verify Configuration
1. Double-check your Instagram App ID and Secret
2. Verify the URL scheme configuration in Xcode
3. Make sure the redirect URI matches exactly

#### Test with Different Account
1. Try with a different Instagram account
2. Make sure the account is not already connected
3. Check if the account has any restrictions

### Getting Help

#### Check Documentation
1. Review the [Instagram API documentation](https://developers.facebook.com/docs/instagram-basic-display-api)
2. Check the [Facebook Developer Community](https://developers.facebook.com/community/)
3. Look at the console logs for specific error messages

#### Common Solutions
1. **Restart the app** - Often fixes temporary issues
2. **Check internet connection** - Required for authentication
3. **Verify credentials** - Double-check App ID and Secret
4. **Clear app data** - Reset to default state

---

## Next Steps

### After Successful Setup

#### 1. Explore the App Features
- **Dashboard**: View your Instagram analytics
- **Calendar**: See your content calendar
- **Composer**: Create and schedule posts
- **Analytics**: Deep dive into performance metrics

#### 2. Connect Multiple Accounts
- Add additional Instagram accounts
- Switch between accounts
- Compare performance across accounts

#### 3. Test Real API Features
- Fetch your actual Instagram posts
- View real analytics data
- Test content publishing (if you have a Business account)

### Development Workflow

#### Use Mock Data for Development
- Keep using the mock API for UI development
- Switch to real API for testing
- Use conditional compilation for different environments

#### Add New Features
- Implement post scheduling
- Add Instagram Stories support
- Create analytics dashboards
- Add comment management

### Production Considerations

#### Instagram App Review
- Submit your app for Instagram App Review
- Provide clear use case documentation
- Create demo videos showing app functionality
- Explain why you need each permission

#### Security Best Practices
- Never commit credentials to version control
- Use environment variables for CI/CD
- Implement proper error handling
- Add rate limiting and caching

---

## 🎉 You're Ready!

Whether you chose the **real API setup** or the **mock API demo**, you now have a fully functional Instagram management app!

### What You Can Do Now:

#### With Real API:
- ✅ Connect real Instagram accounts
- ✅ Fetch actual posts and analytics
- ✅ Publish content (Business accounts)
- ✅ Build production features

#### With Mock API:
- ✅ Demonstrate API knowledge
- ✅ Show portfolio projects
- ✅ Learn Instagram API patterns
- ✅ Develop without credentials

### Resources:

- 📖 **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - How to test all features
- 🔧 **[INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** - Technical details
- 🚀 **[QUICK_START.md](QUICK_START.md)** - Quick reference

---

**Happy coding! 🚀**

Built with ❤️ using SwiftUI and Instagram Graph API
