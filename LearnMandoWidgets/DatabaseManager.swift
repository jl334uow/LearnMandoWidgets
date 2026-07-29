//
//  DatabaseManager.swift
//  LearnMandoWidgets
//
//  Lightweight SQLite wrapper used by the app to query the provided
//  `hsk_dictionary.sqlite` file. This implementation uses the system
//  SQLite3 C API so it works without adding external Swift packages.
//
//  The file will be copied from the app bundle into the App Group
//  container (if available) so the widget and app can share the same
//  database file. If the App Group container is not available the
//  bundled DB will be used read-only.
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
    // App group identifier should match your SharedDataManager
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
        // Prefer the copy inside the App Group container so widget and app can share the same DB
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let destination = containerURL.appendingPathComponent(fileName)
            if !FileManager.default.fileExists(atPath: destination.path) {
                // Try to copy from the bundle into the group container
                if let bundleURL = Bundle.main.url(forResource: "hsk_dictionary", withExtension: "sqlite") {
                    do {
                        try FileManager.default.copyItem(at: bundleURL, to: destination)
                        print("[DatabaseManager] Copied database to app group container: \(destination.path)")
                    } catch {
                        print("[DatabaseManager] Failed to copy DB to group container: \(error)")
                    }
                } else {
                    print("[DatabaseManager] Bundled database not found in bundle.")
                }
            }

            if sqlite3_open_v2(destination.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                print("[DatabaseManager] Opened DB at group container: \(destination.path)")
                return
            } else {
                print("[DatabaseManager] Failed to open DB at group container: \(destination.path)")
            }
        }

        // Fallback: try to open the bundled DB directly (read-only)
        if let bundleURL = Bundle.main.url(forResource: "hsk_dictionary", withExtension: "sqlite") {
            if sqlite3_open_v2(bundleURL.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                print("[DatabaseManager] Opened bundled DB: \(bundleURL.path)")
            } else {
                print("[DatabaseManager] Failed to open bundled DB at: \(bundleURL.path)")
            }
        } else {
            print("[DatabaseManager] No database found in bundle or app group container.")
        }
    }

    // Return total number of rows in vocabulary table
    func wordCount() -> Int {
        let sql = "SELECT COUNT(*) FROM vocabulary;"
        var stmt: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
        } else {
            print("[DatabaseManager] wordCount prepare failed: \(errorMessage())")
        }
        sqlite3_finalize(stmt)
        return count
    }

    // Fetch a single word by zero-based offset (used to mirror previous array index behavior)
    func word(at index: Int) -> MandarinWord? {
        // Order must match search()'s ROW_NUMBER() ordering so that a search
        // result's offset maps back to the same row here.
        let sql = "SELECT word, pinyin, definition FROM vocabulary ORDER BY CAST(id AS INTEGER) LIMIT 1 OFFSET ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("[DatabaseManager] word(at:) prepare failed: \(errorMessage())")
            return nil
        }
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

    // Search across word, pinyin and definition. Returns results with their zero-based index in the table.
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
        // Fallback: run a simple select and compute offset per-row (slower)
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
                // Compute offset by counting rows with smaller id (assuming numeric id ordering)
                let offset = indexOf(id: idStr)
                results.append(DBSearchResult(index: offset, word: MandarinWord(character: wordC, pinyin: pinyinC, english: definitionC)))
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    // Compute zero-based offset of a given id (assuming id is numeric text)
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

    private func errorMessage() -> String {
        if let db = db, let c = sqlite3_errmsg(db) {
            return String(cString: c)
        }
        return "no db"
    }
}
