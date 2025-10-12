# 🚀 Cloud Functions Deployment Guide

This guide will help you deploy Firebase Cloud Functions to enable push notifications in your Chat App.

---

## 📋 Prerequisites

1. **Firebase CLI** installed
2. **Node.js** (v14 or later)
3. **Firebase project** (chatapp-922b4)
4. **Billing enabled** on Firebase (Blaze plan)

---

## 🔧 Step-by-Step Deployment

### Step 1: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version
```

### Step 2: Login to Firebase

```bash
# Login to your Firebase account
firebase login

# Verify you're logged in
firebase projects:list
```

### Step 3: Initialize Firebase Functions

```bash
# Navigate to your project root
cd chat_app

# Initialize functions (if not already done)
firebase init functions
```

**During initialization:**
- Select: **Use an existing project** → `chatapp-922b4`
- Language: **JavaScript** or **TypeScript** (JavaScript recommended)
- ESLint: **Yes** (recommended)
- Install dependencies: **Yes**

### Step 4: Copy Cloud Function Code

```bash
# Copy the provided index.js to functions directory
cp cloud_functions/index.js functions/index.js
```

Or manually copy the content from `cloud_functions/index.js` to `functions/index.js`

### Step 5: Install Dependencies

```bash
# Navigate to functions directory
cd functions

# Install required packages
npm install firebase-functions firebase-admin

# Return to project root
cd ..
```

### Step 6: Update package.json (Optional)

Edit `functions/package.json` to ensure correct Node.js version:

```json
{
  "name": "functions",
  "description": "Cloud Functions for Chat App",
  "engines": {
    "node": "18"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0"
  }
}
```

### Step 7: Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:sendMessageNotification
```

### Step 8: Verify Deployment

1. Go to [Firebase Console](https://console.firebase.google.com/project/chatapp-922b4/functions)
2. Check **Functions** tab
3. Verify these functions are deployed:
   - ✅ `sendMessageNotification`
   - ✅ `cleanupFCMToken`
   - ✅ `sendWelcomeNotification`
   - ✅ `sendBroadcastNotification`

---

## 🧪 Testing

### Test 1: Message Notification

1. Login with two different users
2. Send a message from User A to User B
3. Check logs:
   ```bash
   firebase functions:log
   ```
4. User B should receive notification

### Test 2: Check Function Logs

```bash
# Real-time logs
firebase functions:log --only sendMessageNotification

# Recent logs
firebase functions:log --limit 50
```

### Test 3: Manual Test via Console

1. Go to Firebase Console → Firestore
2. Manually create a message document
3. Watch function execute
4. Check logs for success

---

## 📊 Monitoring

### View Function Metrics

```bash
# Open Firebase Console
firebase open functions
```

In console, you can see:
- **Executions**: Number of times function ran
- **Execution time**: Average duration
- **Errors**: Failed executions
- **Logs**: Detailed execution logs

### Set Up Alerts

1. Go to **Functions** → **Health**
2. Click **Create Alert**
3. Set conditions (e.g., error rate > 5%)
4. Add email notification

---

## 🐛 Troubleshooting

### Issue: Deployment Failed

**Error**: `Billing account not configured`

**Solution**:
```bash
# Enable billing
firebase open billing
# Upgrade to Blaze plan
```

### Issue: Function Not Triggering

**Check**:
1. ✅ Function deployed successfully?
2. ✅ Firestore trigger path correct?
3. ✅ Message document created in correct location?

**Debug**:
```bash
# Check function logs
firebase functions:log --only sendMessageNotification
```

### Issue: Notification Not Sent

**Check**:
1. ✅ FCM token exists in user document?
2. ✅ Notification settings enabled?
3. ✅ FCM token valid?

**Debug**:
```javascript
// Add more logging in function
console.log('FCM Token:', fcmToken);
console.log('Settings:', settings);
```

### Issue: Function Timeout

**Error**: `Function execution took too long`

**Solution**:
```javascript
// Increase timeout in index.js
exports.sendMessageNotification = functions
  .runWith({ timeoutSeconds: 120 })
  .firestore.document('chat_rooms/{chatRoomId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    // ... function code
  });
```

---

## 💰 Cost Estimation

### Free Tier (Spark Plan)
- ❌ Cloud Functions not available

### Blaze Plan (Pay as you go)
- ✅ 2 million invocations/month free
- ✅ 400,000 GB-seconds free
- ✅ 200,000 CPU-seconds free
- Additional: $0.40 per million invocations

**Estimated monthly cost for 1000 users:**
- ~30,000 messages/month
- ~30,000 function invocations
- **Cost**: Free (within limits)

---

## 🔒 Security Rules

Update Firestore security rules to allow functions to write:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /Users/{userId} {
      // Allow functions to update FCM tokens
      allow read, write: if request.auth != null;
    }
    
    match /chat_rooms/{chatRoomId}/messages/{messageId} {
      // Allow functions to read messages
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

---

## 📝 Function Descriptions

### 1. `sendMessageNotification`
- **Trigger**: New message created
- **Action**: Send FCM notification to receiver
- **Features**: 
  - Checks notification settings
  - Handles deleted messages
  - Cleans up invalid tokens

### 2. `cleanupFCMToken`
- **Trigger**: User document updated
- **Action**: Log token removals
- **Purpose**: Debugging and monitoring

### 3. `sendWelcomeNotification`
- **Trigger**: New user registered
- **Action**: Send welcome notification
- **Purpose**: User onboarding

### 4. `sendBroadcastNotification`
- **Trigger**: HTTP callable function
- **Action**: Send notification to multiple users
- **Purpose**: Announcements

### 5. `cleanupOldMessages`
- **Trigger**: Daily schedule (midnight)
- **Action**: Delete messages older than 30 days
- **Purpose**: Database maintenance

---

## 🔄 Updates & Maintenance

### Update Functions

```bash
# Make changes to functions/index.js
# Deploy updates
firebase deploy --only functions
```

### Delete Functions

```bash
# Delete specific function
firebase functions:delete sendWelcomeNotification

# Or remove from index.js and redeploy
```

### View Function Code

```bash
# Download deployed function code
firebase functions:config:get > config.json
```

---

## 📚 Additional Resources

- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [Cloud Messaging Admin SDK](https://firebase.google.com/docs/cloud-messaging/admin)
- [Function Triggers](https://firebase.google.com/docs/functions/firestore-events)
- [Pricing Calculator](https://firebase.google.com/pricing)

---

## ✅ Deployment Checklist

Before going to production:

- [ ] Firebase CLI installed
- [ ] Logged in to Firebase
- [ ] Functions initialized
- [ ] Dependencies installed
- [ ] Code copied to functions/index.js
- [ ] Functions deployed successfully
- [ ] Test notification sent
- [ ] Logs checked for errors
- [ ] Billing account configured
- [ ] Security rules updated
- [ ] Monitoring enabled
- [ ] Error alerts set up

---

## 🎉 Success!

Your Cloud Functions are now deployed and your chat app has real-time push notifications! 🚀

**Next Steps:**
1. Test with real devices
2. Monitor function performance
3. Optimize for cost
4. Add more notification types

---

## 💡 Pro Tips

1. **Use environment variables** for sensitive data:
   ```bash
   firebase functions:config:set notification.apikey="YOUR_KEY"
   ```

2. **Batch operations** for better performance:
   ```javascript
   // Group multiple sends
   await admin.messaging().sendAll(messages);
   ```

3. **Implement retry logic** for failed sends:
   ```javascript
   // Retry with exponential backoff
   ```

4. **Add analytics** to track notification engagement:
   ```javascript
   await admin.analytics().logEvent('notification_sent');
   ```

---

**Happy Deploying! 🚀**
