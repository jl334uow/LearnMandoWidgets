//
//  SharedDataManagerTests.swift
//  LearnMandoWidgetsTests
//
//  Created by Justin on 8/8/2026.
//

import XCTest
@testable import LearnMandoWidgets

final class SharedDataManagerTests: XCTestCase {
    
    var sharedDataManager: SharedDataManager!
    
    override func setUp() {
        super.setUp()
        sharedDataManager = SharedDataManager.shared
    }
    
    override func tearDown() {
        sharedDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Current Word Index Tests
    
    func testGetCurrentWordIndex() {
        let index = sharedDataManager.getCurrentWordIndex()
        XCTAssertGreaterThanOrEqual(index, 0, "Current word index should be non-negative")
    }
    
    func testSetCurrentWordIndex() {
        let testIndex = 5
        sharedDataManager.setCurrentWordIndex(testIndex)
        let retrievedIndex = sharedDataManager.getCurrentWordIndex()
        XCTAssertEqual(retrievedIndex, testIndex, "Set and retrieved index should match")
    }
    
    func testSetCurrentWordIndexBoundaries() {
        // Test minimum boundary
        sharedDataManager.setCurrentWordIndex(0)
        XCTAssertEqual(sharedDataManager.getCurrentWordIndex(), 0)
        
        // Test larger index
        sharedDataManager.setCurrentWordIndex(100)
        XCTAssertEqual(sharedDataManager.getCurrentWordIndex(), 100)
    }
    
    // MARK: - Current Word Tests
    
    func testGetCurrentWord() {
        sharedDataManager.setCurrentWordIndex(0)
        let word = sharedDataManager.getCurrentWord()
        
        XCTAssertFalse(word.character.isEmpty, "Current word should have character")
        XCTAssertFalse(word.pinyin.isEmpty, "Current word should have pinyin")
        XCTAssertFalse(word.english.isEmpty, "Current word should have definition")
    }
    
    func testCurrentWordChangesWithIndex() {
        sharedDataManager.setCurrentWordIndex(0)
        let word0 = sharedDataManager.getCurrentWord()
        
        sharedDataManager.setCurrentWordIndex(1)
        let word1 = sharedDataManager.getCurrentWord()
        
        XCTAssertNotEqual(word0.character, word1.character, "Different indices should return different words")
    }
    
    // MARK: - Last Updated Date Tests
    
    func testGetLastUpdatedDate() {
        let date = sharedDataManager.getLastUpdatedDate()
        XCTAssertNotNil(date, "Should return a date")
    }
    
    func testSetLastUpdatedDate() {
        let testDate = Date(timeIntervalSince1970: 1000000)
        sharedDataManager.setLastUpdatedDate(testDate)
        let retrievedDate = sharedDataManager.getLastUpdatedDate()
        
        // Allow small time difference due to rounding
        XCTAssertEqual(Int(retrievedDate.timeIntervalSince1970), Int(testDate.timeIntervalSince1970), accuracy: 1)
    }
    
    func testSetLastUpdatedDateDefault() {
        let beforeTime = Date()
        sharedDataManager.setLastUpdatedDate()
        let afterTime = Date()
        let retrievedDate = sharedDataManager.getLastUpdatedDate()
        
        XCTAssert(retrievedDate >= beforeTime && retrievedDate <= afterTime, "Default date should be current time")
    }
    
    // MARK: - Random Word Tests
    
    func testSetRandomWord() {
        sharedDataManager.setRandomWord()
        let index = sharedDataManager.getCurrentWordIndex()
        let word = sharedDataManager.getCurrentWord()
        
        XCTAssertGreaterThanOrEqual(index, 0, "Random index should be non-negative")
        XCTAssertFalse(word.character.isEmpty, "Random word should have character")
    }
    
    // MARK: - Favorite Words Tests
    
    func testGetFavoriteWords() {
        let favorites = sharedDataManager.getFavoriteWords()
        XCTAssertIsNotNil(favorites, "Should return a list of favorites")
    }
    
    func testAddFavoriteWord() {
        let testCharacter = "测试"
        sharedDataManager.removeFavoriteWord(testCharacter) // Clean up first
        
        sharedDataManager.addFavoriteWord(testCharacter)
        let favorites = sharedDataManager.getFavoriteWords()
        
        XCTAssert(favorites.contains(testCharacter), "Favorite word should be added")
    }
    
    func testRemoveFavoriteWord() {
        let testCharacter = "测试"
        sharedDataManager.addFavoriteWord(testCharacter)
        sharedDataManager.removeFavoriteWord(testCharacter)
        let favorites = sharedDataManager.getFavoriteWords()
        
        XCTAssertFalse(favorites.contains(testCharacter), "Favorite word should be removed")
    }
    
    func testAddDuplicateFavoriteWord() {
        let testCharacter = "测试"
        sharedDataManager.removeFavoriteWord(testCharacter)
        
        sharedDataManager.addFavoriteWord(testCharacter)
        sharedDataManager.addFavoriteWord(testCharacter) // Add duplicate
        let favorites = sharedDataManager.getFavoriteWords()
        
        let count = favorites.filter { $0 == testCharacter }.count
        XCTAssertEqual(count, 1, "Duplicate favorite words should not be added")
    }
    
    func testIsFavorite() {
        let testCharacter = "测试"
        sharedDataManager.removeFavoriteWord(testCharacter)
        
        XCTAssertFalse(sharedDataManager.isFavorite(testCharacter), "Word should not be favorite initially")
        
        sharedDataManager.addFavoriteWord(testCharacter)
        XCTAssert(sharedDataManager.isFavorite(testCharacter), "Word should be favorite after adding")
    }
    
    // MARK: - App Group Connectivity Tests
    
    func testIsAppGroupAccessible() {
        let accessible = sharedDataManager.isAppGroupAccessible()
        XCTAssertTrue(accessible, "App group should be accessible when configured properly")
    }
}
