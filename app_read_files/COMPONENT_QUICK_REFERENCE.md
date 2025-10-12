# Quick Component Reference

## 🎨 Modern Components Cheat Sheet

### 1. ModernAppBar
```dart
// Location: lib/components/modern_app_bar.dart
// Use: Page headers with gradient

ModernAppBar(
  title: 'Page Title',
  subtitle: 'Optional subtitle',
  onBackPressed: () => Navigator.pop(context),
  actions: [IconButton(...)],
)
```
**Features:** Gradient background, title/subtitle, custom actions

---

### 2. ModernChatBubble
```dart
// Location: lib/components/modern_chat_bubble.dart
// Use: Chat message display

ModernChatBubble(
  message: "Your message",
  isCurrentUser: true,
  timestamp: Timestamp.now(),
  messageId: "id",
  chatRoomId: "roomId",
  reactions: {"👍": "👍"},
  onDelete: () => delete(),
  onReactionTap: (r) => react(r),
)
```
**Features:** Gradient for sender, avatars, reactions, long-press menu, read receipts

---

### 3. ModernMessageInput
```dart
// Location: lib/components/modern_message_input.dart
// Use: Message input field

ModernMessageInput(
  controller: _controller,
  focusNode: _focusNode,
  onSend: sendMessage,
  characterCount: _count,
  maxCharacters: 500,
)
```
**Features:** Glassmorphic design, gradient send button, character counter

---

### 4. ModernUserTile
```dart
// Location: lib/components/modern_user_tile.dart
// Use: User list items

ModernUserTile(
  email: "user@email.com",
  displayName: "Display Name",
  isOnline: true,
  onTap: () => openChat(),
)
```
**Features:** Gradient avatar, online indicator, hero animation

---

### 5. TypingIndicator
```dart
// Location: lib/components/typing_indicator.dart
// Use: Show when user is typing

if (isTyping) {
  return const TypingIndicator();
}
```
**Features:** Animated pulsing dots, matches bubble design

---

## 🎨 Color Scheme

### Light Mode
- **Primary:** Blue 500-600
- **Accent:** Purple 400-600
- **Background:** White/Light Grey
- **Text:** Black/Dark Grey

### Dark Mode
- **Primary:** Blue 700-800
- **Accent:** Purple 700-800
- **Background:** Dark Grey/Black
- **Text:** White/Light Grey

---

## ⚡ Quick Tips

### Gradients
All components use consistent blue → purple gradients:
```dart
LinearGradient(
  colors: [Colors.blue.shade500, Colors.purple.shade600],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Rounded Corners
Consistent 16-20px radius:
```dart
borderRadius: BorderRadius.circular(16)
```

### Shadows
Soft shadows for depth:
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 8,
  offset: const Offset(0, 2),
)
```

### Animations
Standard durations:
- Quick: 200-300ms
- Smooth: 400-600ms
- Entrance: 600-800ms

---

## 📍 Where Used

### Chat Page
- ✅ ModernAppBar (header)
- ✅ ModernChatBubble (messages)
- ✅ ModernMessageInput (input)
- ✅ TypingIndicator (when typing)

### Home Page
- ✅ Existing gradient header
- ✅ ModernUserTile (user list)

---

## 🔧 Customization

All components accept theme from context:
```dart
Theme.of(context).colorScheme.primary
Theme.of(context).brightness == Brightness.dark
```

Components auto-adapt to:
- ✅ Light/Dark theme
- ✅ Screen sizes
- ✅ User interactions

---

## ✅ Checklist

Before using components:
- [ ] Import the component file
- [ ] Pass required parameters
- [ ] Test in light mode
- [ ] Test in dark mode
- [ ] Verify animations work
- [ ] Check tap feedback

---

## 📞 Quick Help

**Problem:** Component not showing
- Check imports
- Verify required parameters
- Check theme context

**Problem:** Colors look wrong
- Verify Theme.of(context) available
- Check brightness setting
- Test in both themes

**Problem:** Animation not smooth
- Check vsync in StatefulWidget
- Verify duration values
- Test on real device

---

## 🎯 Best Practices

1. **Always** test in both light and dark mode
2. **Use** theme colors instead of hardcoded
3. **Keep** animations under 800ms
4. **Provide** proper tap feedback
5. **Handle** null values safely
6. **Add** Hero tags for transitions
7. **Test** on different screen sizes

---

## 📱 Component Status

| Component | Status | Theme Support | Animations |
|-----------|--------|---------------|------------|
| ModernAppBar | ✅ Ready | ✅ Yes | ✅ Smooth |
| ModernChatBubble | ✅ Ready | ✅ Yes | ✅ Smooth |
| ModernMessageInput | ✅ Ready | ✅ Yes | ✅ Smooth |
| ModernUserTile | ✅ Ready | ✅ Yes | ✅ Smooth |
| TypingIndicator | ✅ Ready | ✅ Yes | ✅ Smooth |

All components tested and production-ready! ✨
