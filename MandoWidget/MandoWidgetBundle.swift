//
//  MandoWidgetBundle.swift
//  MandoWidget
//
//  Created by Justin  on 27/7/2026.
//

import WidgetKit
import SwiftUI

@main
struct MandoWidgetBundle: WidgetBundle {
    var body: some Widget {
        MandoWidget()
        MandoWidgetLiveActivity()
    }
}
