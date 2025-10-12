# Components Library - Organization Guide

## 📁 Folder Structure

```
lib/components/
├── components.dart              # Main barrel file - import all components
├── common/                      # Common/Shared components
│   ├── common.dart             # Barrel file
│   ├── empty_state.dart        # Empty state displays
│   ├── loading_indicator.dart  # Loading spinners
│   ├── error_message.dart      # Error displays
│   ├── custom_badge.dart       # Badges and notification counters
│   └── divider_with_text.dart  # Dividers with labels
├── chat/                        # Chat-specific components
│   ├── chat.dart               # Barrel file
│   ├── modern_chat_bubble.dart # Modern message bubble
│   ├── chat_bubble.dart        # Legacy message bubble
│   ├── typing_indicator.dart   # Typing animation
│   ├── message_reaction_picker.dart  # Reaction selector
│   ├── modern_message_input.dart     # Message input field
│   ├── message_date_separator.dart   # Date separators in chat
│   ├── message_status_indicator.dart # Message status icons
│   └── voice_message_bubble.dart     # Voice message player
├── user/                        # User-related components
│   ├── user.dart               # Barrel file
│   ├── modern_user_tile.dart   # Modern user list item
│   ├── user_tile.dart          # Legacy user list item
│   ├── user_avatar.dart        # Avatar component
│   ├── online_status_indicator.dart  # Online/offline status
│   └── user_profile_card.dart        # User profile display
├── forms/                       # Form input components
│   ├── forms.dart              # Barrel file
│   ├── my_button.dart          # Legacy button
│   ├── my_textfield.dart       # Legacy text field
│   ├── modern_button.dart      # Modern button styles
│   ├── modern_textfield.dart   # Modern input fields
│   └── icon_button_with_label.dart   # Icon button with text
└── layout/                      # Layout components
    ├── layout.dart             # Barrel file
    ├── modern_app_bar.dart     # Modern gradient app bar
    ├── my_drawer.dart          # Navigation drawer
    ├── bottom_nav_bar.dart     # Bottom navigation
    └── floating_action_menu.dart     # FAB with menu
```

## 🚀 Usage

### Quick Import (Recommended)

Import all components at once:
```dart
import 'package:chat_app/components/components.dart';
```

### Category-Specific Import

Import only what you need:
```dart
import 'package:chat_app/components/common/common.dart';
import 'package:chat_app/components/chat/chat.dart';
import 'package:chat_app/components/user/user.dart';
import 'package:chat_app/components/forms/forms.dart';
import 'package:chat_app/components/layout/layout.dart';
```

### Individual Import

Import specific components:
```dart
import 'package:chat_app/components/chat/modern_chat_bubble.dart';
import 'package:chat_app/components/user/user_avatar.dart';
```

## 📦 Component Categories

### 1. Common Components

**Purpose:** Reusable UI elements used across the app

| Component | Description | Usage |
|-----------|-------------|-------|
| `EmptyState` | Display when no data available | Lists, search results |
| `LoadingIndicator` | Loading spinner with optional message | Data fetching |
| `ErrorMessage` | Error display with retry button | Error handling |
| `CustomBadge` | Text badges | Tags, labels |
| `NotificationBadge` | Count badges | Unread counts |
| `DividerWithText` | Divider with centered text | Section separators |

**Example:**
```dart
LoadingIndicator(
  message: 'Loading messages...',
  size: 40,
)

ErrorMessage(
  message: 'Failed to load data',
  onRetry: () => loadData(),
)

NotificationBadge(count: 5)
```

### 2. Chat Components

**Purpose:** Chat and messaging functionality

| Component | Description | Usage |
|-----------|-------------|-------|
| `ModernChatBubble` | Modern message bubble | Chat messages |
| `ChatBubble` | Legacy message bubble | Fallback |
| `TypingIndicator` | Animated typing dots | When user types |
| `MessageReactionPicker` | Emoji reaction selector | Message reactions |
| `ModernMessageInput` | Message input field | Send messages |
| `MessageDateSeparator` | Date dividers in chat | Group messages by date |
| `MessageStatusIndicator` | Message status icons | Sent/delivered/read |
| `VoiceMessageBubble` | Voice message player | Audio messages |

**Example:**
```dart
ModernChatBubble(
  message: "Hello!",
  isCurrentUser: true,
  timestamp: Timestamp.now(),
  messageId: "123",
  chatRoomId: "room1",
  reactions: {"👍": "👍"},
  onDelete: () => deleteMessage(),
  onReactionTap: (r) => addReaction(r),
)

MessageDateSeparator(date: DateTime.now())

VoiceMessageBubble(
  isCurrentUser: true,
  duration: Duration(seconds: 30),
  onPlay: () => playAudio(),
  isPlaying: false,
)
```

### 3. User Components

**Purpose:** User profiles and avatars

| Component | Description | Usage |
|-----------|-------------|-------|
| `ModernUserTile` | Modern user list item | User lists |
| `UserTile` | Legacy user list item | Fallback |
| `UserAvatar` | Avatar with online status | Profile pictures |
| `OnlineStatusIndicator` | Online/offline dot | Status display |
| `OnlineStatusText` | Status with text | "Active now" |
| `UserProfileCard` | Full profile card | Profile pages |

**Example:**
```dart
UserAvatar(
  name: "John Doe",
  imageUrl: "https://...",
  size: 60,
  showOnlineStatus: true,
  isOnline: true,
)

ModernUserTile(
  email: "user@example.com",
  displayName: "John Doe",
  isOnline: true,
  onTap: () => openChat(),
)

UserProfileCard(
  name: "John Doe",
  email: "john@example.com",
  bio: "Hey there! I'm using Chat App",
  isOnline: true,
  actions: [
    IconButton(icon: Icon(Icons.chat), onPressed: () {}),
  ],
)
```

### 4. Form Components

**Purpose:** Input fields and buttons

| Component | Description | Usage |
|-----------|-------------|-------|
| `MyButton` | Legacy button | Forms |
| `MyTextField` | Legacy text field | Forms |
| `ModernButton` | Modern gradient button | Primary actions |
| `ModernOutlinedButton` | Outlined button | Secondary actions |
| `ModernTextField` | Modern input field | Forms |
| `ModernSearchField` | Search input | Search functionality |
| `IconButtonWithLabel` | Icon button with label | Action buttons |

**Example:**
```dart
ModernButton(
  text: "Send Message",
  icon: Icons.send,
  onPressed: () => send(),
  isLoading: false,
)

ModernTextField(
  controller: controller,
  hintText: "Enter your name",
  prefixIcon: Icons.person,
  validator: (v) => v!.isEmpty ? 'Required' : null,
)

ModernSearchField(
  controller: searchController,
  hintText: "Search users...",
  onChanged: (q) => search(q),
)

IconButtonWithLabel(
  icon: Icons.camera,
  label: "Camera",
  onPressed: () => openCamera(),
)
```

### 5. Layout Components

**Purpose:** Page structure and navigation

| Component | Description | Usage |
|-----------|-------------|-------|
| `ModernAppBar` | Gradient app bar | Page headers |
| `MyDrawer` | Navigation drawer | Side menu |
| `ModernBottomNavBar` | Bottom navigation | Main navigation |
| `FloatingActionMenu` | FAB with menu | Multiple actions |

**Example:**
```dart
ModernAppBar(
  title: "Chat",
  subtitle: "typing...",
  onBackPressed: () => Navigator.pop(context),
  actions: [
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)

ModernBottomNavBar(
  currentIndex: 0,
  onTap: (i) => changePage(i),
  items: [
    BottomNavItem(
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      label: "Chats",
      badgeCount: 3,
    ),
    BottomNavItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: "Users",
    ),
  ],
)

FloatingActionMenu(
  mainIcon: Icons.add,
  items: [
    FloatingActionMenuItem(
      icon: Icons.person_add,
      label: "New User",
      onPressed: () => addUser(),
    ),
    FloatingActionMenuItem(
      icon: Icons.group_add,
      label: "New Group",
      onPressed: () => createGroup(),
    ),
  ],
)
```

## 🎨 Design System

### Colors
- **Primary:** Blue (500-700)
- **Accent:** Purple (400-700)
- **Success:** Green
- **Error:** Red
- **Warning:** Orange

### Gradients
```dart
LinearGradient(
  colors: [Colors.blue.shade500, Colors.purple.shade600],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Border Radius
- Small: 8px
- Medium: 12px
- Large: 16px
- Extra Large: 20px
- Circular: 50%

### Shadows
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

### Spacing
- Extra Small: 4px
- Small: 8px
- Medium: 12px
- Large: 16px
- Extra Large: 24px

## 🔄 Migration Guide

### Updating Imports

**Before:**
```dart
import '../components/chat_bubble.dart';
import '../components/user_tile.dart';
import '../components/my_button.dart';
```

**After:**
```dart
import 'package:chat_app/components/components.dart';
// All components now available!
```

### Component Replacements

1. **Chat Bubble:**
   - Old: `ChatBubble` → New: `ModernChatBubble`

2. **User Tile:**
   - Old: `UserTile` → New: `ModernUserTile`

3. **Button:**
   - Old: `MyButton` → New: `ModernButton`

4. **TextField:**
   - Old: `MyTextField` → New: `ModernTextField`

5. **App Bar:**
   - Old: `AppBar` → New: `ModernAppBar`

## 📝 Best Practices

### 1. Use Barrel Files
✅ **Do:** `import 'package:chat_app/components/components.dart';`
❌ **Don't:** Import each file individually

### 2. Follow Naming Conventions
- Modern components: `Modern*`
- Legacy components: Keep original names
- Indicators: `*Indicator`
- Cards: `*Card`
- Tiles: `*Tile`

### 3. Keep Components Small
- Single responsibility
- Composable
- Reusable

### 4. Use Theme
- Always use `Theme.of(context)`
- Support dark mode
- Follow design system

### 5. Document Usage
- Add doc comments
- Provide examples
- Explain parameters

## 🧪 Testing

### Widget Tests
```dart
testWidgets('LoadingIndicator displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoadingIndicator(message: 'Loading...'),
    ),
  );
  
  expect(find.text('Loading...'), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## 🚀 Future Enhancements

Planned components:
- [ ] Image message bubble
- [ ] File attachment bubble
- [ ] Location sharing bubble
- [ ] Poll/Survey widget
- [ ] Group info card
- [ ] Call UI components
- [ ] Settings list items
- [ ] Custom sliders
- [ ] Color picker
- [ ] Date/Time picker

## 📚 Documentation

Each component includes:
- **Purpose:** What it's for
- **Parameters:** Required and optional
- **Example:** Usage code
- **Theme Support:** Light/dark mode
- **Animations:** If animated

## 🎯 Summary

**Total Components:** 28+
- Common: 6
- Chat: 8
- User: 6
- Forms: 6
- Layout: 4

**Benefits:**
- ✅ Clean organization
- ✅ Easy imports
- ✅ Consistent design
- ✅ Reusable components
- ✅ Well documented
- ✅ Theme support
- ✅ Modern UI

Use `import 'package:chat_app/components/components.dart';` to access all components! 🎉
