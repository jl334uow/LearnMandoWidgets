//
//  MandoWidgetLiveActivity.swift
//  MandoWidget
//
//  Created by Justin  on 27/7/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MandoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MandoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MandoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MandoWidgetAttributes {
    fileprivate static var preview: MandoWidgetAttributes {
        MandoWidgetAttributes(name: "World")
    }
}

extension MandoWidgetAttributes.ContentState {
    fileprivate static var smiley: MandoWidgetAttributes.ContentState {
        MandoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MandoWidgetAttributes.ContentState {
         MandoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MandoWidgetAttributes.preview) {
   MandoWidgetLiveActivity()
} contentStates: {
    MandoWidgetAttributes.ContentState.smiley
    MandoWidgetAttributes.ContentState.starEyes
}
