# Edit Profile - Quick Reference

## 🆕 New Fields Added

### 1. Username Field
```
┌────────────────────────────────┐
│ Username                       │
│ ┌────────────────────────────┐ │
│ │ @ username                 │ │
│ └────────────────────────────┘ │
└────────────────────────────────┘
```
- **Validation:** 3+ chars, letters/numbers/underscore only
- **Unique:** Must be unique across all users
- **Optional:** Can be left blank
- **Example:** `johndoe`, `user_123`, `alice2024`

---

### 2. Location Field
```
┌────────────────────────────────┐
│ Location                       │
│ ┌────────────────────────────┐ │
│ │ 📍 City, Country           │ │
│ └────────────────────────────┘ │
└────────────────────────────────┘
```
- **Validation:** None
- **Optional:** Can be left blank
- **Example:** `New York, USA`, `London, UK`, `Tokyo, Japan`

---

### 3. Website Field
```
┌────────────────────────────────┐
│ Website                        │
│ ┌────────────────────────────┐ │
│ │ 🔗 https://yourwebsite.com │ │
│ └────────────────────────────┘ │
└────────────────────────────────┘
```
- **Validation:** Must start with http:// or https://
- **Optional:** Can be left blank
- **Example:** `https://github.com/username`, `https://portfolio.com`

---

## 📋 Complete Field List

| # | Field | Icon | Required | Validation |
|---|-------|------|----------|------------|
| 1 | Display Name | 👤 | ✅ Yes | 2+ characters |
| 2 | Bio | 📝 | ❌ No | Max 200 chars |
| 3 | Phone | 📱 | ❌ No | None |
| 4 | **Username** | @ | ❌ No | 3+ chars, unique, alphanumeric |
| 5 | **Location** | 📍 | ❌ No | None |
| 6 | **Website** | 🔗 | ❌ No | Must start with http(s):// |

---

## 🎯 Quick Actions

### On Edit Profile Page:
```
[Back] ← ──────────────── → [Save]
```

### Profile Display:
```
All fields are tappable to copy:
📧 Email       → Copy email address
🆔 User ID     → Copy user ID
📱 Phone       → Copy phone number
@ Username     → Copy @username
📍 Location    → Copy location
🔗 Website     → Copy website URL
```

---

## ⚡ Quick Test Guide

1. **Open Profile Page** → Tap "Edit Profile"
2. **Fill New Fields:**
   - Username: `testuser123`
   - Location: `San Francisco, USA`
   - Website: `https://example.com`
3. **Tap Save** → Should see success message
4. **Go Back** → New fields should appear in profile
5. **Tap Fields** → Should copy to clipboard

---

## 🐛 Common Issues

### Username Already Taken
```
Error: "Username already taken or update failed"
Solution: Choose a different username
```

### Invalid Website URL
```
Error: "Website must start with http:// or https://"
Solution: Add http:// or https:// prefix
```

### Username Too Short
```
Error: "Username must be at least 3 characters"
Solution: Use 3 or more characters
```

### Invalid Username Characters
```
Error: "Username can only contain letters, numbers, and underscores"
Solution: Remove special characters except underscore
```

---

## 💾 Firestore Structure

```
Users/
  └── {userId}/
      ├── displayName: "John Doe"
      ├── bio: "Software Developer"
      ├── phoneNumber: "+1234567890"
      ├── username: "johndoe"           ← NEW
      ├── location: "New York, USA"     ← NEW
      ├── website: "https://john.dev"   ← NEW
      └── updatedAt: {timestamp}
```

---

## 📱 Visual Layout

### Before (3 fields):
```
┌─────────────────────┐
│ Display Name        │
│ Bio                 │
│ Phone Number        │
└─────────────────────┘
```

### After (6 fields):
```
┌─────────────────────┐
│ Display Name    ✅  │
│ Bio             ✅  │
│ Phone Number    ✅  │
│ Username        🆕  │
│ Location        🆕  │
│ Website         🆕  │
└─────────────────────┘
```

---

## ✅ Checklist

Before submitting profile:
- [ ] Display name is at least 2 characters
- [ ] Username (if provided) is at least 3 characters
- [ ] Username only uses letters, numbers, underscore
- [ ] Website (if provided) starts with http:// or https://
- [ ] All fields look correct
- [ ] Press "Save Changes"

---

**Quick Tip:** All new fields are optional except Display Name!
