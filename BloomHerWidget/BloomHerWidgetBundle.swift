//
//  BloomHerWidgetBundle.swift
//  BloomHerWidget
//
//  Entry point for the BloomHer widget extension.
//  Declares all widget contributions for WidgetKit.
//

import WidgetKit
import SwiftUI

@main
struct BloomHerWidgetBundle: WidgetBundle {
    var body: some Widget {
        CycleDayWidget()
        PregnancyWeekWidget()
        WaterIntakeWidget()
    }
}
