//
//  SharedDataManager.swift
//  LearnMandoWidgets
//
//  Created by Justin on 27/7/2026.
//

import Foundation

/// Manages shared data between the app and widget using App Groups
class SharedDataManager {
    static let shared = SharedDataManager()
    
    // App Group identifier - must match the one configured in Xcode
    private let appGroupIdentifier = "group.com.justin.mandowidgets"
    
    // UserDefaults instance for app group
    private lazy var userDefaults: UserDefaults? = {
        UserDefaults(suiteName: appGroupIdentifier)
    }()
    
    // Keys for storing data
    private let currentWordIndexKey = "currentWordIndex"
    private let lastUpdatedDateKey = "lastUpdatedDate"
    private let favoriteWordsKey = "favoriteWords"
    
    // MARK: - Current Word Management
    
    func getCurrentWordIndex() -> Int {
        guard let defaults = userDefaults else { return 0 }
        return defaults.integer(forKey: currentWordIndexKey)
    }
    
    func setCurrentWordIndex(_ index: Int) {
        guard let defaults = userDefaults else { return }
        defaults.set(index, forKey: currentWordIndexKey)
    }
    
    func getCurrentWord() -> MandarinWord {
        let index = getCurrentWordIndex()
        // Try to fetch from the database (if available). If that fails, fall back to the in-memory sampleWords
        if let dbWord = DatabaseManager.shared.word(at: index) {
            return dbWord
        }
        return MandarinWord.sampleWords[index % MandarinWord.sampleWords.count]
    }
    
    func setRandomWord() {
        // Prefer DB row count if available
        let count = max(1, DatabaseManager.shared.wordCount())
        let randomIndex = Int.random(in: 0..<count)
        setCurrentWordIndex(randomIndex)
    }
    
    // MARK: - Last Updated Date
    
    func getLastUpdatedDate() -> Date {
        guard let defaults = userDefaults else { return Date() }
        return defaults.object(forKey: lastUpdatedDateKey) as? Date ?? Date()
    }
    
    func setLastUpdatedDate(_ date: Date = Date()) {
        guard let defaults = userDefaults else { return }
        defaults.set(date, forKey: lastUpdatedDateKey)
    }
    
    // MARK: - Favorite Words Management
    
    func getFavoriteWords() -> [String] {
        guard let defaults = userDefaults else { return [] }
        return defaults.stringArray(forKey: favoriteWordsKey) ?? []
    }
    
    func addFavoriteWord(_ character: String) {
        guard let defaults = userDefaults else { return }
        var favorites = getFavoriteWords()
        if !favorites.contains(character) {
            favorites.append(character)
            defaults.set(favorites, forKey: favoriteWordsKey)
        }
    }
    
    func removeFavoriteWord(_ character: String) {
        guard let defaults = userDefaults else { return }
        var favorites = getFavoriteWords()
        favorites.removeAll { $0 == character }
        defaults.set(favorites, forKey: favoriteWordsKey)
    }
    
    func isFavorite(_ character: String) -> Bool {
        return getFavoriteWords().contains(character)
    }
    
    // MARK: - Test Connectivity
    
    func isAppGroupAccessible() -> Bool {
        return userDefaults != nil
    }
}
