//
//  WaterIntakeWidget.swift
//  BloomHerWidget
//
//  Displays daily water intake with a circular progress indicator.
//  The fill color transitions from the brand rose toward sage green
//  as the user approaches their daily hydration goal.
//
//  Supports: .systemSmall
//
//  Data source: WidgetDataProvider → App Group UserDefaults
//  Refresh cadence: every 15 minutes (8 entries), new timeline after 2 hours
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct WaterIntakeEntry: TimelineEntry {
    let date: Date
    let data: WidgetWaterData
    let isPlaceholder: Bool

    static func placeholder() -> WaterIntakeEntry {
        WaterIntakeEntry(date: Date(), data: .placeholder, isPlaceholder: true)
    }
}

// MARK: - Timeline Provider

struct WaterIntakeProvider: TimelineProvider {

    func placeholder(in context: Context) -> WaterIntakeEntry {
        .placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterIntakeEntry) -> Void) {
        let data  = context.isPreview ? .placeholder : WidgetDataProvider.fetchWaterData()
        let entry = WaterIntakeEntry(date: Date(), data: data, isPlaceholder: context.isPreview)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterIntakeEntry>) -> Void) {
        let now  = Date()
        let data = WidgetDataProvider.fetchWaterData()

        let entries: [WaterIntakeEntry] = (0..<8).map { offset in
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: offset * 15,
                to: now
            ) ?? now
            return WaterIntakeEntry(date: entryDate, data: data, isPlaceholder: false)
        }

        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }
}

// MARK: - Widget View

struct WaterIntakeWidgetView: View {
    let entry: WaterIntakeEntry
    @Environment(\.colorScheme) private var colorScheme

    private var data: WidgetWaterData { entry.data }
    private var isDark: Bool { colorScheme == .dark }
    private var progress: Double { data.progress }

    // MARK: Hardcoded brand colors (no main-target dependency)

    // Background tones
    private let creamBg     = Color(widgetHex: "#FFF8F5")
    private let darkBg      = Color(widgetHex: "#1E1520")

    // Text
    private let textDark    = Color(widgetHex: "#3D2C2E")
    private let textLight   = Color(widgetHex: "#F5EEF0")

    // Water / progress palette
    private let waterBlue   = Color(widgetHex: "#7EC8E3")
    private let roseBase    = Color(widgetHex: "#F4A0B5")
    private let sageGreen   = Color(widgetHex: "#A8D5BA")

    // MARK: Derived accent color

    /// Transitions from rose (empty) → peach (mid) → sage green (near goal).
    private var progressAccentColor: Color {
        switch progress {
        case 0..<0.33:
            return Color(widgetHex: "#F4A0B5") // rose
        case 0.33..<0.66:
            return Color(widgetHex: "#7EC8E3") // water blue
        case 0.66..<0.90:
            return Color(widgetHex: "#A8D5BA") // sage green
        default:
            return Color(widgetHex: "#5DB890") // deep sage — goal reached
        }
    }

    private var progressAccentColorLight: Color {
        switch progress {
        case 0..<0.33:
            return Color(widgetHex: "#FDD6E0")
        case 0.33..<0.66:
            return Color(widgetHex: "#C4EBF8")
        default:
            return Color(widgetHex: "#D4EDE0")
        }
    }

    // MARK: Body

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Header row
                HStack {
                    Label {
                        Text("Water")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(isDark ? textLight.opacity(0.55) : textDark.opacity(0.50))
                    } icon: {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(progressAccentColor)
                    }

                    Spacer()

                    // Percentage badge
                    if !entry.isPlaceholder {
                        Text(data.percentageText)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(progressAccentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(progressAccentColor.opacity(isDark ? 0.22 : 0.15))
                            )
                    }
                }

                Spacer(minLength: 8)

                // Circular progress indicator
                circularProgress

                Spacer(minLength: 8)

                // Bottom intake / goal row
                intakeRow
            }
            .padding(14)
        }
    }

    // MARK: Circular Progress

    private var circularProgress: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    isDark ? Color.white.opacity(0.08) : progressAccentColor.opacity(0.15),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )

            // Progress arc — drawn clockwise from 12 o'clock
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        colors: [progressAccentColor, progressAccentColorLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 1) {
                Image(systemName: progress >= 1.0 ? "checkmark.circle.fill" : "drop.fill")
                    .font(.system(size: progress >= 1.0 ? 16 : 14, weight: .semibold))
                    .foregroundStyle(
                        progress >= 1.0
                            ? Color(widgetHex: "#5DB890")
                            : progressAccentColor
                    )

                if progress >= 1.0 {
                    Text("Goal!")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(widgetHex: "#5DB890"))
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(isDark ? textLight : textDark)
                }
            }
        }
        // Constrain to a sensible fraction of widget space
        .frame(width: 72, height: 72)
    }

    // MARK: Intake Row

    private var intakeRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            // Current intake
            Text(formattedMl(data.intakeMl))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(isDark ? textLight.opacity(0.90) : textDark)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("ml")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(isDark ? textLight.opacity(0.40) : textDark.opacity(0.35))

            Text("/")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .foregroundStyle(isDark ? textLight.opacity(0.25) : textDark.opacity(0.25))

            // Goal
            Text(formattedMl(data.goalMl))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(isDark ? textLight.opacity(0.50) : textDark.opacity(0.45))
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("ml")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(isDark ? textLight.opacity(0.30) : textDark.opacity(0.25))
        }
    }

    // MARK: Helpers

    private func formattedMl(_ ml: Int) -> String {
        ml >= 1000 ? String(format: "%.1f", Double(ml) / 1000.0) + "L" : "\(ml)"
    }

    // MARK: Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: isDark
                ? [Color(widgetHex: "#1E1520"), progressAccentColor.opacity(0.18)]
                : [creamBg, progressAccentColorLight.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Widget Configuration

struct WaterIntakeWidget: Widget {
    let kind: String = "WaterIntakeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterIntakeProvider()) { entry in
            WaterIntakeWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Water Intake")
        .description("Track your daily water intake and stay hydrated.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

#Preview("Small — Empty", as: .systemSmall) {
    WaterIntakeWidget()
} timeline: {
    WaterIntakeEntry(
        date: .now,
        data: WidgetWaterData(intakeMl: 250, goalMl: 2000, lastUpdated: .now),
        isPlaceholder: false
    )
}

#Preview("Small — Mid Progress", as: .systemSmall) {
    WaterIntakeWidget()
} timeline: {
    WaterIntakeEntry(
        date: .now,
        data: WidgetWaterData(intakeMl: 1000, goalMl: 2000, lastUpdated: .now),
        isPlaceholder: false
    )
}

#Preview("Small — Near Goal", as: .systemSmall) {
    WaterIntakeWidget()
} timeline: {
    WaterIntakeEntry(
        date: .now,
        data: WidgetWaterData(intakeMl: 1750, goalMl: 2000, lastUpdated: .now),
        isPlaceholder: false
    )
}

#Preview("Small — Goal Reached", as: .systemSmall) {
    WaterIntakeWidget()
} timeline: {
    WaterIntakeEntry(
        date: .now,
        data: WidgetWaterData(intakeMl: 2200, goalMl: 2000, lastUpdated: .now),
        isPlaceholder: false
    )
}

#Preview("Small — Placeholder", as: .systemSmall) {
    WaterIntakeWidget()
} timeline: {
    WaterIntakeEntry.placeholder()
}
