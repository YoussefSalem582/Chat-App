# Online Status Feature Implementation

## Overview
The chat app now displays real-time online/offline status for all users. This feature tracks user presence accurately and updates automatically when users sign in, sign out, or when the app goes to background/foreground.

## Features Implemented

### 1. User Online Status Display
- **Green indicator dot** and "Active now" text for online users
- **Gray indicator dot** and "Offline" text for offline users
- Real-time updates based on Firebase Firestore data

### 2. Automatic Status Updates

#### Sign In/Sign Up
When users sign in or sign up through any method:
- Status is set to `isOnline: true`
- `lastSeen` timestamp is updated to current server time

Supported authentication methods:
- Email/Password authentication
- Google Sign-In
- Phone authentication (OTP)

#### Sign Out
When users sign out:
- Status is set to `isOnline: false`
- `lastSeen` timestamp is updated to current server time

#### App Lifecycle Management
The app automatically updates status based on app state:
- **App comes to foreground**: Sets user online
- **App goes to background**: Sets user offline
- **App is minimized**: Sets user offline

## Technical Implementation

### Files Modified

#### 1. `lib/services/auth/auth_service.dart`
Added online status updates to all authentication methods:

```dart
// Sign In
await _firestore.collection("Users").doc(userCredential.user!.uid).set({
  'uid': userCredential.user!.uid,
  'email': userCredential.user!.email,
  'isOnline': true,  // ✅ Set online on sign in
  'lastSeen': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));

// Sign Out
await _firestore.collection("Users").doc(userId).update({
  'isOnline': false,  // ✅ Set offline on sign out
  'lastSeen': FieldValue.serverTimestamp(),
});
```

#### 2. `lib/pages/home_page.dart`
Added lifecycle management and status updates:

```dart
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);  // ✅ Add lifecycle observer
    _setUserOnline();  // ✅ Set online when home page loads
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _setUserOnline();  // ✅ App resumed
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _setUserOffline();  // ✅ App paused/inactive
    }
  }
}
```

**User tile display**:
```dart
// Read online status from Firebase data
bool isOnline = userData["isOnline"] ?? false;

ModernUserTile(
  text: email,
  onTap: () => Navigator.push(...),
  isOnline: isOnline,  // ✅ Dynamic status from Firebase
)
```

#### 3. `lib/components/home/modern_user_tile.dart`
Displays online status with visual indicators:

```dart
// Online indicator dot
Container(
  width: 12,
  height: 12,
  decoration: BoxDecoration(
    color: isOnline ? Colors.green : Colors.grey,  // ✅ Green/Gray indicator
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white, width: 2),
  ),
)

// Status text
Text(
  isOnline ? 'Active now' : 'Offline',  // ✅ Status text
  style: TextStyle(
    fontSize: 12,
    color: isOnline ? Colors.green : Colors.grey,
  ),
)
```

## Firebase Firestore Structure

### Users Collection
Each user document now includes:
```json
{
  "uid": "user_unique_id",
  "email": "user@example.com",
  "isOnline": true,              // ✅ Boolean: true = online, false = offline
  "lastSeen": "2024-01-01T12:00:00Z"  // ✅ Server timestamp
}
```

## How It Works

### 1. User Signs In
```
User enters credentials → Authentication successful → 
Firebase updates: { isOnline: true, lastSeen: now() } →
Home screen shows user as "Active now"
```

### 2. User Uses App
```
App in foreground → isOnline: true →
User switches to another app → App paused →
Firebase updates: { isOnline: false, lastSeen: now() } →
Other users see this user as "Offline"
```

### 3. User Returns to App
```
User opens app → App resumed →
Firebase updates: { isOnline: true, lastSeen: now() } →
Home screen shows user as "Active now" again
```

### 4. User Signs Out
```
User clicks logout → Before signing out →
Firebase updates: { isOnline: false, lastSeen: now() } →
Sign out completes → User returns to auth screen
```

## Benefits

✅ **Real-time presence tracking**: Know when contacts are available to chat
✅ **Automatic updates**: No manual intervention needed
✅ **Accurate status**: Reflects actual app usage state
✅ **Last seen timestamp**: Track when users were last active
✅ **Visual indicators**: Green/gray dots and text for quick recognition
✅ **Multi-platform support**: Works across all authentication methods

## Testing

### Test Scenarios

1. **Sign In Test**
   - Sign in with any method (email/Google/phone)
   - Verify you appear as "Active now" to other users
   - Check Firebase Console: `isOnline` should be `true`

2. **Sign Out Test**
   - Sign out from the app
   - Have another user check your status
   - Verify you appear as "Offline"
   - Check Firebase Console: `isOnline` should be `false`

3. **App Lifecycle Test**
   - Open the app (should be online)
   - Press home button to minimize app
   - Have another user check your status (should be offline)
   - Reopen the app (should be online again)

4. **Multi-User Test**
   - Sign in on two different devices/accounts
   - Both should see each other as "Active now"
   - Sign out one account
   - Other user should see them as "Offline"

## Future Enhancements

### Possible Improvements:
1. **Typing indicators**: Show when someone is typing a message
2. **Last seen display**: Show "Last seen 5 minutes ago" instead of just "Offline"
3. **Away status**: Auto-set to "Away" after X minutes of inactivity
4. **Custom statuses**: Allow users to set custom status messages
5. **Do Not Disturb**: Let users manually set themselves as offline
6. **Firebase onDisconnect()**: Automatically set offline if connection drops
7. **Chat page presence**: Show online status in individual chat screens

## Troubleshooting

### Issue: Users always show as offline
**Solution**: Ensure Firebase Firestore rules allow read/write access to the `Users` collection:
```javascript
match /Users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

### Issue: Status doesn't update when app minimizes
**Solution**: Check that `WidgetsBindingObserver` is properly implemented and `didChangeAppLifecycleState` is being called.

### Issue: Old users don't have `isOnline` field
**Solution**: The code uses `userData["isOnline"] ?? false` which defaults to `false` if the field doesn't exist. Users will appear offline until they sign in again.

## Summary

The online status feature is now fully functional, providing real-time presence information for all users in the chat app. The implementation automatically handles status updates across all authentication methods and app lifecycle states, requiring no manual intervention from users or developers.
