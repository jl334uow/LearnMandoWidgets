//
//  ContentView.swift
//  LearnMandoWidgets
//
//  Created by Justin  on 27/7/2026.
//

import SwiftUI
import WidgetKit
import UIKit

struct ContentView: View {
    @State private var currentIndex = 0
    @State private var isFavorite = false
    @State private var searchText: String = ""

    var currentWord: MandarinWord {
        MandarinWord.sampleWords[currentIndex]
    }

    // Normalizes strings by removing diacritics and lowercasing for pinyin/english comparison
    private func normalized(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }

    private struct SearchResult: Identifiable {
        let id: Int
        let word: MandarinWord
    }

    private var searchResults: [SearchResult] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        let qNorm = normalized(query)
        return MandarinWord.sampleWords.enumerated().compactMap { (idx, word) in
            // Match by exact character (Chinese), or normalized pinyin or english
            if word.character.contains(query) { return SearchResult(id: idx, word: word) }
            if normalized(word.pinyin).contains(qNorm) { return SearchResult(id: idx, word: word) }
            if normalized(word.english).contains(qNorm) { return SearchResult(id: idx, word: word) }
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mandarin Learning")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Word \(currentIndex + 1) of \(MandarinWord.sampleWords.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFavorite ? .red : .gray)
                        }
                    }
                    .padding()

                    // Search and results
                    if !searchResults.isEmpty {
                        List {
                            ForEach(searchResults) { result in
                                HStack(spacing: 12) {
                                    Text(result.word.character)
                                        .font(.system(size: 28, weight: .bold))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.word.pinyin)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text(result.word.english)
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectSearchResult(at: result.id)
                                }
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        // Word Card
                        Spacer()

                        VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                Text("Chinese Character")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(currentWord.character)
                                    .font(.system(size: 64, weight: .bold, design: .default))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }

                            Divider()

                            VStack(spacing: 10) {
                                VStack(spacing: 4) {
                                    Text("Pinyin")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(currentWord.pinyin)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }

                                VStack(spacing: 4) {
                                    Text("English")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(currentWord.english)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(25)
                        .background(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)

                        Spacer()

                        // Navigation Buttons
                        HStack(spacing: 15) {
                            Button(action: previousWord) {
                                Label("Previous", systemImage: "chevron.left")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)

                            Button(action: nextWord) {
                                Label("Next", systemImage: "chevron.right")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                        .padding()
                    }
                }
            }
            // Dismiss keyboard when tapping outside interactive elements
            .onTapGesture {
                dismissKeyboard()
            }
            // Dismiss when the user presses the keyboard search/return button
            .onSubmit(of: .search) {
                dismissKeyboard()
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search character, pinyin or English")
            .onAppear {
                updateUI()
            }
            .onChange(of: currentIndex) {
                updateUI()
            }
        }
    }

    private func selectSearchResult(at index: Int) {
        withAnimation {
            currentIndex = index
            // Clear search UI
            searchText = ""
            dismissKeyboard()
            SharedDataManager.shared.setCurrentWordIndex(currentIndex)
            SharedDataManager.shared.setLastUpdatedDate()
            WidgetCenter.shared.reloadAllTimelines()
            updateUI()
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func nextWord() {
        withAnimation {
            currentIndex = (currentIndex + 1) % MandarinWord.sampleWords.count
            SharedDataManager.shared.setCurrentWordIndex(currentIndex)
            SharedDataManager.shared.setLastUpdatedDate()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func previousWord() {
        withAnimation {
            currentIndex = currentIndex == 0 ? MandarinWord.sampleWords.count - 1 : currentIndex - 1
            SharedDataManager.shared.setCurrentWordIndex(currentIndex)
            SharedDataManager.shared.setLastUpdatedDate()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func toggleFavorite() {
        if isFavorite {
            SharedDataManager.shared.removeFavoriteWord(currentWord.character)
        } else {
            SharedDataManager.shared.addFavoriteWord(currentWord.character)
        }
        isFavorite.toggle()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateUI() {
        isFavorite = SharedDataManager.shared.isFavorite(currentWord.character)
    }
}

#Preview {
    ContentView()
}
