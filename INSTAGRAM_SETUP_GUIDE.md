# Instagram API Integration Setup Guide

This guide will help you configure Instagram API integration for the Antar app.

## Prerequisites

1. A Facebook Developer account
2. A Meta (Facebook) App with Instagram integration
3. An Instagram Business or Creator account

## Step 1: Create a Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click "My Apps" → "Create App"
3. Choose "Consumer" as the app type
4. Fill in your app details:
   - App Name: "Antar" (or your preferred name)
   - App Contact Email: Your email
5. Click "Create App"

## Step 2: Add Instagram Basic Display

1. In your Facebook App dashboard, click "Add Product"
2. Find "Instagram Basic Display" and click "Set Up"
3. Scroll down to "User Token Generator"
4. Click "Create New App"

## Step 3: Configure Instagram Basic Display

1. In the Instagram Basic Display settings:
   - **Valid OAuth Redirect URIs**: Add `antarapp://instagram-callback`
   - **Deauthorize Callback URL**: `https://yourdomain.com/deauth` (placeholder)
   - **Data Deletion Request URL**: `https://yourdomain.com/deletion` (placeholder)
2. Save your changes

## Step 4: Get Your App Credentials

1. In the Instagram Basic Display settings, you'll find:
   - **Instagram App ID**: Copy this value
   - **Instagram App Secret**: Copy this value (click "Show")

## Step 5: Update the App Configuration

1. Open `Antar/Services/InstagramAPIConfig.swift`
2. Replace the placeholder values:

```swift
static let appId = "YOUR_INSTAGRAM_APP_ID"        // Replace with your Instagram App ID
static let appSecret = "YOUR_INSTAGRAM_APP_SECRET" // Replace with your Instagram App Secret
```

## Step 6: Configure URL Scheme in Xcode

1. Open your Xcode project
2. Select the "Antar" target in the project navigator
3. Go to the "Info" tab
4. Expand "URL Types"
5. Click the "+" button to add a new URL Type
6. Configure it as follows:
   - **Identifier**: `com.antar.instagram`
   - **URL Schemes**: `antarapp`
   - **Role**: Editor

## Step 7: Add Required Permissions

If you're using Instagram Graph API (for business accounts), you may need additional permissions:

1. Go to your Facebook App dashboard
2. Navigate to "App Review" → "Permissions and Features"
3. Request the following permissions:
   - `instagram_basic`
   - `instagram_content_publish`
   - `pages_show_list`
   - `pages_read_engagement`

## Step 8: Test the Integration

1. Build and run the app
2. Go to Settings
3. Tap "Add Instagram Account"
4. You should be redirected to Instagram login
5. Authorize the app
6. You'll be redirected back to the app with your account connected

## Important Notes

### Instagram Basic Display vs Instagram Graph API

This app uses **Instagram Basic Display API** for personal accounts and **Instagram Graph API** for business/creator accounts.

- **Basic Display**: Good for reading user profile and media
- **Graph API**: Required for posting content and accessing insights

### Token Expiration

- Instagram Basic Display tokens expire after 60 days
- You'll need to implement token refresh or re-authentication
- The app will notify users when tokens expire

### Rate Limits

Instagram has rate limits on API calls:
- 200 calls per hour per user
- Be mindful of pagination and caching

### Required Business Account

To use the **content publishing features**, your Instagram account must be:
1. A Business or Creator account
2. Connected to a Facebook Page

### Development vs Production

During development:
- You can add test users in the Facebook App dashboard
- Test users can authenticate without app review

For production:
- Submit your app for Instagram App Review
- Provide use cases and demo videos
- Wait for approval (typically 1-2 weeks)

## Troubleshooting

### "Invalid Redirect URI" Error

Make sure the redirect URI in the Facebook App settings exactly matches:
```
antarapp://instagram-callback
```

### "Invalid Client ID" Error

Double-check that you've correctly copied the Instagram App ID (not Facebook App ID).

### Authentication Window Doesn't Open

1. Make sure the URL scheme is configured in Xcode
2. Check that the app can open URLs
3. Verify your App ID and Secret are correct

### "Insufficient Permissions" Error

Request the required permissions in the Facebook App dashboard and wait for approval.

## Alternative: Using Mock Data

If you want to test the app without setting up Instagram API:

The app already includes mock data functionality. Simply keep using the `MockDataService` for development and testing.

## Support

For more information:
- [Instagram Basic Display API Documentation](https://developers.facebook.com/docs/instagram-basic-display-api)
- [Instagram Graph API Documentation](https://developers.facebook.com/docs/instagram-api)
- [Facebook App Review Process](https://developers.facebook.com/docs/app-review)

## Security Best Practices

1. **Never commit credentials to Git**: Use environment variables or a secure config file
2. **Use Keychain**: The app already stores tokens securely in Keychain
3. **Implement token refresh**: Add automatic token refresh before expiration
4. **Handle errors gracefully**: Show user-friendly error messages
5. **Validate all inputs**: Never trust data from external APIs

## Next Steps

After setting up Instagram integration, you may want to:

1. Implement automatic token refresh
2. Add support for Instagram Stories
3. Implement post scheduling with API
4. Add Instagram Insights/Analytics
5. Support multiple account types (Personal, Business, Creator)

