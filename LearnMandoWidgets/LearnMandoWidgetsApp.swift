//
//  LearnMandoWidgetsApp.swift
//  LearnMandoWidgets
//
//  Created by Justin  on 27/7/2026.
//

import SwiftUI
import WidgetKit

@main
struct LearnMandoWidgetsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Initialize word index on first app launch
                    let manager = SharedDataManager.shared
                    let hasPreviousIndex = manager.getCurrentWordIndex() > 0 || UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
                    
                    if !hasPreviousIndex {
                        manager.setCurrentWordIndex(0)
                        manager.setLastUpdatedDate()
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        
                        // Force widget timeline reload
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
    }
}
