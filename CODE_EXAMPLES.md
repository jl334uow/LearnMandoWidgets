# SharedDataManager - Code Examples

This guide shows common usage patterns for the `SharedDataManager` class.

---

## Basic Usage

### Access the Shared Manager

```swift
import SwiftUI

let manager = SharedDataManager.shared
```

---

## Word Management

### Get Current Word

```swift
let currentWord = SharedDataManager.shared.getCurrentWord()
print(currentWord.character)   // 你好
print(currentWord.pinyin)       // nǐ hǎo
print(currentWord.english)      // Hello
```

### Get Current Word Index

```swift
let index = SharedDataManager.shared.getCurrentWordIndex()
print("Current word: \(index + 1) of 24")
```

### Set Specific Word

```swift
// Jump to word at index 5
SharedDataManager.shared.setCurrentWordIndex(5)
```

### Set Random Word

```swift
// Show a random word
SharedDataManager.shared.setRandomWord()
```

---

## Favorites Management

### Add a Favorite

```swift
let word = MandarinWord(character: "你好", pinyin: "nǐ hǎo", english: "Hello")
SharedDataManager.shared.addFavoriteWord(word.character)
```

### Remove a Favorite

```swift
SharedDataManager.shared.removeFavoriteWord("你好")
```

### Check if Word is Favorite

```swift
if SharedDataManager.shared.isFavorite("你好") {
    print("❤️ This is a favorite word")
}
```

### Get All Favorites

```swift
let favorites = SharedDataManager.shared.getFavoriteWords()
for character in favorites {
    print("⭐ \(character)")
}
```

### Toggle Favorite (Common Pattern)

```swift
func toggleFavorite(character: String) {
    let isFavorited = SharedDataManager.shared.isFavorite(character)
    
    if isFavorited {
        SharedDataManager.shared.removeFavoriteWord(character)
    } else {
        SharedDataManager.shared.addFavoriteWord(character)
    }
}
```

---

## Update Tracking

### Record Last Update

```swift
// Use current date
SharedDataManager.shared.setLastUpdatedDate()

// Use specific date
let customDate = Date(timeIntervalSince1970: 0)
SharedDataManager.shared.setLastUpdatedDate(customDate)
```

### Get Last Update

```swift
let lastUpdate = SharedDataManager.shared.getLastUpdatedDate()
print("Last studied: \(lastUpdate)")
```

### Check If Recently Updated

```swift
let lastUpdate = SharedDataManager.shared.getLastUpdatedDate()
let daysSinceUpdate = Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0

if daysSinceUpdate == 0 {
    print("📚 Studied today!")
} else {
    print("⏰ Last studied \(daysSinceUpdate) days ago")
}
```

---

## Integration Examples

### Example 1: ContentView - Heart Button

```swift
struct ContentView: View {
    @State private var currentIndex = 0
    @State private var isFavorite = false
    
    var currentWord: MandarinWord {
        MandarinWord.sampleWords[currentIndex]
    }
    
    var body: some View {
        VStack {
            // ... word display ...
            
            HStack {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .gray)
                }
            }
        }
        .onAppear {
            updateUI()
        }
    }
    
    private func toggleFavorite() {
        if isFavorite {
            SharedDataManager.shared.removeFavoriteWord(currentWord.character)
        } else {
            SharedDataManager.shared.addFavoriteWord(currentWord.character)
        }
        isFavorite.toggle()
    }
    
    private func updateUI() {
        isFavorite = SharedDataManager.shared.isFavorite(currentWord.character)
    }
}
```

### Example 2: Widget - Show App's Current Word

```swift
struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let word = SharedDataManager.shared.getCurrentWord()
        let entry = SimpleEntry(date: Date(), word: word)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let word = SharedDataManager.shared.getCurrentWord()
            let entry = SimpleEntry(date: entryDate, word: word)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}
```

### Example 3: Study Statistics View

```swift
struct StudyStatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            let currentWord = SharedDataManager.shared.getCurrentWord()
            let favorites = SharedDataManager.shared.getFavoriteWords()
            let lastUpdate = SharedDataManager.shared.getLastUpdatedDate()
            
            VStack(alignment: .leading) {
                Text("Current Word")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currentWord.character)
                    .font(.title)
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Favorites")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(favorites.count) words saved")
                    .font(.title)
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Last Studied")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(lastUpdate.formatted(date: .abbreviated, time: .shortened))
                    .font(.title3)
            }
        }
        .padding()
    }
}
```

### Example 4: Filtered Favorites List

```swift
struct FavoritesView: View {
    var body: some View {
        let favorites = SharedDataManager.shared.getFavoriteWords()
        let favoriteWords = MandarinWord.sampleWords.filter { word in
            favorites.contains(word.character)
        }
        
        List(favoriteWords) { word in
            VStack(alignment: .leading) {
                Text(word.character)
                    .font(.title2)
                Text(word.pinyin)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(word.english)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
}
```

---

## Advanced Patterns

### Pattern 1: Reactive Updates with @StateObject

```swift
class StudyManager: ObservableObject {
    @Published var currentWord: MandarinWord
    @Published var isFavorite: Bool = false
    
    let manager = SharedDataManager.shared
    
    init() {
        self.currentWord = manager.getCurrentWord()
        self.isFavorite = manager.isFavorite(currentWord.character)
    }
    
    func nextWord() {
        let nextIndex = (manager.getCurrentWordIndex() + 1) % MandarinWord.sampleWords.count
        manager.setCurrentWordIndex(nextIndex)
        manager.setLastUpdatedDate()
        
        self.currentWord = manager.getCurrentWord()
        self.isFavorite = manager.isFavorite(currentWord.character)
    }
    
    func toggleFavorite() {
        if isFavorite {
            manager.removeFavoriteWord(currentWord.character)
        } else {
            manager.addFavoriteWord(currentWord.character)
        }
        self.isFavorite.toggle()
    }
}

// Usage
struct ContentView: View {
    @StateObject var studyManager = StudyManager()
    
    var body: some View {
        VStack {
            Text(studyManager.currentWord.character)
            
            Button(action: studyManager.toggleFavorite) {
                Image(systemName: studyManager.isFavorite ? "heart.fill" : "heart")
            }
            
            Button("Next", action: studyManager.nextWord)
        }
    }
}
```

### Pattern 2: Error Handling

```swift
func safelyAddFavorite(_ character: String) {
    guard SharedDataManager.shared.isAppGroupAccessible() else {
        print("❌ App Groups not accessible")
        return
    }
    
    if character.isEmpty {
        print("❌ Empty character")
        return
    }
    
    SharedDataManager.shared.addFavoriteWord(character)
    print("✅ Favorite added: \(character)")
}
```

### Pattern 3: Batch Operations

```swift
func importFavorites(_ characters: [String]) {
    for character in characters {
        SharedDataManager.shared.addFavoriteWord(character)
    }
}

func clearAllFavorites() {
    let favorites = SharedDataManager.shared.getFavoriteWords()
    for character in favorites {
        SharedDataManager.shared.removeFavoriteWord(character)
    }
}

func syncFavoritesWithServer(_ serverFavorites: [String]) {
    clearAllFavorites()
    importFavorites(serverFavorites)
}
```

---

## Testing SharedDataManager

```swift
// Test: Add and retrieve favorite
SharedDataManager.shared.addFavoriteWord("你好")
assert(SharedDataManager.shared.isFavorite("你好"))

// Test: Set and get word index
SharedDataManager.shared.setCurrentWordIndex(3)
assert(SharedDataManager.shared.getCurrentWordIndex() == 3)

// Test: Date tracking
SharedDataManager.shared.setLastUpdatedDate()
let retrieved = SharedDataManager.shared.getLastUpdatedDate()
assert(Calendar.current.isDateInToday(retrieved))

print("✅ All tests passed!")
```

---

## Tips & Best Practices

1. **Always use the shared singleton**
   ```swift
   // ✅ Good
   SharedDataManager.shared.getCurrentWord()
   
   // ❌ Avoid
   let manager = SharedDataManager()
   ```

2. **Update tracking date when user studies**
   ```swift
   // When user navigates to a new word
   SharedDataManager.shared.setLastUpdatedDate()
   ```

3. **Check app group accessibility on app launch**
   ```swift
   @main
   struct LearnMandoWidgetsApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
               .onAppear {
                   if !SharedDataManager.shared.isAppGroupAccessible() {
                       print("⚠️ App Groups not configured")
                   }
               }
           }
       }
   }
   ```

4. **Filter without force unwrapping**
   ```swift
   // ✅ Safe
   let favorites = SharedDataManager.shared.getFavoriteWords()
   
   // ❌ Never do this
   let favorites = SharedDataManager.shared.getFavoriteWords()!
   ```

