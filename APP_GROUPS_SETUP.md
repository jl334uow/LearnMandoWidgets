# App Groups Setup Guide

## Overview
This app uses **App Groups** to share data between the main app and the widget. Both targets read and write to a shared container using `UserDefaults` with the app group identifier `group.com.justin.mandowidgets`.

## Shared Features

### Word Synchronization
- The main app stores the currently viewed word index
- The widget reads this index to display the same word
- Both automatically sync without manual updates

### Favorites Tracking
- The app and widget can both access and modify favorite words
- Changes made in the app appear in the widget and vice versa

### Last Updated Date
- Tracks when words were last reviewed

---

## How to Enable App Groups in Xcode

### Step 1: Add App Groups Capability to Main App Target

1. **Open the project** in Xcode
2. Select **LearnMandoWidgets** (main app target) in the project navigator
3. Go to the **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and select **App Groups**
6. In the App Groups section, enter the identifier: `group.com.justin.mandowidgets`

### Step 2: Add App Groups Capability to Widget Target

1. Select **MandoWidget** (widget target) in the project navigator
2. Go to the **Signing & Capabilities** tab
3. Click **+ Capability**
4. Search for and select **App Groups**
5. Enter the same identifier: `group.com.justin.mandowidgets`

### Step 3: Verify Configuration

- Both targets should now have the App Groups capability with identifier `group.com.justin.mandowidgets`
- The capability will appear as `entitlements` files in your project

---

## How Data Sharing Works

### SharedDataManager Class

The `SharedDataManager` singleton handles all shared data operations:

```swift
// Access the shared manager
let manager = SharedDataManager.shared

// Get/Set current word
let word = manager.getCurrentWord()
manager.setCurrentWordIndex(5)

// Manage favorites
manager.addFavoriteWord("你好")
manager.isFavorite("你好") // true

// Track updates
manager.setLastUpdatedDate()
let lastDate = manager.getLastUpdatedDate()
```

### UserDefaults with App Groups

The manager uses:
```swift
UserDefaults(suiteName: "group.com.justin.mandowidgets")
```

This creates a shared container accessible to both the app and widget.

---

## Data Keys

The following keys are used in the shared container:

| Key | Type | Purpose |
|-----|------|---------|
| `currentWordIndex` | Int | Index of the current word being studied |
| `lastUpdatedDate` | Date | When content was last updated |
| `favoriteWords` | [String] | Array of favorite word characters |

---

## Troubleshooting

### Data Not Syncing Between App and Widget

1. **Verify the app group identifier** is identical in both targets
   - Main app: `Signing & Capabilities` → `App Groups`
   - Widget: `Signing & Capabilities` → `App Groups`
   - Both should show: `group.com.justin.mandowidgets`

2. **Check entitlements files**
   - Look for `.entitlements` files in Xcode
   - Ensure both contain the correct app group identifier

3. **Rebuild the project**
   - Clean build folder: `Cmd + Shift + K`
   - Rebuild: `Cmd + B`

4. **Test on device or simulator**
   - App Groups require proper signing
   - Development team must be the same for both targets

### Widget Not Updating

1. Ensure widget uses `SharedDataManager.shared.getCurrentWord()`
2. Verify the timeline policy is set correctly (`.never` for manual updates)
3. Try restarting the simulator/device

---

## Files Modified/Created

- **LearnMandoWidgets/SharedDataManager.swift** - Main app version
- **MandoWidget/SharedDataManager.swift** - Widget version
- **LearnMandoWidgets/ContentView.swift** - Updated to use SharedDataManager
- **MandoWidget/MandoWidget.swift** - Updated to use SharedDataManager

---

## Creating Entitlements Files (Manual Method)

If the capability isn't automatically creating entitlements files:

1. Right-click the project in Xcode
2. Select **New File...**
3. Choose **Property List**
4. Name it `LearnMandoWidgets.entitlements` for the main app
5. Add the following content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.justin.mandowidgets</string>
    </array>
</dict>
</plist>
```

Do the same for the widget target, naming it `MandoWidget.entitlements`.

---

## Testing Data Sharing

1. **Add a word to favorites in the app**
   - Navigate to a word and tap the heart icon
   
2. **Check if the widget reflects it**
   - Add the widget to home screen
   - The widget will display the current app word
   - Favorites data is accessible

3. **Switch words in the app**
   - Navigate using Next/Previous buttons
   - The widget updates automatically when refreshed

---

## Important Notes

- App Groups require a valid Development Team certificate
- Testing on a physical device is recommended (though simulator works too)
- Changes to the shared container don't trigger automatic widget updates—they update based on the timeline policy
- The current implementation uses `.never` policy, meaning widget updates only when the system requests it (e.g., app reinstall, manual refresh)

