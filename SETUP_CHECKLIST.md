# Quick Setup Checklist ✅

Complete these steps to activate App Groups and test your Mandarin learning app with widget data synchronization.

---

## 📋 Pre-Setup Verification

- [ ] Project builds without errors (Cmd + B)
- [ ] Both targets exist: "LearnMandoWidgets" and "MandoWidget"
- [ ] Xcode is up to date

---

## 🔧 Step 1: Configure Main App Target

1. [ ] Open **LearnMandoWidgets.xcodeproj** in Xcode
2. [ ] Click on project in navigator
3. [ ] Select **LearnMandoWidgets** target
4. [ ] Go to **Signing & Capabilities** tab
5. [ ] Click **+ Capability**
6. [ ] Search for and select **App Groups**
7. [ ] Enter identifier: `group.com.justin.mandowidgets`
8. [ ] Verify it appears under "LearnMandoWidgets" target

---

## 🔧 Step 2: Configure Widget Target

1. [ ] Select **MandoWidget** target
2. [ ] Go to **Signing & Capabilities** tab
3. [ ] Click **+ Capability**
4. [ ] Search for and select **App Groups**
5. [ ] Enter **the same** identifier: `group.com.justin.mandowidgets`
6. [ ] Verify it appears under "MandoWidget" target

---

## 🏗️ Step 3: Build & Verify

1. [ ] Clean build folder (Cmd + Shift + K)
2. [ ] Build project (Cmd + B)
3. [ ] Check for build errors—resolve if any
4. [ ] Look for `.entitlements` files in Project Navigator
   - Should see: `LearnMandoWidgets.entitlements`
   - Should see: `MandoWidget.entitlements`

---

## 🧪 Step 4: Test in Simulator

1. [ ] Select target: **LearnMandoWidgets**
2. [ ] Select simulator: **iPhone 15 Pro (or any recent model)**
3. [ ] Run app (Cmd + R)
4. [ ] App launches successfully
5. [ ] Navigate to a word (e.g., "你好")
6. [ ] Tap the heart icon to add to favorites
7. [ ] Note the word shown in the app

---

## 📱 Step 5: Add Widget to Simulator

1. [ ] Go to home screen (Cmd + H)
2. [ ] Long-press on empty area
3. [ ] Tap **+ Add Widget** (or "Edit Home Screen")
4. [ ] Search for **Mandarin Word** widget
5. [ ] Select any widget size (Small or Medium recommended)
6. [ ] Add to home screen
7. [ ] Return to home screen to view widget

---

## 🔄 Step 6: Verify Data Synchronization

1. [ ] Open app (from home screen or app switcher)
2. [ ] Check the word displayed
3. [ ] Open Control Center (swipe down from top-right, or up from bottom-left on older iPhones)
4. [ ] Find the widget preview or go back to home screen
5. [ ] **Verify: Widget shows the SAME word as the app**
6. [ ] Navigate to next word in app using "Next" button
7. [ ] Check widget—it should show updated word
8. [ ] Go back to app and add a different word to favorites
9. [ ] Check app's heart icon reflects your action

---

## 🐛 Troubleshooting If Data Not Syncing

### Check 1: Verify App Group IDs
```
Main App "Signing & Capabilities":
  - Should show: "group.com.justin.mandowidgets" ✅

Widget "Signing & Capabilities":
  - Should show: "group.com.justin.mandowidgets" ✅

Both MUST be identical!
```

### Check 2: Verify Entitlements Files
1. [ ] Open **LearnMandoWidgets.entitlements**
   - Should contain `group.com.justin.mandowidgets`
2. [ ] Open **MandoWidget.entitlements**
   - Should contain `group.com.justin.mandowidgets`

### Check 3: Rebuild
```bash
# In Terminal:
cd /Users/justin/repos/LearnMandoWidgets
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean
```

### Check 4: Test App Group Accessibility
Add this to `ContentView` temporarily:
```swift
.onAppear {
    let accessible = SharedDataManager.shared.isAppGroupAccessible()
    print("📱 App Groups accessible: \(accessible)")
}
```

---

## ✅ Success Indicators

You'll know everything is working when:

- [ ] App launches without errors
- [ ] Widget can be added to home screen
- [ ] Widget displays the word that app is showing
- [ ] Navigating to a new word in app updates widget
- [ ] Heart icon changes state in app
- [ ] No console errors about app group access

---

## 📚 Documentation Files

Reference these for detailed information:

- **APP_GROUPS_SETUP.md** - Detailed setup guide & troubleshooting
- **CODE_EXAMPLES.md** - Code samples and usage patterns
- **IMPLEMENTATION_SUMMARY.md** - Overview of changes made

---

## 🎯 After Setup is Complete

Once everything works, you can:

1. **Add more words** to `MandarinWord.sampleWords`
2. **Customize the widget design** (colors, fonts, layout)
3. **Add quiz mode** to test favorites
4. **Implement statistics** (study streak, favorite count, etc.)
5. **Add audio pronunciation** for pinyin
6. **Create custom word collections** by topic

---

## 📞 If You Need Help

Check these files in order:
1. **APP_GROUPS_SETUP.md** - Most common setup issues
2. **CODE_EXAMPLES.md** - Usage questions
3. **IMPLEMENTATION_SUMMARY.md** - Overview of what was changed

---

## 🚀 Next Commands

```bash
# Open in Xcode
open /Users/justin/repos/LearnMandoWidgets/LearnMandoWidgets.xcodeproj

# Build from command line (if Xcode installed properly)
cd /Users/justin/repos/LearnMandoWidgets
xcodebuild -scheme LearnMandoWidgets -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

**You're all set! 🎉**

The implementation is complete. Follow the checklist above to activate App Groups, then your app and widget will share data seamlessly.
