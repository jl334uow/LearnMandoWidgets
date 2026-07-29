//
//  DatabaseManager.swift
//  MandoWidget
//
//  A copy of the lightweight SQLite wrapper for the widget target.
//  The widget will attempt to open the DB from the App Group container
//  (preferred) and fall back to a bundled copy in the widget bundle.
//

import Foundation
import SQLite3

struct DBSearchResult {
    let index: Int
    let word: MandarinWord
}

final class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let fileName = "hsk_dictionary.sqlite"
    private let appGroupIdentifier = "group.com.justin.mandowidgets"

    private init() {
        openDatabase()
    }

    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }

    private func openDatabase() {
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let destination = containerURL.appendingPathComponent(fileName)
            if sqlite3_open_v2(destination.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                print("[Widget DatabaseManager] Opened DB at group container: \(destination.path)")
                return
            } else {
                print("[Widget DatabaseManager] Failed to open DB at group container: \(destination.path)")
            }
        }

        // Fallback to bundled DB inside the widget bundle
        if let bundleURL = Bundle.main.url(forResource: "hsk_dictionary", withExtension: "sqlite") {
            if sqlite3_open_v2(bundleURL.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                print("[Widget DatabaseManager] Opened bundled DB: \(bundleURL.path)")
            } else {
                print("[Widget DatabaseManager] Failed to open bundled DB at: \(bundleURL.path)")
            }
        } else {
            print("[Widget DatabaseManager] No database found in group container or widget bundle.")
        }
    }

    func wordCount() -> Int {
        let sql = "SELECT COUNT(*) FROM vocabulary;"
        var stmt: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)
        return count
    }

    func word(at index: Int) -> MandarinWord? {
        // Order must match search()'s ROW_NUMBER() ordering so that a search
        // result's offset maps back to the same row here.
        let sql = "SELECT word, pinyin, definition FROM vocabulary ORDER BY CAST(id AS INTEGER) LIMIT 1 OFFSET ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_int(stmt, 1, Int32(index))
        defer { sqlite3_finalize(stmt) }
        if sqlite3_step(stmt) == SQLITE_ROW {
            let wordC = sqlite3_column_text(stmt, 0).flatMap { String(cString: $0) } ?? ""
            let pinyinC = sqlite3_column_text(stmt, 1).flatMap { String(cString: $0) } ?? ""
            let definitionC = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
            return MandarinWord(character: wordC, pinyin: pinyinC, english: definitionC)
        }
        return nil
    }

    func search(_ query: String, limit: Int = 50) -> [DBSearchResult] {
        let pattern = "%" + query + "%"
        // The result's `offset` must be its zero-based position in the FULL table
        // (ordered by CAST(id AS INTEGER)), so it maps back correctly through word(at:).
        // NOTE: ROW_NUMBER() OVER (...) would number only the filtered rows, which is
        // why it previously returned the result-list position instead of the real offset.
        let sqlOffset = "SELECT v.id, v.word, v.pinyin, v.definition, (SELECT COUNT(*) FROM vocabulary v2 WHERE CAST(v2.id AS INTEGER) < CAST(v.id AS INTEGER)) AS offset FROM vocabulary v WHERE v.word LIKE ? OR v.pinyin LIKE ? OR v.definition LIKE ? ORDER BY CAST(v.id AS INTEGER) LIMIT ?;"
        var stmt: OpaquePointer?
        var results: [DBSearchResult] = []
        if sqlite3_prepare_v2(db, sqlOffset, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (pattern as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (pattern as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (pattern as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 4, Int32(limit))

            while sqlite3_step(stmt) == SQLITE_ROW {
                let offset = Int(sqlite3_column_int(stmt, 4))
                let wordC = sqlite3_column_text(stmt, 1).flatMap { String(cString: $0) } ?? ""
                let pinyinC = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
                let definitionC = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) } ?? ""
                results.append(DBSearchResult(index: offset, word: MandarinWord(character: wordC, pinyin: pinyinC, english: definitionC)))
            }
            sqlite3_finalize(stmt)
            return results
        }

        sqlite3_finalize(stmt)
        // Fallback
        let sql = "SELECT id, word, pinyin, definition FROM vocabulary WHERE word LIKE ? OR pinyin LIKE ? OR definition LIKE ? LIMIT ?;"
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (pattern as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (pattern as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (pattern as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 4, Int32(limit))

            while sqlite3_step(stmt) == SQLITE_ROW {
                let idStr = sqlite3_column_text(stmt, 0).flatMap { String(cString: $0) } ?? "0"
                let wordC = sqlite3_column_text(stmt, 1).flatMap { String(cString: $0) } ?? ""
                let pinyinC = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
                let definitionC = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) } ?? ""
                let offset = indexOf(id: idStr)
                results.append(DBSearchResult(index: offset, word: MandarinWord(character: wordC, pinyin: pinyinC, english: definitionC)))
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    private func indexOf(id: String) -> Int {
        let sql = "SELECT COUNT(*) FROM vocabulary WHERE CAST(id AS INTEGER) < CAST(? AS INTEGER);"
        var stmt: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (id as NSString).utf8String, -1, nil)
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)
        return count
    }
}
