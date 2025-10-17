# Instagram Integration Setup Checklist

Use this checklist to complete the Instagram integration setup.

## 📋 Pre-Setup

- [ ] I have a Facebook Developer account
- [ ] I have an Instagram account
- [ ] I have Xcode installed
- [ ] I have read QUICK_START.md

## 🔧 Step 1: Facebook App Setup (10 minutes)

### Create Facebook App
- [ ] Go to https://developers.facebook.com/
- [ ] Click "My Apps" → "Create App"
- [ ] Select "Consumer" app type
- [ ] Enter app name: "Antar" (or your choice)
- [ ] Enter contact email
- [ ] Click "Create App"

### Add Instagram Basic Display
- [ ] In app dashboard, click "Add Product"
- [ ] Find "Instagram Basic Display"
- [ ] Click "Set Up"
- [ ] Click "Create New App"
- [ ] Fill in required fields

### Configure OAuth Settings
- [ ] In Instagram Basic Display settings, scroll to "OAuth Redirect URIs"
- [ ] Add: `antarapp://instagram-callback`
- [ ] Add Deauthorize Callback URL (placeholder): `https://yourdomain.com/deauth`
- [ ] Add Data Deletion Request URL (placeholder): `https://yourdomain.com/deletion`
- [ ] Click "Save Changes"

### Get Credentials
- [ ] Copy Instagram App ID
- [ ] Click "Show" and copy Instagram App Secret
- [ ] Save these somewhere safe (don't share them!)

## 💻 Step 2: Xcode Configuration (5 minutes)

### Add URL Scheme
- [ ] Open Antar.xcodeproj in Xcode
- [ ] Select "Antar" target in project navigator
- [ ] Click "Info" tab
- [ ] Find "URL Types" section
- [ ] Click "+" to add new URL type
- [ ] Set Identifier: `com.antar.instagram`
- [ ] Set URL Schemes: `antarapp`
- [ ] Set Role: `Editor`

### Verify Build Settings
- [ ] Go to "Signing & Capabilities"
- [ ] Ensure a valid Team is selected
- [ ] Ensure bundle identifier is unique
- [ ] Verify deployment target is iOS 14.0+

## 🔐 Step 3: Add Credentials (2 minutes)

### Update Configuration File
- [ ] Open Xcode project
- [ ] Navigate to: `Antar/Services/InstagramAPIConfig.swift`
- [ ] Replace `YOUR_INSTAGRAM_APP_ID` with your Instagram App ID
- [ ] Replace `YOUR_INSTAGRAM_APP_SECRET` with your Instagram App Secret
- [ ] Save the file

### Verify .gitignore
- [ ] Check that `.gitignore` exists in project root
- [ ] Verify it contains: `Antar/Services/InstagramAPIConfig.swift`
- [ ] This prevents committing your credentials!

## 🧪 Step 4: Test Integration (3 minutes)

### Build and Run
- [ ] Select a simulator or device
- [ ] Click Run (Cmd+R) or Product → Run
- [ ] App launches successfully
- [ ] No build errors

### Test Authentication
- [ ] Navigate to Settings tab
- [ ] Tap "Add Instagram Account"
- [ ] Authentication window opens
- [ ] Enter Instagram credentials
- [ ] Tap "Authorize"
- [ ] Window closes automatically
- [ ] Account appears in Settings list
- [ ] Account has checkmark (active)

### Verify Success
- [ ] Check Xcode console for success messages
- [ ] Account displays username correctly
- [ ] No error alerts shown
- [ ] Can switch between accounts (if multiple)

## ✅ Step 5: Verify Integration

### Check Token Storage
Look for these console logs:
- [ ] "Received Instagram OAuth callback: ..."
- [ ] "Fetched X media items" (or similar)

### Check Account Status
- [ ] Account shows in Settings
- [ ] Username is correct
- [ ] Profile image placeholder shows (if applicable)
- [ ] Followers count shows (may be 0)

### Check Error Handling
- [ ] Try canceling authentication → shows error
- [ ] Try with invalid credentials → shows error
- [ ] Error messages are user-friendly

## 🎉 Optional: Advanced Testing

### Test Multiple Accounts
- [ ] Add second Instagram account
- [ ] Both accounts appear in list
- [ ] Can switch between accounts
- [ ] Active account has checkmark

### Test API Calls
- [ ] Profile data fetches correctly
- [ ] Media/posts fetch (check console)
- [ ] No rate limit errors

## 📝 Troubleshooting

If something doesn't work, check:

### Authentication Window Doesn't Open
- [ ] URL scheme configured correctly in Xcode?
- [ ] App ID and Secret are correct?
- [ ] Internet connection working?

### "Invalid Redirect URI" Error
- [ ] Redirect URI in Facebook App is exactly: `antarapp://instagram-callback`
- [ ] URL scheme in Xcode is exactly: `antarapp`

### "Invalid Client ID" Error
- [ ] Using Instagram App ID, not Facebook App ID?
- [ ] App ID copied correctly (no spaces)?

### Account Doesn't Appear
- [ ] Check Xcode console for errors
- [ ] Token saved to Keychain? (check logs)
- [ ] Try restarting app

## 🚀 Ready for Production?

Before releasing to App Store:

- [ ] Submit app for Instagram App Review
- [ ] Provide demo video showing app usage
- [ ] Explain why you need each permission
- [ ] Add privacy policy URL
- [ ] Add terms of service URL
- [ ] Test with multiple users
- [ ] Handle all error cases gracefully
- [ ] Add proper loading states
- [ ] Implement analytics

## 📚 Resources

- [QUICK_START.md](QUICK_START.md) - Quick reference
- [INSTAGRAM_SETUP_GUIDE.md](INSTAGRAM_SETUP_GUIDE.md) - Detailed guide
- [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md) - Technical details

## ✨ You're Done!

If all checkboxes are checked, your Instagram integration is complete! 🎉

**Next steps:**
1. Start building features with real Instagram data
2. Implement post scheduling
3. Add analytics dashboard
4. Test with real users

---

**Questions?** Review the setup guide or check Instagram API documentation.

