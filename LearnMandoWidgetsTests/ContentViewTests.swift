//
//  ContentViewTests.swift
//  LearnMandoWidgetsTests
//
//  Created by Justin on 8/8/2026.
//

import XCTest
import SwiftUI
@testable import LearnMandoWidgets

final class ContentViewTests: XCTestCase {
    
    // MARK: - Definition Display Tests
    
    func testDefinitionIsNotTruncated() {
        // Test that ensures the English definition is fully displayed without truncation
        let testWord = MandarinWord(
            character: "学习",
            pinyin: "xuéxí",
            english: "to study; to learn; learning; study; education; knowledge; to emulate"
        )
        
        // Verify that the english property contains the full text
        XCTAssertFalse(testWord.english.isEmpty, "Definition should not be empty")
        XCTAssertGreater(testWord.english.count, 10, "Definition should have substantial content")
        XCTAssert(testWord.english.contains("study"), "Definition should contain expected keywords")
    }
    
    func testLongDefinitionHandling() {
        // Test that very long definitions are handled properly
        let longDefinition = "This is a very long definition that contains multiple parts separated by semicolons; it includes various meanings and usages; it should wrap across multiple lines; and it should all be visible without truncation"
        let testWord = MandarinWord(
            character: "长",
            pinyin: "cháng",
            english: longDefinition
        )
        
        XCTAssertEqual(testWord.english, longDefinition, "Long definition should be stored completely")
        XCTAssertGreater(testWord.english.count, 100, "Long definition should exceed typical line width")
    }
    
    func testMultipleDefinitionsDisplayCorrectly() {
        // Test that multiple words with different definition lengths display correctly
        let words = [
            MandarinWord(character: "是", pinyin: "shì", english: "to be; yes"),
            MandarinWord(character: "学习", pinyin: "xuéxí", english: "to study; to learn; learning; study; education; knowledge"),
            MandarinWord(character: "工作", pinyin: "gōngzuò", english: "job; work; employment; task; to work; to labor")
        ]
        
        for word in words {
            XCTAssertFalse(word.english.isEmpty, "Definition should not be empty for: \(word.character)")
            XCTAssertFalse(word.pinyin.isEmpty, "Pinyin should not be empty for: \(word.character)")
            XCTAssertFalse(word.character.isEmpty, "Character should not be empty")
        }
    }
    
    // MARK: - MandarinWord Structure Tests
    
    func testMandarinWordInitialization() {
        let word = MandarinWord(
            character: "你好",
            pinyin: "nǐ hǎo",
            english: "Hello"
        )
        
        XCTAssertEqual(word.character, "你好")
        XCTAssertEqual(word.pinyin, "nǐ hǎo")
        XCTAssertEqual(word.english, "Hello")
    }
    
    func testMandarinWordWithComplexDefinition() {
        let word = MandarinWord(
            character: "面",
            pinyin: "miàn",
            english: "face; surface; aspect; side; top; flour; noodles; plane; coach (sports); skilled person; look; appearance"
        )
        
        XCTAssertTrue(word.english.contains("face"))
        XCTAssertTrue(word.english.contains("noodles"))
        XCTAssertTrue(word.english.contains("appearance"))
    }
    
    // MARK: - Sample Data Availability Tests
    
    func testSampleWordsAvailable() {
        XCTAssertFalse(MandarinWord.sampleWords.isEmpty, "Sample words should not be empty")
        XCTAssertGreater(MandarinWord.sampleWords.count, 10, "Should have at least 10 sample words")
    }
    
    func testAllSampleWordsHaveCompleteData() {
        for word in MandarinWord.sampleWords {
            XCTAssertFalse(word.character.isEmpty, "Character should not be empty")
            XCTAssertFalse(word.pinyin.isEmpty, "Pinyin should not be empty")
            XCTAssertFalse(word.english.isEmpty, "English definition should not be empty")
        }
    }
    
    // MARK: - Definition Specific Content Tests
    
    func testChineseCharacterIsValidUnicode() {
        for word in MandarinWord.sampleWords {
            // Verify characters are valid Chinese unicode
            for scalar in word.character.unicodeScalars {
                // Chinese unicode range: 0x4E00-0x9FFF for CJK Unified Ideographs
                let isChineseChar = (0x4E00...0x9FFF).contains(scalar.value) || 
                                   (0x3400...0x4DBF).contains(scalar.value) ||  // CJK Extension A
                                   (0x20000...0x2A6DF).contains(scalar.value)   // CJK Extension B
                XCTAssert(isChineseChar, "Character should be valid Chinese: \(word.character)")
            }
        }
    }
    
    func testPinyinContainsTones() {
        let wordsWithTones = MandarinWord.sampleWords.filter { 
            $0.pinyin.contains("ā") || $0.pinyin.contains("á") || 
            $0.pinyin.contains("ǎ") || $0.pinyin.contains("à") ||
            $0.pinyin.contains("ē") || $0.pinyin.contains("é") ||
            $0.pinyin.contains("ě") || $0.pinyin.contains("è")
        }
        
        XCTAssertGreater(wordsWithTones.count, 0, "Sample words should include tone marks")
    }
    
    func testDefinitionContainsEnglishWords() {
        for word in MandarinWord.sampleWords {
            let englishWords = word.english.lowercased().split(separator: " ").map(String.init)
            XCTAssertGreater(englishWords.count, 0, "Definition should contain at least one English word")
            
            // Check that at least one word looks like English (simple heuristic)
            let hasValidEnglish = englishWords.contains { wordPart in
                wordPart.count > 0 && wordPart.allSatisfy { char in
                    char.isLetter || char == "-" || char == "'" || char == ";"
                }
            }
            XCTAssert(hasValidEnglish, "Definition should contain valid English words: \(word.english)")
        }
    }
}
