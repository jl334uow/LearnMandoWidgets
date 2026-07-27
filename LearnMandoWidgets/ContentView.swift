//
//  ContentView.swift
//  LearnMandoWidgets
//
//  Created by Justin  on 27/7/2026.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var currentIndex = 0
    @State private var isFavorite = false
    
    var currentWord: MandarinWord {
        MandarinWord.sampleWords[currentIndex]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
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
                
                Spacer()
                
                // Word Card
                VStack(spacing: 20) {
                    // Character Display
                    VStack(spacing: 15) {
                        Text("Chinese Character")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(currentWord.character)
                            .font(.system(size: 64, weight: .bold, design: .default))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Pinyin and English
                    VStack(spacing: 12) {
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
        .onAppear {
            updateUI()
        }
        .onChange(of: currentIndex) { _ in
            updateUI()
        }
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
