# Admin Dashboard Setup Guide

## 🔐 Admin Credentials

**Email:** `admin@gmail.com`  
**Password:** `admin123`

## 📋 Setup Instructions

### Step 1: Create Admin Account
1. Run the app and navigate to the Register page
2. Register a new account with:
   - **Email:** admin@gmail.com
   - **Password:** admin123
   - **First Name:** Admin
   - **Last Name:** User

### Step 2: Login as Admin
1. After registration, the app will automatically detect the admin email
2. You'll be redirected to the Admin Dashboard instead of the regular home page

### Step 3: Access Admin Features
The admin account will have access to:
- ✅ Real-time user analytics
- ✅ Total registered users count
- ✅ Currently online users count
- ✅ Total chats statistics
- ✅ Total messages sent
- ✅ Complete user list with online status
- ✅ User activity metrics
- ✅ Communication statistics

## 🎨 Admin Dashboard Features

### Analytics Tab
- **User Activity:**
  - Total Registered Users
  - Currently Online Users
  - Offline Users
  - Activity Rate (percentage)

- **Communication Stats:**
  - Total Conversations
  - Total Messages Sent
  - Average Messages per Chat
  - Average Messages per User

- **Platform Overview:**
  - Active Chats
  - Platform Status
  - Last Updated Time

### Users Tab
- Real-time list of all registered users
- User details:
  - Display Name
  - Email Address
  - User ID (UID)
  - Online/Offline status with visual indicator
- Green dot indicator for online users
- Color-coded status badges

## 🔄 Real-Time Updates

The admin dashboard automatically updates when:
- New users register
- Users come online/offline
- New messages are sent
- New chats are created

Click the refresh icon in the app bar to manually reload analytics.

## 🚪 Logout

Click the logout button in the top right to sign out from the admin account.

## 🔒 Security Note

The admin check is based on the email address `admin@gmail.com`. This is a simple implementation for demonstration purposes. In a production environment, you should:

1. Store admin roles in Firestore
2. Use Firebase Admin SDK for role management
3. Implement proper authentication middleware
4. Add admin-only Firebase security rules

## 📱 Screenshots Features

1. **Top Statistics Cards:**
   - Total Users (purple card)
   - Online Now (green indicator)
   - Total Chats
   - Messages Count

2. **Navigation Tabs:**
   - Analytics (detailed stats)
   - Users (user list)

3. **Color Scheme:**
   - Primary: Purple (#667eea)
   - Success: Green
   - Background: Theme-based (dark/light mode)

## 🛠️ Technical Details

- **Real-time data:** Uses Firestore StreamBuilder
- **Analytics:** Aggregates data from Users and Chats collections
- **Performance:** Efficient queries with caching
- **Responsive:** Works in both dark and light modes
- **Refresh:** Manual refresh button available

## 📊 Data Sources

- `Users` collection: User profiles, online status
- `chats` collection: Chat rooms
- `chats/{chatId}/messages` subcollection: Individual messages

All data is fetched in real-time and displayed with proper error handling.
