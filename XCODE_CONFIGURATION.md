# Xcode Project Configuration Verification

This guide helps verify that Xcode is properly linking the entitlements files to both targets.

---

## 🎯 Verify Build Settings

### For Main App Target (LearnMandoWidgets)

1. **Open project in Xcode**
2. **Select LearnMandoWidgets target**
3. **Go to Build Settings tab**
4. **Search for: "Code Sign Entitlements"**

You should see:
```
Code Sign Entitlements: LearnMandoWidgets/LearnMandoWidgets.entitlements
```

If it's empty or wrong:
- Right-click on the file area
- Select "Delete"
- Click "Remove Reference" (not "Delete File")
- Close Xcode
- The `.entitlements` file will still be on disk
- Reopen project
- The entitlements should be properly linked

### For Widget Target (MandoWidget)

Repeat the same steps for **MandoWidget** target.

You should see:
```
Code Sign Entitlements: MandoWidget/MandoWidget.entitlements
```

---

## 🔗 Verify Build Phases

### Main App Target

1. **Select LearnMandoWidgets target**
2. **Go to Build Phases tab**
3. **Look for "Copy Bundle Resources" section**
4. **Expand it**

You should see the file:
```
✓ LearnMandoWidgets.entitlements
```

If missing:
- Click **+** button
- Choose **Add Files**
- Navigate to `LearnMandoWidgets/LearnMandoWidgets.entitlements`
- Add it

### Widget Target

Repeat for **MandoWidget** target's Build Phases.

You should see:
```
✓ MandoWidget.entitlements
```

---

## 📁 Verify Files on Disk

**In Terminal:**

```bash
# Check main app entitlements
file "/Users/justin/repos/LearnMandoWidgets/LearnMandoWidgets/LearnMandoWidgets.entitlements"

# Check widget entitlements
file "/Users/justin/repos/LearnMandoWidgets/MandoWidget/MandoWidget.entitlements"

# Both should show: XML document
```

**Expected output:**
```
/Users/justin/repos/LearnMandoWidgets/LearnMandoWidgets/LearnMandoWidgets.entitlements: XML document text
/Users/justin/repos/LearnMandoWidgets/MandoWidget/MandoWidget.entitlements: XML document text
```

---

## ✅ Final Verification Checklist

- [ ] **LearnMandoWidgets.entitlements exists** in project navigator
- [ ] **MandoWidget.entitlements exists** in project navigator
- [ ] **Main app Build Settings** shows Code Sign Entitlements path
- [ ] **Widget Build Settings** shows Code Sign Entitlements path
- [ ] **Main app Build Phases** includes .entitlements in Copy Bundle Resources
- [ ] **Widget Build Phases** includes .entitlements in Copy Bundle Resources
- [ ] Both files have identical app group id: `group.com.justin.mandowidgets`
- [ ] **Xcode product name matches**:
  - Main target: LearnMandoWidgets
  - Widget target: MandoWidget

---

## 🔧 Complete Step-by-Step Fix

If anything is missing:

### Step 1: Clean Everything

```bash
cd /Users/justin/repos/LearnMandoWidgets

# Close Xcode
# Then:
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf .build
rm -rf build
```

### Step 2: Check Files Exist

```bash
# These MUST exist:
test -f "LearnMandoWidgets/LearnMandoWidgets.entitlements" && echo "✅ Main app entitlements OK" || echo "❌ Missing"
test -f "MandoWidget/MandoWidget.entitlements" && echo "✅ Widget entitlements OK" || echo "❌ Missing"
```

### Step 3: Open in Xcode

```bash
open LearnMandoWidgets.xcodeproj
```

### Step 4: Configure Main App Target

1. Click **LearnMandoWidgets** (project)
2. Click **LearnMandoWidgets** (target)
3. **Signing & Capabilities** tab
4. Look for **App Groups** badge

   If missing:
   - Click **+ Capability**
   - Search **App Groups**
   - Enter: `group.com.justin.mandowidgets`

5. Verify entitlements file is created/linked

### Step 5: Configure Widget Target

1. Click **LearnMandoWidgets** (project)
2. Click **MandoWidget** (target)
3. **Signing & Capabilities** tab
4. Look for **App Groups** badge

   If missing:
   - Click **+ Capability**
   - Search **App Groups**
   - Enter: `group.com.justin.mandowidgets`

5. Verify entitlements file is created/linked

### Step 6: Verify Build Settings

For **LearnMandoWidgets** target:
1. Go to **Build Settings** tab
2. Search: **Code Sign Entitlements**
3. Should show: `LearnMandoWidgets/LearnMandoWidgets.entitlements`

For **MandoWidget** target:
1. Go to **Build Settings** tab
2. Search: **Code Sign Entitlements**
3. Should show: `MandoWidget/MandoWidget.entitlements`

### Step 7: Clean Build

```bash
# In Xcode:
Product → Clean Build Folder (Cmd + Shift + K)

# Then build:
Product → Build (Cmd + B)
```

---

## 🧪 Quick Test After Setup

1. **Run main app** on simulator
   - App should start with "你好"
   - Check console for errors

2. **Add widget** to home screen
   - Long-press home screen
   - Edit home screen
   - Add "Mandarin Word" widget
   - Widget should display word from app

3. **Test sync**
   - In app: tap "Next"
   - On home screen: widget should update
   - If not: wait 15 seconds or tap widget

---

## Common Issues & Fixes

### Issue: "Code Sign Entitlements" field is empty

**Fix:**
1. Remove the target from the project
2. Re-add App Groups capability
3. Clean build folder
4. Rebuild

### Issue: Entitlements file not appearing in project navigator

**Fix:**
1. Right-click in project navigator
2. Select "Add Files to LearnMandoWidgets"
3. Navigate to file location
4. Make sure "Copy items if needed" is checked
5. Select correct target
6. Add

### Issue: Widget building fine but entitlements not recognized

**Fix:**
1. Check the entitlements filename matches target name
   - Main app: `LearnMandoWidgets.entitlements`
   - Widget: `MandoWidget.entitlements`
2. Delete and re-create capability
3. Verify Build Settings Code Sign Entitlements path

### Issue: Two Teams configured differently

**Fix:**
1. Select **LearnMandoWidgets** target
2. **Signing & Capabilities** tab
3. Check **Team** dropdown
4. Select same team for main app and widget

---

## 📸 Screenshots to Check

Take these screenshots to verify setup:

1. **Project Navigator** - showing both .entitlements files
2. **Main app Signing & Capabilities** - showing App Groups
3. **Widget Signing & Capabilities** - showing App Groups
4. **Main app Build Settings** - Code Sign Entitlements value
5. **Widget Build Settings** - Code Sign Entitlements value

---

## 🎯 Success Indicators

✅ Everything is correct when:
- Both `.entitlements` files visible in Xcode navigator
- Both targets show "App Groups" in Signing & Capabilities
- Build Settings show correct entitlements paths
- Project builds without errors
- Widget can be added to home screen
- Widget displays same word as app

---

**After verifying all steps above, do a clean build and test again!**
