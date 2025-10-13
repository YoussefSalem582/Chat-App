# Firebase Firestore Security Rules Update

## Error: Permission Denied

The error `PERMISSION_DENIED: Missing or insufficient permissions` occurs because your Firestore security rules don't allow editing/deleting user documents.

## Solution: Update Firestore Security Rules

### Steps to Fix:

1. **Go to Firebase Console:**
   - Open [Firebase Console](https://console.firebase.google.com)
   - Select your project: `chat_app`

2. **Navigate to Firestore Database:**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab

3. **Replace your current rules with these updated rules:**

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             request.auth.token.email == 'admin@gmail.com';
    }
    
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user is owner
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /Users/{userId} {
      // Allow read if signed in
      allow read: if isSignedIn();
      
      // Allow create for new users (registration)
      allow create: if isSignedIn() && isOwner(userId);
      
      // Allow update if:
      // 1. User is updating their own profile, OR
      // 2. User is admin
      allow update: if isSignedIn() && (isOwner(userId) || isAdmin());
      
      // Allow delete only if admin
      allow delete: if isAdmin();
    }
    
    // Chats collection
    match /chats/{chatId} {
      // Allow read if user is a participant or admin
      allow read: if isSignedIn() && 
                    (request.auth.uid in resource.data.participants || isAdmin());
      
      // Allow create if signed in
      allow create: if isSignedIn() && 
                      request.auth.uid in request.resource.data.participants;
      
      // Allow update if user is a participant or admin
      allow update: if isSignedIn() && 
                      (request.auth.uid in resource.data.participants || isAdmin());
      
      // Allow delete if admin
      allow delete: if isAdmin();
      
      // Messages subcollection
      match /messages/{messageId} {
        // Allow read if user is a participant in parent chat or admin
        allow read: if isSignedIn() && 
                      (request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants || isAdmin());
        
        // Allow create if user is a participant
        allow create: if isSignedIn() && 
                        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        
        // Allow update/delete if user is sender or admin
        allow update, delete: if isSignedIn() && 
                                (request.auth.uid == resource.data.senderId || isAdmin());
      }
    }
    
    // Stories collection (if you have it)
    match /stories/{storyId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(request.resource.data.userId);
      allow update, delete: if isSignedIn() && 
                              (isOwner(resource.data.userId) || isAdmin());
    }
    
    // Default: Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

4. **Click "Publish" button** to save and deploy the rules

### What These Rules Do:

✅ **Admin Privileges:**
- Admin can read, update, and delete ANY user
- Admin can read, update, and delete ANY chat
- Admin can read, update, and delete ANY message

✅ **User Privileges:**
- Users can read all other users (for chat/contacts)
- Users can create their own profile
- Users can update their own profile
- Users can only delete their profile if admin

✅ **Chat Security:**
- Only participants can read/write their chats
- Only sender can update/delete their messages
- Admin has full access for moderation

### Alternative: Development/Testing Rules (Less Secure)

If you want to temporarily allow all operations for testing:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ Warning:** Only use this for development. Never in production!

### After Updating Rules:

1. Wait 10-30 seconds for rules to propagate
2. Restart your Flutter app
3. Try editing/deleting a user again
4. Should work without permission errors!

### Verify Rules Work:

```dart
// Test admin operations in your app:
1. Login as admin@gmail.com
2. Go to Users tab
3. Click Edit on any user (not admin)
4. Update name and save ✅
5. Click Delete on any user (not admin)
6. Confirm deletion ✅
```

The error should be resolved now! 🎉
