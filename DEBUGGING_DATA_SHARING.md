# Data Sharing Debugging & Troubleshooting

## 🔍 Issues Fixed

### 1. **Missing Widget Entitlements File**
   - **Problem**: Widget target didn't have `.entitlements` file
   - **Solution**: Created `MandoWidget/MandoWidget.entitlements`
   - **Result**: Widget can now access app group container

### 2. **No Initial Word Set**
   - **Problem**: App never initialized default word index
   - **Solution**: Added initialization in `LearnMandoWidgetsApp.onAppear`
   - **Result**: First launch sets word index to 0

### 3. **Widget Not Refreshing After Changes**
   - **Problem**: Widget timeline policy was `.never`
   - **Solution**: Changed to `.after(2 hours)` with frequent checkpoints
   - **Result**: Widget refreshes every 15 minutes and reloads when app signals change

### 4. **No Timeline Reload Signals**
   - **Problem**: Changing words didn't signal widget to update
   - **Solution**: Added `WidgetCenter.shared.reloadAllTimelines()` calls
   - **Result**: Widget updates immediately when user navigates or changes favorites

---

## ✅ Testing Checklist (Updated)

Follow these steps **in order**:

### Step 1: Clean Build
```bash
cd /Users/justin/repos/LearnMandoWidgets
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# In Xcode: Product → Clean Build Folder (Cmd + Shift + K)
# Then: Product → Build (Cmd + B)
```

### Step 2: Select Correct Scheme
- [ ] Select scheme: **LearnMandoWidgets** (not MandoWidget)
- [ ] Select simulator: **iPhone 15 Pro** (or recent model)
- [ ] Run app: **Cmd + R**

### Step 3: First Run - App Initialization
- [ ] App launches
- [ ] Check console for any errors (Cmd + Option + C)
- [ ] App should show first word: "你好" (Hello)
- [ ] Leave app running

### Step 4: Add Widget
- [ ] Go to home screen (Cmd + H or swipe left)
- [ ] Long-press empty area → Edit Home Screen → Add Widget
- [ ] Search for **Mandarin Word**
- [ ] Add **Small** or **Medium** widget
- [ ] Verify widget appears (may be blank initially)

### Step 5: Test Data Sync
- [ ] **Look at widget** - should show current word from app
  - If blank: tap the widget or wait 15 seconds
  - If still blank: see "Debugging Blank Widget" below

### Step 6: Test Navigation
1. [ ] Bring app to foreground
2. [ ] Click **Next** button
3. [ ] App shows new word (e.g., "谢谢")
4. [ ] Go back to home screen
5. [ ] **Widget should show "谢谢"** (same word as app)
6. [ ] If not updated: tap widget or wait 15 seconds

### Step 7: Test Favorites
1. [ ] In app, tap **❤️** heart icon
2. [ ] Heart turns red
3. [ ] Go to home screen
4. [ ] Widget should still show correct word
5. [ ] Tap app in widget or home screen
6. [ ] App heart should still be red

### Step 8: Test Multiple Navigation
- [ ] Click Previous button several times
- [ ] Navigate through different words
- [ ] **Each time, check widget updates**
- [ ] All words should match between app and widget

---

## 🐛 Debugging: Widget Showing Blank or Wrong Word

### Check 1: Verify Entitlements Files Exist

```bash
# In Terminal, check both exist:
ls -la "/Users/justin/repos/LearnMandoWidgets/LearnMandoWidgets/"*".entitlements"
ls -la "/Users/justin/repos/LearnMandoWidgets/MandoWidget/"*".entitlements"

# Should output 2 files
```

**Expected output:**
```
LearnMandoWidgets.entitlements
MandoWidget.entitlements
```

### Check 2: Verify Entitlements Content

Open both files and verify they contain:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.justin.mandowidgets</string>
</array>
```

### Check 3: Check Xcode Project Settings

1. [ ] Open project in Xcode
2. [ ] Select **LearnMandoWidgets** target
3. [ ] Go to **Build Settings**
4. [ ] Search for **Code Sign Entitlements**
5. [ ] Should show: `LearnMandoWidgets/LearnMandoWidgets.entitlements`
6. [ ] Repeat for **MandoWidget** target

### Check 4: Enable Console Logging

Add temporary debug logging to widget Provider:

In `MandoWidget.swift`, update `getSnapshot`:

```swift
func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let word = SharedDataManager.shared.getCurrentWord()
    let accessible = SharedDataManager.shared.isAppGroupAccessible()
    let index = SharedDataManager.shared.getCurrentWordIndex()
    
    print("🔧 Widget Snapshot - Accessible: \(accessible), Index: \(index), Word: \(word.character)")
    
    let entry = SimpleEntry(date: Date(), word: word)
    completion(entry)
}
```

### Check 5: Verify Data is Actually Being Saved

Add logging to app. In `ContentView.swift`, update `updateUI()`:

```swift
private func updateUI() {
    isFavorite = SharedDataManager.shared.isFavorite(currentWord.character)
    let index = SharedDataManager.shared.getCurrentWordIndex()
    let accessible = SharedDataManager.shared.isAppGroupAccessible()
    print("📱 App - Accessible: \(accessible), Index: \(index), Word: \(currentWord.character)")
}
```

Then check Xcode console (Cmd + Option + C) when you navigate words.

---

## 🧪 Advanced Debugging

### Test App Group Access Directly

Add this to `ContentView.onAppear`:

```swift
.onAppear {
    let manager = SharedDataManager.shared
    
    print("=" * 50)
    print("🔍 DEBUG: App Groups Test")
    print("Accessible: \(manager.isAppGroupAccessible())")
    print("Current Index: \(manager.getCurrentWordIndex())")
    print("Current Word: \(manager.getCurrentWord().character)")
    print("Favorites: \(manager.getFavoriteWords())")
    print("=" * 50)
    
    updateUI()
}
```

### Force Widget Refresh

In `ContentView`, add a debug button temporarily:

```swift
Button("🔄 Refresh Widget") {
    WidgetCenter.shared.reloadAllTimelines()
    print("✅ Widget reload triggered")
}
```

Tap this after changing words to force immediate widget update.

---

## 🔄 Step-by-Step Fix Process

If widget still shows nothing after testing:

1. **Clean everything**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

2. **Verify entitlements files are linked**
   - Select project
   - Select **LearnMandoWidgets** target
   - Go to **Build Phases**
   - Expand **Copy Bundle Resources**
   - Should see: `LearnMandoWidgets.entitlements`
   - Repeat for **MandoWidget** target

3. **Rebuild**
   ```bash
   cd /Users/justin/repos/LearnMandoWidgets
   xcodebuild clean
   # Then in Xcode: Cmd + B
   ```

4. **Delete widget from home screen**
   - Long-press widget
   - Remove widget
   - Re-add it fresh

5. **Restart simulator**
   - Simulator menu → Device → Erase All Content and Settings
   - Rebuild and run

---

## ✨ What Should Happen Now

### Timeline 1: First App Launch
```
1. App starts
2. LearnMandoWidgetsApp.onAppear triggers
3. SharedDataManager initializes to word index 0
4. WidgetCenter.shared.reloadAllTimelines() called
5. Widget Provider.getTimeline() called
6. Widget reads from shared container
7. Widget displays "你好"
```

### Timeline 2: User Navigates
```
1. User taps "Next" in app
2. ContentView updates currentIndex
3. SharedDataManager saves new index
4. WidgetCenter.shared.reloadAllTimelines() called
5. Widget Provider refreshes immediately
6. Widget displays new word
```

### Timeline 3: User Adds Favorite
```
1. User taps ❤️ in app
2. SharedDataManager saves to favorites
3. WidgetCenter.shared.reloadAllTimelines() called
4. Widget updates (data available if needed)
```

---

## 📱 Expected Console Output

**App console** (Cmd + Option + C):
```
📱 App - Accessible: true, Index: 0, Word: 你好
✅ Word updated
✅ Widget reload triggered
```

**Widget console** (in Widget target):
```
🔧 Widget Snapshot - Accessible: true, Index: 0, Word: 你好
```

If you see `Accessible: false` — app groups not working.

---

## 🆘 Still Not Working?

1. **Take a screenshot** of:
   - The app showing a word
   - The widget on home screen
   - Xcode console output

2. **Check these specific points**:
   - [ ] Both `.entitlements` files exist and have same identifier
   - [ ] App group identifier: `group.com.justin.mandowidgets` (verify spelling)
   - [ ] You did Product → Clean Build Folder
   - [ ] You restarted Xcode after adding entitlements
   - [ ] App ran before adding widget
   - [ ] Widget was added fresh after fixes

3. **Last resort**: Delete and recreate the entitlements
   - Delete both `.entitlements` files
   - In Xcode, remove App Groups capability from both targets
   - Re-add App Groups capability to both targets
   - Verify entitlements regenerate
   - Clean build, run app, add widget

---

## 📚 Files Modified for Debugging

- ✅ `MandoWidget/MandoWidget.entitlements` - Created
- ✅ `LearnMandoWidgetsApp.swift` - Added initialization & widget refresh
- ✅ `ContentView.swift` - Added widget refresh on every action
- ✅ `MandoWidget.swift` - Improved timeline provider

---

**Try the updated build and let me know if the widget now syncs with the app!**
