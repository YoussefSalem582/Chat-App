# 🎨 Chat Screen - Visual Feature Guide

## 📱 Interactive Feature Map

```
╔═════════════════════════════════════════╗
║  [←] user@example.com      [🔍] [⋮]   ║  ← App Bar with Actions
║      🟢 Online                          ║  ← Real-time Status
╠═════════════════════════════════════════╣
║  [Search bar: Type to search...]   [×] ║  ← Search Mode (Toggle)
╠═════════════════════════════════════════╣
║  ┃ Replying to                      [×]║  ← Reply Preview (When active)
║  ┃ Original message preview...        ║
╠═════════════════════════════════════════╣
║  3 selected              [Cancel] [🗑️] ║  ← Selection Mode Header
╠═════════════════════════════════════════╣
║                                         ║
║         ┌─────────────┐                 ║
║         │   Today     │                 ║  ← Date Separator
║         └─────────────┘                 ║
║                                         ║
║  [☐] 👤 ┌──────────────────────┐       ║  ← Received Message
║         │ Hello! How are you?  │       ║    (with selection checkbox)
║         │ 10:30 AM             │       ║
║         └──────────────────────┘       ║
║                                         ║
║         ┌──────────────────────┐ 👤 [☑]║  ← Sent Message
║         │ I'm great, thanks!   │       ║    (selected)
║         │ 10:32 AM ✓✓          │       ║
║         │                      │       ║
║         │ 😊 ❤️               │       ║  ← Reactions
║         └──────────────────────┘       ║
║                                         ║
║  👤 ┌──────────────────────┐           ║  ← Message with Reply
║     │ ┃ Replying to:        │           ║
║     │ ┃ I'm great, thanks!  │           ║
║     ├─────────────────────┤           ║
║     │ That's wonderful!    │           ║
║     │ 10:33 AM             │           ║
║     └──────────────────────┘           ║
║                                         ║
║  👤 💭 Typing...                        ║  ← Typing Indicator
║                                      ⬇️ ║  ← Scroll to Bottom FAB
╠═════════════════════════════════════════╣
║  Character count: 42/500                ║  ← Character Counter
║  ┌─────────────────────────────────┐   ║
║  │[+]│ Type a message...      │[📨]│   ║  ← Message Input
║  └─────────────────────────────────┘   ║
╚═════════════════════════════════════════╝
     ↑                           ↑
     Attachments             Send Button
```

---

## 🎯 Feature Hotspots

### 1. App Bar Features
```
┌─────────────────────────────────────────┐
│  [←] user@example.com      [🔍] [⋮]    │
│      🟢 Online / ⚪ 2h ago              │
└─────────────────────────────────────────┘
  ↑       ↑           ↑      ↑    ↑
  |       |           |      |    └── More Options
  |       |           |      └───── Search Toggle
  |       |           └──────────── Last Seen Time
  |       └──────────────────────── User Email
  └──────────────────────────────── Back Navigation
```

**Tap Actions:**
- **←** Back to home
- **🔍** Toggle search mode
- **⋮** Open chat options (wallpaper, block, report)
- **Status** Read-only display

---

### 2. Search Feature
```
┌─────────────────────────────────────────┐
│  [Search: "hello"...]              [×]  │
└─────────────────────────────────────────┘
│                                         │
│  📄 Hello! How are you?                 │  ← Search Result 1
│     10:30 AM                            │
│  ─────────────────────────────────────  │
│  📄 Hello there!                        │  ← Search Result 2
│     Yesterday                           │
└─────────────────────────────────────────┘
```

**How to Use:**
1. Tap 🔍 in app bar
2. Type search term
3. Tap any result to jump to it
4. Tap × to close search

---

### 3. Reply Feature
```
STEP 1: Swipe Message
┌─────────────────────────────────────────┐
│  👤 ┌──────────────────────┐ → → →      │
│     │ Hello! How are you?  │            │
└─────────────────────────────────────────┘
       Swipe right to reply

STEP 2: Reply Preview Appears
┌─────────────────────────────────────────┐
│  ┃ Replying to                      [×] │
│  ┃ Hello! How are you?                 │
└─────────────────────────────────────────┘

STEP 3: Type & Send
┌─────────────────────────────────────────┐
│  │[+]│ I'm good, thanks!       │[📨]│   │
└─────────────────────────────────────────┘

RESULT: Message with Reply Reference
┌─────────────────────────────────────────┐
│                    ┌──────────────────┐  │
│                    │ ┃ Replying to:   │  │
│                    │ ┃ Hello! How...  │  │
│                    ├─────────────────┤  │
│                    │ I'm good, thanks!│ │
│                    └──────────────────┘  │
└─────────────────────────────────────────┘
```

**Gestures:**
- **Received msg**: Swipe RIGHT →
- **Sent msg**: Swipe LEFT ←
- **Cancel**: Tap × button

---

### 4. Selection Mode
```
STEP 1: Long Press Message
┌─────────────────────────────────────────┐
│  [☐] 👤 ┌──────────────────────┐        │
│         │ Message 1            │        │
│         └──────────────────────┘        │
└─────────────────────────────────────────┘
       Hold for 1 second

STEP 2: Selection Mode Active
┌─────────────────────────────────────────┐
│  3 selected              [Cancel] [🗑️]  │  ← Header appears
├─────────────────────────────────────────┤
│  [☑] 👤 ┌──────────────────────┐        │  ← Selected
│         │ Message 1            │        │
│  [☑] 👤 ┌──────────────────────┐        │  ← Selected
│         │ Message 2            │        │
│  [☐] 👤 ┌──────────────────────┐        │  ← Not selected
│         │ Message 3            │        │
└─────────────────────────────────────────┘

STEP 3: Tap Delete
┌─────────────────────────────────────────┐
│  ╔═══════════════════════════════════╗  │
│  ║ Delete 3 messages?                ║  │
│  ║                                   ║  │
│  ║  [Cancel]        [Delete]         ║  │
│  ╚═══════════════════════════════════╝  │
└─────────────────────────────────────────┘
```

**Actions:**
- **Long press** Enter selection mode
- **Tap messages** Toggle selection
- **Tap 🗑️** Delete all selected
- **Tap Cancel** Exit selection mode

---

### 5. Date Separators
```
┌─────────────────────────────────────────┐
│         ┌─────────────┐                 │
│         │   Today     │                 │  ← Automatic separator
│         └─────────────┘                 │
│                                         │
│  👤 Message at 10:30 AM                 │
│  👤 Message at 11:45 AM                 │
│                                         │
│         ┌─────────────┐                 │
│         │  Yesterday  │                 │  ← Day changed
│         └─────────────┘                 │
│                                         │
│  👤 Message from yesterday              │
│                                         │
│         ┌─────────────┐                 │
│         │  Monday     │                 │  ← Earlier this week
│         └─────────────┘                 │
│                                         │
│  👤 Message from Monday                 │
│                                         │
│         ┌─────────────┐                 │
│         │ 10/05/2025  │                 │  ← Older messages
│         └─────────────┘                 │
└─────────────────────────────────────────┘
```

**Smart Formatting:**
- Same day: "Today"
- Previous day: "Yesterday"
- This week: Day name ("Monday", "Tuesday")
- Older: Full date (DD/MM/YYYY)

---

### 6. Scroll to Bottom Button
```
┌─────────────────────────────────────────┐
│  [Messages above, scrolled up...]       │
│                                         │
│                                         │
│                                         │
│                                      ⬇️ │  ← FAB appears when
│                                         │     scrolled > 500px
└─────────────────────────────────────────┘

TAP ⬇️ →

┌─────────────────────────────────────────┐
│  👤 Latest message here                 │  ← Jumps to bottom
│  👤 Another message                     │
│  👤 Most recent message                 │
│                                         │  ← FAB hidden
└─────────────────────────────────────────┘
```

**Behavior:**
- **Shows**: When scrolled up > 500px
- **Hides**: When at bottom
- **Action**: Smooth scroll to latest message

---

### 7. Attachment Menu
```
STEP 1: Tap + Button
┌─────────────────────────────────────────┐
│  │[+]│ Type a message...       │[📨]│   │
└─────────────────────────────────────────┘
     ↑
   Tap here

STEP 2: Menu Appears
╔═════════════════════════════════════════╗
║  Send Attachment                        ║
╠═════════════════════════════════════════╣
║  📷  Image                              ║
║      Send photos from gallery           ║
║  ─────────────────────────────────────  ║
║  📸  Camera                             ║
║      Take a photo                       ║
║  ─────────────────────────────────────  ║
║  📄  Document                           ║
║      Send files                         ║
║  ─────────────────────────────────────  ║
║  📍  Location                           ║
║      Share your location                ║
╚═════════════════════════════════════════╝
```

**Options:**
- 📷 **Image** - Gallery picker
- 📸 **Camera** - Take photo
- 📄 **Document** - File picker
- 📍 **Location** - Map share

---

### 8. Chat Options Menu
```
STEP 1: Tap ⋮ in App Bar
┌─────────────────────────────────────────┐
│  [←] user@example.com      [🔍] [⋮]    │
└─────────────────────────────────────────┘
                                    ↑
                                Tap here

STEP 2: Options Menu
╔═════════════════════════════════════════╗
║  🖼️  Wallpaper                          ║
║      Customize chat background          ║
║  ─────────────────────────────────────  ║
║  🔔  Notifications                      ║
║      Manage chat notifications          ║
║  ─────────────────────────────────────  ║
║  🚫  Block User                         ║
║      Block this contact                 ║
║  ─────────────────────────────────────  ║
║  🚨  Report                             ║
║      Report inappropriate content       ║
╚═════════════════════════════════════════╝
```

**Actions:**
- 🖼️ **Wallpaper** - Custom backgrounds
- 🔔 **Notifications** - Mute/unmute
- 🚫 **Block** - Block contact
- 🚨 **Report** - Report user

---

### 9. Message Status Indicators
```
┌─────────────────────────────────────────┐
│                    ┌──────────────────┐  │
│                    │ Sending...       │  │
│                    │ 10:30 AM 🕐      │  │  ← Sending
│                    └──────────────────┘  │
│                                          │
│                    ┌──────────────────┐  │
│                    │ Sent!            │  │
│                    │ 10:30 AM ✓       │  │  ← Sent
│                    └──────────────────┘  │
│                                          │
│                    ┌──────────────────┐  │
│                    │ Delivered        │  │
│                    │ 10:30 AM ✓✓      │  │  ← Delivered
│                    └──────────────────┘  │
│                                          │
│                    ┌──────────────────┐  │
│                    │ Read!            │  │
│                    │ 10:30 AM ✓✓      │  │  ← Read (blue)
│                    └──────────────────┘  │
└─────────────────────────────────────────┘
```

**Status Icons:**
- 🕐 **Sending** - Being sent
- ✓ **Sent** - Delivered to server
- ✓✓ **Delivered** - Received by user
- ✓✓ (Blue) **Read** - Opened by user

---

### 10. Online Status Display
```
USER ONLINE:
┌─────────────────────────────────────────┐
│  [←] john@email.com        [🔍] [⋮]    │
│      🟢 Online                          │  ← Green dot + "Online"
└─────────────────────────────────────────┘

USER OFFLINE (Recent):
┌─────────────────────────────────────────┐
│  [←] john@email.com        [🔍] [⋮]    │
│      ⚪ 5m ago                          │  ← Grey dot + time
└─────────────────────────────────────────┘

USER OFFLINE (Hours):
┌─────────────────────────────────────────┐
│  [←] john@email.com        [🔍] [⋮]    │
│      ⚪ 2h ago                          │
└─────────────────────────────────────────┘

USER OFFLINE (Days):
┌─────────────────────────────────────────┐
│  [←] john@email.com        [🔍] [⋮]    │
│      ⚪ 3d ago                          │
└─────────────────────────────────────────┘
```

**Status Format:**
- Real-time updates
- Minutes: "5m ago"
- Hours: "2h ago"
- Days: "3d ago"
- Weeks: "2w ago"

---

## 🎨 Color Guide

### Status Colors
```
🟢 Online:     rgb(76, 175, 80)   #4CAF50
⚪ Offline:    rgb(158, 158, 158) #9E9E9E
🔵 Read:       rgb(33, 150, 243)  #2196F3
🔴 Error:      rgb(244, 67, 54)   #F44336
🟡 Warning:    rgb(255, 152, 0)   #FF9800
```

### Message Bubbles
```
Sent (Light):
  Gradient: #2196F3 → #1976D2

Sent (Dark):
  Gradient: #1976D2 → #1565C0

Received (Light):
  Solid: #EEEEEE

Received (Dark):
  Solid: #424242
```

### App Bar
```
Gradient: #2196F3 (Blue) → #9C27B0 (Purple)
Angle: Top-left to Bottom-right
Text: #FFFFFF (White)
Icons: #FFFFFF (White)
```

---

## 📏 Spacing & Sizing

### Message Layout
```
┌─────────────────────────────────────────┐
│  12px padding                           │
│  👤 ┌──────────────────────┐            │
│  8px│     Message          │            │
│     │  16px horizontal     │            │
│     │  12px vertical       │            │
│     └──────────────────────┘            │
│  4px padding                            │
└─────────────────────────────────────────┘
```

### Avatar Sizes
- **Chat List**: 40px diameter
- **Message Bubble**: 28px diameter
- **Profile**: 80px diameter

### Border Radius
- **Message Bubbles**: 20px
- **Input Field**: 25px
- **Buttons**: 12px
- **Date Separator**: 20px
- **Attachment Icons**: Circle

---

## 🎭 Animations

### Typing Indicator
```
Frame 1:  ●○○  
Frame 2:  ○●○  
Frame 3:  ○○●  
Frame 4:  ○○○  
Repeat    ↺
```
**Duration**: 1.2s per cycle

### Message Send
```
1. Fade in from right (Sent)
2. Fade in from left (Received)
Duration: 300ms
Curve: easeOut
```

### Scroll to Bottom
```
1. Slide up from bottom
2. Fade in
Duration: 200ms
```

### Reply Preview
```
1. Slide down
2. Fade in
Duration: 250ms
Curve: easeInOut
```

---

## 🖱️ Complete Gesture Map

```
╔═══════════════════════════════════════════════╗
║  GESTURE              ACTION                  ║
╠═══════════════════════════════════════════════╣
║  Tap Message          Select (if in mode)     ║
║  Long Press Message   Enter selection mode    ║
║  Swipe Right →        Reply (received)        ║
║  Swipe Left ←         Reply (sent)            ║
║  Pull Down ↓          Refresh messages        ║
║  Tap 🔍              Toggle search            ║
║  Tap ⋮               Show options             ║
║  Tap +               Show attachments         ║
║  Tap ⬇️              Scroll to bottom         ║
║  Tap ×               Cancel/Close             ║
║  Tap 🗑️              Delete selected          ║
║  Tap [Message]        Long press menu         ║
║  Double Tap           Quick reaction (future) ║
╚═══════════════════════════════════════════════╝
```

---

## 📱 Responsive Behavior

### Keyboard Open
```
BEFORE:
┌─────────────────────────────────────────┐
│  Messages...                            │
│  Messages...                            │
│  Messages...                            │
│  [Input field]                          │
└─────────────────────────────────────────┘

KEYBOARD OPENS:
┌─────────────────────────────────────────┐
│  Messages...                            │
│  [Input field]                          │
│  ╔═══════════════════════════════════╗  │
│  ║  Q W E R T Y U I O P              ║  │
│  ║  A S D F G H J K L                ║  │
│  ║  Z X C V B N M                    ║  │
│  ╚═══════════════════════════════════╝  │
└─────────────────────────────────────────┘
      ↑ Auto-scrolls to bottom
```

### Portrait vs Landscape
```
Portrait:          Landscape:
┌─────────┐       ┌────────────────────┐
│ App Bar │       │ App │  Messages    │
│─────────│       │ Bar │──────────────│
│         │       │─────│  Input       │
│Messages │       └────────────────────┘
│         │           ↑ Optimized layout
│─────────│
│  Input  │
└─────────┘
```

---

## 🎯 Feature Priority Map

### High Priority (Always Visible)
```
1. ⭐⭐⭐ Message List
2. ⭐⭐⭐ Send Button
3. ⭐⭐⭐ Input Field
4. ⭐⭐⭐ Online Status
```

### Medium Priority (Contextual)
```
5. ⭐⭐ Search (when needed)
6. ⭐⭐ Reply Preview (when replying)
7. ⭐⭐ Selection Header (when selecting)
8. ⭐⭐ Scroll FAB (when scrolled up)
```

### Low Priority (Options)
```
9. ⭐ Attachment Menu (on demand)
10. ⭐ Chat Options (on demand)
11. ⭐ Date Separators (automatic)
```

---

## 🎊 Complete Feature Checklist

### Core Messaging ✅
- [x] Send text messages
- [x] Receive messages
- [x] Real-time updates
- [x] Message history
- [x] Typing indicators

### Enhanced Features ✅
- [x] Reply to messages
- [x] Message search
- [x] Multiple selection
- [x] Delete messages
- [x] Message reactions

### UI Features ✅
- [x] Online status
- [x] Date separators
- [x] Scroll to bottom
- [x] Pull to refresh
- [x] Character counter

### Planned Features ⏳
- [ ] Image messages
- [ ] Voice messages
- [ ] File sharing
- [ ] Location sharing
- [ ] Message editing

---

**🎨 Visual guide complete! All features mapped and documented.**

---

*Visual Feature Guide v3.0*
*Last Updated: October 12, 2025*
