//
//  MandoWidget.swift
//  MandoWidget
//
//  Created by Justin  on 27/7/2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let word = MandarinWord.sampleWords.first ?? MandarinWord(character: "你好", pinyin: "nǐ hǎo", english: "Hello")
        return SimpleEntry(date: Date(), word: word)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Use the app's current word from shared data
        let word = SharedDataManager.shared.getCurrentWord()
        let entry = SimpleEntry(date: Date(), word: word)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Get current word from shared data
        let currentWord = SharedDataManager.shared.getCurrentWord()
        let currentDate = Date()
        
        // Create entry for now
        let currentEntry = SimpleEntry(date: currentDate, word: currentWord)
        entries.append(currentEntry)
        
        // Create entries for every 15 minutes for the next 2 hours
        for minuteOffset in stride(from: 15, through: 120, by: 15) {
            if let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate) {
                let word = SharedDataManager.shared.getCurrentWord()
                let entry = SimpleEntry(date: entryDate, word: word)
                entries.append(entry)
            }
        }
        
        // Set timeline to expire in 2 hours, but reload when app changes data
        let timeline = Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: MandarinWord
}

struct MandoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .systemSmall {
            SmallWidgetView(word: entry.word)
        } else if family == .systemMedium {
            MediumWidgetView(word: entry.word)
        } else if family == .accessoryCircular {
            CircularWidgetView(word: entry.word)
        } else if family == .accessoryRectangular {
            RectangularWidgetView(word: entry.word)
        } else if family == .accessoryInline {
            InlineWidgetView(word: entry.word)
        } else {
            Text(entry.word.character)
        }
    }
}

// Small widget - shows character and translation
struct SmallWidgetView: View {
    let word: MandarinWord
    
    var body: some View {
        VStack(spacing: 12) {
            Text(word.character)
                .font(.system(size: 48, weight: .bold, design: .default))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            VStack(spacing: 4) {
                Text(word.pinyin)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(word.english)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// Medium widget - shows character, pinyin, and English with more space
struct MediumWidgetView: View {
    let word: MandarinWord
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(word.character)
                    .font(.system(size: 56, weight: .bold, design: .default))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pinyin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(word.pinyin)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("English")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(word.english)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

// Circular lock screen widget - shows character only
struct CircularWidgetView: View {
    let word: MandarinWord
    
    var body: some View {
        VStack(spacing: 4) {
            Text(word.character)
                .font(.system(size: 36, weight: .bold, design: .default))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .widgetAccentable()
        }
    }
}

// Rectangular lock screen widget - shows character and pinyin
struct RectangularWidgetView: View {
    let word: MandarinWord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(word.character)
                .font(.headline)
                .fontWeight(.bold)
                .widgetAccentable()
            
            Text(word.pinyin)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(word.english)
                .font(.caption2)
                .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Inline lock screen widget - shows character and English
struct InlineWidgetView: View {
    let word: MandarinWord
    
    var body: some View {
        Text("\(word.character) • \(word.english)")
            .widgetAccentable()
    }
}

struct MandoWidget: Widget {
    let kind: String = "MandoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MandoWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MandoWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Mandarin Word")
        .description("A random Mandarin word with pinyin and English translation.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

#Preview(as: .systemSmall) {
    MandoWidget()
} timeline: {
    SimpleEntry(date: .now, word: MandarinWord(character: "你好", pinyin: "nǐ hǎo", english: "Hello"))
    SimpleEntry(date: .now, word: MandarinWord(character: "谢谢", pinyin: "xiè xiè", english: "Thank you"))
}
