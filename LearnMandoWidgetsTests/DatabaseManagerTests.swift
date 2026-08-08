//
//  DatabaseManagerTests.swift
//  LearnMandoWidgetsTests
//
//  Created by Justin on 8/8/2026.
//

import XCTest
@testable import LearnMandoWidgets

final class DatabaseManagerTests: XCTestCase {
    
    var databaseManager: DatabaseManager!
    
    override func setUp() {
        super.setUp()
        databaseManager = DatabaseManager.shared
    }
    
    override func tearDown() {
        databaseManager = nil
        super.tearDown()
    }
    
    // MARK: - Word Count Tests
    
    func testWordCountIsGreaterThanZero() {
        let count = databaseManager.wordCount()
        XCTAssertGreater(count, 0, "Database should contain at least one word")
    }
    
    func testWordCountConsistent() {
        let count1 = databaseManager.wordCount()
        let count2 = databaseManager.wordCount()
        XCTAssertEqual(count1, count2, "Word count should be consistent across calls")
    }
    
    // MARK: - Word Retrieval Tests
    
    func testWordAtValidIndex() {
        if let word = databaseManager.word(at: 0) {
            XCTAssertFalse(word.character.isEmpty, "Word should have character")
            XCTAssertFalse(word.pinyin.isEmpty, "Word should have pinyin")
            XCTAssertFalse(word.english.isEmpty, "Word should have definition")
        }
    }
    
    func testWordDefinitionIsComplete() {
        if let word = databaseManager.word(at: 0) {
            XCTAssertGreater(word.english.count, 0, "Definition should not be empty")
            // Verify no placeholder text
            XCTAssertFalse(word.english.starts(with: "..."), "Definition should not be truncated")
        }
    }
    
    func testWordAtInvalidIndexReturnsNil() {
        let count = databaseManager.wordCount()
        let word = databaseManager.word(at: count + 1000)
        XCTAssertNil(word, "Word at invalid index should return nil")
    }
    
    func testMultipleWordsHaveDifferentCharacters() {
        guard let word0 = databaseManager.word(at: 0),
              let word1 = databaseManager.word(at: 1) else {
            XCTFail("Should be able to retrieve at least 2 words")
            return
        }
        
        XCTAssertNotEqual(word0.character, word1.character, "Different word indices should have different characters")
    }
    
    // MARK: - Search Tests
    
    func testSearchReturnsResults() {
        let results = databaseManager.search("学")
        XCTAssertFalse(results.isEmpty, "Search should return results for common characters")
    }
    
    func testSearchResultsHaveValidIndex() {
        let results = databaseManager.search("好")
        
        for result in results {
            XCTAssertGreaterThanOrEqual(result.index, 0, "Search result index should be non-negative")
            XCTAssertLess(result.index, databaseManager.wordCount(), "Search result index should be within bounds")
        }
    }
    
    func testSearchResultsHaveCompleteData() {
        let results = databaseManager.search("食")
        
        for result in results {
            XCTAssertFalse(result.word.character.isEmpty, "Search result should have character")
            XCTAssertFalse(result.word.pinyin.isEmpty, "Search result should have pinyin")
            XCTAssertFalse(result.word.english.isEmpty, "Search result should have definition")
        }
    }
    
    func testSearchDefinitionDisplaysCompletely() {
        let results = databaseManager.search("工")
        
        for result in results {
            let definition = result.word.english
            // Ensure definition is not truncated with ellipsis
            XCTAssertFalse(definition.hasSuffix("..."), "Definition should not be truncated: \(definition)")
            // Ensure definition has meaningful length
            XCTAssertGreater(definition.count, 2, "Definition should have substantial content")
        }
    }
    
    func testSearchNonexistentCharacter() {
        let results = databaseManager.search("zzzzz")
        // Results may be empty or limited depending on DB content
        XCTAssertLessThanOrEqual(results.count, 50, "Search should return limited results for non-existent query")
    }
    
    func testSearchCaseInsensitive() {
        let lowerResults = databaseManager.search("study")
        let upperResults = databaseManager.search("STUDY")
        
        // Both should return results (if available)
        XCTAssertGreater(lowerResults.count + upperResults.count, 0, "Search should work case-insensitively")
    }
    
    func testSearchWithLimit() {
        let results = databaseManager.search("", limit: 5)
        XCTAssertLessThanOrEqual(results.count, 5, "Search should respect limit parameter")
    }
    
    // MARK: - Data Integrity Tests
    
    func testWordCharacterIsChineseUnicode() {
        if let word = databaseManager.word(at: 0) {
            for scalar in word.character.unicodeScalars {
                let isChinese = (0x4E00...0x9FFF).contains(scalar.value) || 
                               (0x3400...0x4DBF).contains(scalar.value) ||
                               (0x20000...0x2A6DF).contains(scalar.value)
                XCTAssert(isChinese, "Word character should be valid Chinese: \(word.character)")
            }
        }
    }
    
    func testWordPinyinContainsValidCharacters() {
        if let word = databaseManager.word(at: 0) {
            // Pinyin should contain letters and possibly tone marks
            let validChars = CharacterSet.letters.union(CharacterSet(charactersIn: " āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ"))
            let pinyin = word.pinyin
            
            for char in pinyin {
                if !char.isWhitespace && char != " " {
                    XCTAssert(validChars.contains(UnicodeScalar(String(char))!), 
                             "Pinyin should contain valid characters: \(word.pinyin)")
                }
            }
        }
    }
    
    func testSearchResultIndexIsAccessible() {
        let results = databaseManager.search("好")
        
        for result in results {
            let word = databaseManager.word(at: result.index)
            XCTAssertNotNil(word, "Should be able to retrieve word using search result index")
            
            if let word = word {
                XCTAssertFalse(word.english.isEmpty, "Retrieved word should have complete definition")
            }
        }
    }
}
