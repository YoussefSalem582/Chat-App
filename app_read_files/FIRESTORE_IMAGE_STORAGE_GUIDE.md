# Firestore Image Storage Implementation

## ⚠️ Important Notice
This is a **temporary solution** for storing profile images without Firebase Storage. This approach is **not recommended for production** due to:
- Firestore document size limits (1MB per document)
- Higher costs for large images
- Slower performance compared to Firebase Storage
- Not optimized for image delivery

**Recommended**: Upgrade to Firebase Blaze plan and use Firebase Storage for proper image handling.

---

## How It Works

### 1. Image Upload Process
- User selects an image from gallery or camera
- Image is compressed to max 1024x1024, quality 85%
- Image is converted to base64 string
- Base64 string is stored in Firestore subcollection

### 2. Storage Structure
```
Users (collection)
└── {userId} (document)
    ├── email
    ├── displayName
    ├── hasProfileImage: true/false
    └── profile_images (subcollection)
        └── current (document)
            ├── base64: "iVBORw0KG..."
            ├── contentType: "image/jpeg"
            ├── uploadedAt: timestamp
            └── userId: "abc123"
```

### 3. Image Retrieval
- Check `hasProfileImage` flag on user document
- If true, fetch from `profile_images/current` subcollection
- Decode base64 to Uint8List
- Display using `Image.memory()`

---

## Required Firestore Security Rules

Update your Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /Users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // Profile images subcollection
      match /profile_images/{imageId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Chat rooms
    match /chat_rooms/{chatRoomId} {
      allow read, write: if request.auth != null;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
    
    // User chats
    match /userChats/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## File Size Limits

### Current Limits:
- **Maximum image size**: 1MB (1024 KB)
- **Recommended size**: 500 KB or less
- **Compression**: 1024x1024 pixels, 85% quality

### Why These Limits?
- Firestore has a 1MB document size limit
- Base64 encoding increases size by ~33%
- Need buffer space for metadata

---

## Code Changes Made

### 1. ProfileService (`lib/services/profile/profile_service.dart`)
- ✅ Removed Firebase Storage dependency
- ✅ Added base64 encoding/decoding
- ✅ Added file size validation
- ✅ Store images in Firestore subcollection
- ✅ Added `getProfileImage()` method
- ✅ Added `getUserProfileImage(userId)` method

### 2. ProfileAvatar (`lib/components/profile/profile_avatar.dart`)
- ✅ Changed from StatelessWidget to StatefulWidget
- ✅ Changed prop from `photoURL` to `hasProfileImage`
- ✅ Added image loading logic
- ✅ Display using `Image.memory()` instead of `Image.network()`
- ✅ Added loading indicator

### 3. ProfilePage (`lib/pages/profile_page.dart`)
- ✅ Updated to use `hasProfileImage` flag
- ✅ Modified success message
- ✅ Reload user data after upload

---

## Testing Checklist

- [ ] Update Firestore security rules in Firebase Console
- [ ] Hot restart the Flutter app
- [ ] Test image upload from gallery
- [ ] Test image upload from camera
- [ ] Test image removal
- [ ] Verify image displays correctly
- [ ] Check console for any errors
- [ ] Test with different image sizes

---

## Limitations

1. **File Size**: Images larger than 1MB will be rejected
2. **Performance**: Slower than Firebase Storage
3. **Bandwidth**: Uses Firestore reads/writes quota
4. **Caching**: No automatic CDN caching like Storage
5. **Cost**: More expensive for large-scale apps

---

## Migration Path (When You Upgrade to Blaze)

When you're ready to use Firebase Storage:

1. **Enable Firebase Storage** in Console
2. **Update security rules** for Storage
3. **Revert ProfileService** to use Storage
4. **Migrate existing images** (optional)
5. **Update ProfileAvatar** to use `Image.network()`

Code for Firebase Storage version is available in git history.

---

## Error Messages

### "Error: Image too large"
- Image exceeds 1MB after compression
- Solution: Choose a smaller image or reduce quality

### "Error: Image file does not exist"
- Image picker failed or permission denied
- Solution: Check app permissions

### "Failed to upload image"
- Network error or Firestore rules issue
- Solution: Check internet connection and Firestore rules

---

## Support

If you encounter issues:
1. Check Firestore rules are correctly set
2. Verify internet connection
3. Check console logs for detailed errors
4. Ensure image is under 1MB

**Best solution**: Upgrade to Firebase Blaze plan (free tier is generous!) and use proper Firebase Storage.
