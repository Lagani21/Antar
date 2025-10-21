# 🧪 Antar Testing Guide

Comprehensive testing guide for the Antar Instagram management app, including both real API integration and mock API demonstrations.

## 📋 Table of Contents

1. [Quick Testing (5 minutes)](#quick-testing-5-minutes)
2. [Mock API Testing](#mock-api-testing)
3. [Real API Testing](#real-api-testing)
4. [Feature Testing](#feature-testing)
5. [Error Testing](#error-testing)
6. [Performance Testing](#performance-testing)
7. [Portfolio Demo](#portfolio-demo)
8. [Troubleshooting](#troubleshooting)

---

## Quick Testing (5 minutes)

### Prerequisites Check
Before testing, verify:
- ✅ App builds successfully (no compilation errors)
- ✅ Simulator/device is running iOS 15.0+
- ✅ Internet connection available
- ✅ Xcode console is visible (for logs)

### Basic Functionality Test

#### 1. App Launch (30 seconds)
1. **Run the app**: Press **⌘R** in Xcode
2. **Expected**: App launches without crashes
3. **Check**: Console shows "Loaded X accounts from UserDefaults"
4. **Verify**: Bottom tab bar is visible with 5 tabs

#### 2. Navigation Test (1 minute)
1. **Tap each tab**: Dashboard, Calendar, Create, Drafts, Settings
2. **Expected**: Each tab loads without errors
3. **Check**: Content appears for each tab
4. **Verify**: Tab selection changes appropriately

#### 3. Settings Access (30 seconds)
1. **Go to Settings** tab (rightmost tab)
2. **Scroll down** to find **"Developer & Demo"** section
3. **Expected**: Section is visible
4. **Verify**: "API Request Monitor" option is present

---

## Mock API Testing

Perfect for **portfolio demonstrations** and **development** without real credentials.

### Access Mock API Demo

#### Navigate to API Monitor
1. **Settings tab** → **"Developer & Demo"** section
2. **Tap "API Request Monitor"**
3. **Expected**: API debug interface opens
4. **Verify**: 5 colored demo buttons are visible

### Test Individual Endpoints

#### 1. Get Profile Test (30 seconds)
1. **Tap blue "Get Profile"** button
2. **Expected**: 
   - Request appears in log with blue "GET" badge
   - Green "200" status badge
   - Description: "Fetch user profile information"
   - Timestamp shows "just now"

3. **Verify Success**:
   ```
   GET https://graph.instagram.com/me?fields=id,username,account_type,media_count
   Status: 200 OK
   Response: {"id": "17841405793187218", "username": "demo_user", "account_type": "BUSINESS"}
   ```

#### 2. Get Media Test (30 seconds)
1. **Tap purple "Get Media"** button
2. **Expected**:
   - Request appears in log
   - Response shows array of media items
   - Includes captions, URLs, engagement metrics

3. **Verify Success**:
   ```
   GET https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url...
   Status: 200 OK
   Response: {"data": [{"id": "17895695668004550", "caption": "Beautiful sunset 🌅"}]}
   ```

#### 3. Get Insights Test (30 seconds)
1. **Tap orange "Get Insights"** button
2. **Expected**:
   - Request for media insights
   - Response shows engagement metrics
   - Includes impressions, reach, saves

3. **Verify Success**:
   ```
   GET https://graph.instagram.com/17895695668004550/insights?metric=engagement,impressions...
   Status: 200 OK
   Response: {"data": [{"name": "engagement", "values": [{"value": 1456}]}]}
   ```

#### 4. Account Insights Test (30 seconds)
1. **Tap pink "Account Insights"** button
2. **Expected**:
   - Request for account-level insights
   - Response shows daily metrics
   - Includes impressions, reach, profile views, follower count

3. **Verify Success**:
   ```
   GET https://graph.instagram.com/me/insights?metric=impressions,reach,profile_views,follower_count...
   Status: 200 OK
   Response: {"data": [{"name": "impressions", "period": "day", "values": [{"value": 12456}]}]}
   ```

### Test Publishing Flow (Most Important!)

#### Complete Publishing Demo (2 minutes)
1. **Tap green "Publish Post"** button
2. **Expected**: Modal opens with:
   - Image preview
   - Image URL field
   - Caption text editor
   - "Publish to Instagram" button

3. **Customize the post**:
   - Change image URL (try: `https://picsum.photos/1080/1080`)
   - Edit caption (try: "Check out this amazing demo! 🚀 #Instagram #API")

4. **Publish the post**:
   - Tap **"Publish to Instagram"**
   - **Expected**: Loading state shows "Publishing..."
   - **Wait**: 1-2 seconds for network simulation

5. **Verify 2-step flow**:
   - **Step 1**: "Create media container" request appears
   - **Step 2**: "Publish media container" request appears
   - **Success**: Green success message shows
   - **Result**: Media ID is displayed

#### Expected API Flow:
```
Request 1: POST /me/media
Body: {"image_url": "https://...", "caption": "Your caption", "access_token": "DEMO_ACCESS_TOKEN"}
Response: {"id": "17895695668123456"}

Request 2: POST /me/media_publish  
Body: {"creation_id": "17895695668123456", "access_token": "DEMO_ACCESS_TOKEN"}
Response: {"id": "17895695669789012"}
```

### Test Request Inspection

#### View Request Details (1 minute)
1. **Tap any request** in the log
2. **Expected**: Detail view opens showing:
   - Full HTTP method and endpoint
   - Request headers (including Authorization)
   - Request body (if applicable)
   - Response status code
   - Complete response JSON (formatted)

3. **Verify Details**:
   - Headers include `Authorization: Bearer DEMO_ACCESS_TOKEN`
   - JSON is properly formatted and readable
   - Timestamps are accurate

### Test Logging Controls

#### Enable/Disable Logging (30 seconds)
1. **Toggle "Enable API Logging"** switch
2. **Tap a demo button** while logging is off
3. **Expected**: No new request appears in log
4. **Turn logging back on** and tap button
5. **Expected**: Request appears normally

#### Clear Logs (30 seconds)
1. **Tap "Clear API Logs"** button
2. **Expected**: All requests disappear from log
3. **Badge counter** resets to 0
4. **Button becomes disabled** (grayed out)

### Test Badge Counter

#### Verify Counter Updates (30 seconds)
1. **Check initial state**: Badge should show "0" or current count
2. **Make several requests**: Tap different demo buttons
3. **Expected**: Badge updates with current request count
4. **Clear logs**: Badge should reset to "0"

---

## Real API Testing

For testing with actual Instagram accounts (requires setup from [SETUP_GUIDE.md](SETUP_GUIDE.md)).

### Prerequisites
- ✅ Instagram API credentials configured
- ✅ URL scheme configured in Xcode
- ✅ Valid Instagram account ready

### Authentication Testing

#### 1. Add Instagram Account (2 minutes)
1. **Go to Settings** tab
2. **Tap "Add Instagram Account"**
3. **Expected**: Authentication window opens
4. **Enter credentials**: Your Instagram username/password
5. **Tap "Authorize"**
6. **Expected**: 
   - Window closes automatically
   - Account appears in Settings list
   - Account shows checkmark (active)
   - Console shows success messages

#### 2. Verify Account Data (1 minute)
1. **Check account details**:
   - Username displays correctly
   - Profile image placeholder shows
   - Follower count appears (may be 0)
   - Following count appears

2. **Check console logs**:
   ```
   "Received Instagram OAuth callback: ..."
   "Fetched X media items"
   "Token saved to Keychain for account: ..."
   ```

#### 3. Test Multiple Accounts (2 minutes)
1. **Add second Instagram account**
2. **Expected**: Both accounts appear in list
3. **Test switching**: Tap different accounts
4. **Verify**: Active account has checkmark
5. **Check**: Account switching works smoothly

### Real API Data Testing

#### 1. Profile Data Fetching (1 minute)
1. **After authentication**, check console logs
2. **Expected**: Profile data fetched successfully
3. **Verify**: Username, account type, media count

#### 2. Media Fetching (1 minute)
1. **Check console** for media fetch logs
2. **Expected**: "Fetched X media items" message
3. **Verify**: No rate limit errors

#### 3. Insights Fetching (1 minute)
1. **Check console** for insights logs
2. **Expected**: Insights data fetched (if Business account)
3. **Verify**: No permission errors

---

## Feature Testing

### Dashboard Testing

#### 1. Overview Metrics (1 minute)
1. **Navigate to Dashboard** tab
2. **Expected**: Analytics overview displays
3. **Verify**: Metrics show realistic data
4. **Check**: Charts and graphs render properly

#### 2. Account Switching (30 seconds)
1. **Switch between accounts** in Settings
2. **Return to Dashboard**
3. **Expected**: Data updates for active account
4. **Verify**: No crashes or errors

### Calendar Testing

#### 1. Calendar View (1 minute)
1. **Navigate to Calendar** tab
2. **Expected**: Monthly calendar displays
3. **Verify**: Posts appear on correct dates
4. **Check**: Calendar navigation works

#### 2. Post Details (30 seconds)
1. **Tap on a post** in calendar
2. **Expected**: Post details view opens
3. **Verify**: Post information displays correctly

### Composer Testing

#### 1. Create Post (2 minutes)
1. **Navigate to Create** tab
2. **Add caption**: Write a test caption
3. **Select media**: Choose an image
4. **Expected**: Post preview shows correctly
5. **Save as draft**: Verify draft is saved

#### 2. Publish with Mock API (1 minute)
1. **In Create view**, look for publish options
2. **If mock API integration exists**, test publishing
3. **Expected**: API calls logged in debug monitor

### Analytics Testing

#### 1. Follower Analytics (1 minute)
1. **Navigate to Analytics** (if available)
2. **Expected**: Follower growth charts display
3. **Verify**: Data shows realistic trends

#### 2. Post Performance (1 minute)
1. **Select a post** from calendar or dashboard
2. **View analytics**: Check engagement metrics
3. **Expected**: Metrics display correctly

---

## Error Testing

### Authentication Errors

#### 1. Invalid Credentials (1 minute)
1. **Try authentication** with wrong password
2. **Expected**: Error message appears
3. **Verify**: Error is user-friendly
4. **Check**: No crashes occur

#### 2. Cancel Authentication (30 seconds)
1. **Start authentication** process
2. **Cancel** the authentication window
3. **Expected**: App returns to Settings
4. **Verify**: No error states remain

#### 3. Network Errors (1 minute)
1. **Turn off internet** connection
2. **Try authentication**
3. **Expected**: Network error message
4. **Verify**: App handles gracefully

### API Error Testing

#### 1. Rate Limit Simulation (30 seconds)
1. **Make many requests** quickly
2. **Expected**: Rate limit handling (if implemented)
3. **Verify**: App doesn't crash

#### 2. Invalid API Responses (30 seconds)
1. **Test with invalid data** (if possible)
2. **Expected**: Error handling works
3. **Verify**: User sees helpful messages

---

## Performance Testing

### Memory Usage (2 minutes)
1. **Open Xcode Instruments** (Product → Profile)
2. **Select "Leaks"** template
3. **Run the app** and use all features
4. **Expected**: No memory leaks detected
5. **Check**: Memory usage stays reasonable

### Network Performance (1 minute)
1. **Monitor network requests** in console
2. **Expected**: Requests complete in reasonable time
3. **Verify**: No excessive API calls
4. **Check**: Proper error handling for timeouts

### UI Performance (1 minute)
1. **Navigate quickly** between tabs
2. **Scroll through lists** rapidly
3. **Expected**: Smooth animations
4. **Verify**: No UI freezes or stutters

---

## Portfolio Demo

### 1-Minute Demo Script

> "This app demonstrates Instagram Graph API integration. Even without production credentials, I've built a complete mock API system that simulates real Instagram endpoints. Let me show you..."

**Demo Flow:**
1. **Open API Request Monitor** (Settings → Developer & Demo)
2. **Show empty state**: "No requests yet"
3. **Tap "Get Profile"**: "Watch as I fetch a user profile..."
4. **Show request details**: "You can see the complete HTTP request with OAuth headers and JSON response"
5. **Tap "Publish Post"**: "Publishing follows Instagram's 2-step flow"
6. **Submit publish**: "Create container, then publish it"
7. **Show both requests**: "You can see both API calls logged with full details"

### 3-Minute Deep Dive

**Extended Demo:**
1. **Start with architecture overview**
2. **Show each endpoint type**
3. **Demonstrate error handling**
4. **Explain security measures**
5. **Show how to swap in real API**

### Screenshots for Portfolio

**Essential Screenshots:**
1. **API Request Monitor** with multiple requests
2. **Request detail view** showing full JSON
3. **Publishing flow** with 2-step process
4. **Settings** showing Developer section
5. **Color-coded badges** (GET/POST, 200/400)

---

## Troubleshooting

### Common Issues

#### Mock API Not Working
**Problem**: Demo buttons don't respond or no requests appear.

**Solutions**:
1. **Check logging**: Ensure "Enable API Logging" is ON
2. **Restart app**: Close and reopen the app
3. **Check console**: Look for error messages
4. **Verify build**: Ensure app built successfully

#### Real API Not Working
**Problem**: Authentication fails or accounts don't appear.

**Solutions**:
1. **Check credentials**: Verify App ID and Secret are correct
2. **Check URL scheme**: Ensure `antarapp` is configured
3. **Check redirect URI**: Must be exactly `antarapp://instagram-callback`
4. **Check internet**: Ensure connection is working

#### App Crashes
**Problem**: App crashes during testing.

**Solutions**:
1. **Check console logs**: Look for crash details
2. **Clean build**: Product → Clean Build Folder
3. **Restart Xcode**: Sometimes fixes temporary issues
4. **Check simulator**: Try different simulator or device

### Debug Steps

#### Enable Debug Logging
1. **Check Xcode console** for detailed logs
2. **Look for error messages** or warnings
3. **Check network requests** in console
4. **Verify authentication flow** step by step

#### Test in Isolation
1. **Test one feature at a time**
2. **Use fresh app install** for authentication
3. **Test with different accounts**
4. **Try different simulators**

---

## Testing Checklist

### ✅ Basic Functionality
- [ ] App launches without crashes
- [ ] All tabs navigate correctly
- [ ] Settings section is accessible
- [ ] Mock API demo loads

### ✅ Mock API Testing
- [ ] All 5 demo buttons work
- [ ] Requests appear in log
- [ ] Badge counter updates
- [ ] Request details view works
- [ ] Publishing flow shows 2 requests
- [ ] Logging toggle works
- [ ] Clear logs button works

### ✅ Real API Testing (if configured)
- [ ] Authentication window opens
- [ ] Instagram login works
- [ ] Account appears in Settings
- [ ] Account switching works
- [ ] Profile data fetches
- [ ] Media data fetches
- [ ] No rate limit errors

### ✅ Error Handling
- [ ] Invalid credentials show error
- [ ] Cancel authentication works
- [ ] Network errors handled
- [ ] No crashes on errors

### ✅ Performance
- [ ] Smooth navigation
- [ ] No memory leaks
- [ ] Reasonable network usage
- [ ] No UI freezes

---

## 🎉 Testing Complete!

After completing all tests, you should have:

- ✅ **Verified functionality** of all features
- ✅ **Confirmed API integration** works (mock or real)
- ✅ **Validated error handling** and edge cases
- ✅ **Ensured performance** meets expectations
- ✅ **Prepared demo materials** for portfolio

### Next Steps:
1. **Fix any issues** found during testing
2. **Document bugs** and their solutions
3. **Prepare demo script** for presentations
4. **Take screenshots** for portfolio
5. **Plan next features** to implement

---

**Happy Testing! 🧪**

For setup help, see [SETUP_GUIDE.md](SETUP_GUIDE.md)
