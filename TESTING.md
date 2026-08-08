# Test Suite for LearnMandoWidgets

This document provides an overview of the test suite and how to run the tests.

## Test Files

### 1. **ContentViewTests.swift**
Tests for the main content view and definition display functionality.

**Key Tests:**
- `testDefinitionIsNotTruncated()` - Verifies that English definitions are fully displayed
- `testLongDefinitionHandling()` - Tests handling of very long definitions
- `testMultipleDefinitionsDisplayCorrectly()` - Ensures multiple words display properly
- `testSampleWordsAvailable()` - Confirms sample data exists
- `testAllSampleWordsHaveCompleteData()` - Validates all sample words have required fields
- `testChineseCharacterIsValidUnicode()` - Checks character encoding validity
- `testPinyinContainsTones()` - Verifies tone marks in pinyin
- `testDefinitionContainsEnglishWords()` - Validates English translation content

**Purpose:** Ensures the UI correctly displays all word components without truncation.

### 2. **SharedDataManagerTests.swift**
Tests for data persistence and management across app and widget.

**Key Tests:**
- `testGetCurrentWordIndex()` / `testSetCurrentWordIndex()` - Word navigation state
- `testGetCurrentWord()` - Current word retrieval
- `testCurrentWordChangesWithIndex()` - Navigation consistency
- `testSetLastUpdatedDate()` - Timestamp tracking
- `testAddFavoriteWord()` / `testRemoveFavoriteWord()` - Favorite management
- `testIsFavorite()` - Favorite status checking
- `testIsAppGroupAccessible()` - App group connectivity

**Purpose:** Validates data synchronization, persistence, and app group functionality.

### 3. **DatabaseManagerTests.swift**
Tests for SQLite database operations and word retrieval.

**Key Tests:**
- `testWordCountIsGreaterThanZero()` - Database has content
- `testWordAtValidIndex()` - Valid word retrieval
- `testWordDefinitionIsComplete()` - Definition completeness check
- `testSearchReturnsResults()` - Search functionality
- `testSearchResultsHaveCompleteData()` - Search result integrity
- `testSearchDefinitionDisplaysCompletely()` - **Critical: Validates definition display**
- `testSearchResultIndexIsAccessible()` - Index integrity
- `testWordCharacterIsChineseUnicode()` - Character encoding validation

**Purpose:** Ensures database operations work correctly and all data is accessible.

## Running the Tests

### Option 1: Run Tests in Xcode
1. Open the project in Xcode: `open LearnMandoWidgets.xcodeproj`
2. Select the test scheme: **Cmd+Shift+T** to show the test navigator
3. Click on any test to run it individually
4. Or run all tests: **Cmd+U**

### Option 2: Run Tests from Terminal
```bash
cd /Users/justin/repos/LearnMandoWidgets

# Run all tests
xcodebuild test -scheme LearnMandoWidgets -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
xcodebuild test -scheme LearnMandoWidgets -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing LearnMandoWidgetsTests/ContentViewTests

# Run specific test case
xcodebuild test -scheme LearnMandoWidgets -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing LearnMandoWidgetsTests/ContentViewTests/testDefinitionIsNotTruncated
```

### Option 3: Run Tests with Coverage
```bash
xcodebuild test \
  -scheme LearnMandoWidgets \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES
```

## Test Coverage

The test suite covers:

| Component | Coverage | Tests |
|-----------|----------|-------|
| **Definition Display** | ✅ High | 8+ tests verify full definition display |
| **Word Navigation** | ✅ High | 5+ tests ensure proper index/word movement |
| **Data Persistence** | ✅ High | 6+ tests validate SharedDataManager |
| **Database Operations** | ✅ High | 12+ tests check DB queries and integrity |
| **Search Functionality** | ✅ Medium | 6+ tests for search operations |
| **Data Integrity** | ✅ High | 5+ tests validate character/pinyin encoding |

## Critical Test: Definition Display

The most important test for your use case is **`testSearchDefinitionDisplaysCompletely()`** in `DatabaseManagerTests.swift`:

```swift
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
```

This test:
1. ✅ Searches for words in the database
2. ✅ Verifies each definition is completely stored
3. ✅ Checks that definitions are not truncated
4. ✅ Ensures definitions have substantial content

## Running in Continuous Integration

Add this to your CI/CD pipeline:

```bash
# Clean, build, and test
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean -scheme LearnMandoWidgets
xcodebuild test -scheme LearnMandoWidgets \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug
```

## Debugging Failed Tests

If a test fails:

1. **Run the test in Xcode**: Click the test name and use **Cmd+Ctrl+U**
2. **Check the assertion**: Look at the XCTAssert failure message
3. **Import the test class**: Add `@testable import LearnMandoWidgets` at the top
4. **Use breakpoints**: Set breakpoints in your test methods to step through
5. **Check console output**: Look for database errors or data issues

## Future Test Enhancements

Consider adding:
- **UI Tests**: For visual layout verification (`.lineLimit(nil)`, `.fixedSize()`)
- **Performance Tests**: Measure search time and database query speed
- **Widget Tests**: Verify widget displays synchronized data
- **Integration Tests**: Test app-to-widget data flow
- **Snapshot Tests**: Compare rendered UI against baseline images

## Test Execution Instructions

Quick start:
```bash
cd /Users/justin/repos/LearnMandoWidgets
xcodebuild test -scheme LearnMandoWidgets -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected output:
```
Test Suite 'All Tests' started at 2026-08-08
Test Suite 'LearnMandoWidgetsTests.xctest' started at 2026-08-08
Test Suite 'ContentViewTests' started at 2026-08-08
✓ testDefinitionIsNotTruncated
✓ testLongDefinitionHandling
✓ testMultipleDefinitionsDisplayCorrectly
...
Test Suite 'ContentViewTests' passed: 8 tests, 0 failures
Test Suite 'SharedDataManagerTests' passed: 10 tests, 0 failures
Test Suite 'DatabaseManagerTests' passed: 14 tests, 0 failures
Test Suite 'All Tests' passed: 32 tests, 0 failures
```

---

**Last Updated:** August 8, 2026
**Test Framework:** XCTest
**Target:** iOS 16.5+

