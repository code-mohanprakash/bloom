//
//  PregnancyWeekWidget.swift
//  BloomHerWidget
//
//  Displays the user's current pregnancy week, trimester, baby size,
//  and days remaining until the due date.
//
//  Supports: .systemSmall
//
//  Data source: WidgetDataProvider → App Group UserDefaults
//  Refresh cadence: every 15 minutes (8 entries), new timeline after 2 hours
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PregnancyWeekEntry: TimelineEntry {
    let date: Date
    let data: WidgetPregnancyData
    let isPlaceholder: Bool

    static func placeholder() -> PregnancyWeekEntry {
        PregnancyWeekEntry(date: Date(), data: .placeholder, isPlaceholder: true)
    }
}

// MARK: - Timeline Provider

struct PregnancyWeekProvider: TimelineProvider {

    func placeholder(in context: Context) -> PregnancyWeekEntry {
        .placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (PregnancyWeekEntry) -> Void) {
        let data  = context.isPreview ? .placeholder : WidgetDataProvider.fetchPregnancyData()
        let entry = PregnancyWeekEntry(date: Date(), data: data, isPlaceholder: context.isPreview)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PregnancyWeekEntry>) -> Void) {
        let now  = Date()
        let data = WidgetDataProvider.fetchPregnancyData()

        let entries: [PregnancyWeekEntry] = (0..<8).map { offset in
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: offset * 15,
                to: now
            ) ?? now
            return PregnancyWeekEntry(date: entryDate, data: data, isPlaceholder: false)
        }

        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }
}

// MARK: - Widget View

struct PregnancyWeekWidgetView: View {
    let entry: PregnancyWeekEntry
    @Environment(\.colorScheme) private var colorScheme

    private var data: WidgetPregnancyData { entry.data }
    private var isDark: Bool { colorScheme == .dark }

    // MARK: Colors (hardcoded, self-contained)
    private let roseLight   = Color(widgetHex: "#F4A0B5")
    private let peachLight  = Color(widgetHex: "#F9D5A7")
    private let creamBg     = Color(widgetHex: "#FFF8F5")
    private let darkBg      = Color(widgetHex: "#1E1520")
    private let darkSurface = Color(widgetHex: "#2A1F2E")
    private let textDark    = Color(widgetHex: "#3D2C2E")
    private let textLight   = Color(widgetHex: "#F5EEF0")

    // Trimester-specific tints
    private var trimesterColor: Color {
        switch data.trimester {
        case 1: return Color(widgetHex: "#F4A0B5") // Rose — first trimester
        case 2: return Color(widgetHex: "#F9D5A7") // Peach — second trimester
        default: return Color(widgetHex: "#C7B8EA") // Lavender — third trimester
        }
    }

    private var trimesterColorLight: Color {
        switch data.trimester {
        case 1: return Color(widgetHex: "#FDD6E0")
        case 2: return Color(widgetHex: "#FDEECE")
        default: return Color(widgetHex: "#E8E0F5")
        }
    }

    var body: some View {
        ZStack {
            // Warm gradient background
            backgroundGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Top row: trimester badge
                HStack {
                    trimesterBadge

                    Spacer()

                    // Baby emoji
                    Text("👶")
                        .font(.system(size: 18))
                }

                Spacer(minLength: 6)

                // Week hero
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(data.currentWeek)")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundStyle(isDark ? textLight : textDark)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)

                    VStack(alignment: .leading, spacing: -1) {
                        Text("week")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(isDark ? textLight.opacity(0.6) : textDark.opacity(0.5))
                        Text("of 40")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(isDark ? textLight.opacity(0.4) : textDark.opacity(0.35))
                    }
                    .padding(.bottom, 4)
                }

                Spacer(minLength: 4)

                // Progress bar — weeks progress
                pregnancyProgressBar

                Spacer(minLength: 8)

                // Bottom row: baby size | days until due
                HStack {
                    // Baby size
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Size")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(isDark ? textLight.opacity(0.40) : textDark.opacity(0.35))
                        Text(data.babySize)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(isDark ? textLight.opacity(0.80) : textDark.opacity(0.75))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer()

                    // Days until due
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Due in")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(isDark ? textLight.opacity(0.40) : textDark.opacity(0.35))
                        Text("\(data.daysUntilDue)d")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(trimesterColor)
                    }
                }
            }
            .padding(14)
        }
    }

    // MARK: Trimester Badge

    private var trimesterBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: trimesterIcon)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(trimesterColor)

            Text(data.trimesterLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(trimesterColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(trimesterColor.opacity(isDark ? 0.22 : 0.16))
        )
    }

    private var trimesterIcon: String {
        switch data.trimester {
        case 1: return "1.circle.fill"
        case 2: return "2.circle.fill"
        default: return "3.circle.fill"
        }
    }

    // MARK: Progress Bar

    private var pregnancyProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(isDark ? Color.white.opacity(0.10) : trimesterColor.opacity(0.18))
                    .frame(height: 5)

                // Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [trimesterColor, trimesterColorLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geo.size.width * CGFloat(min(1.0, Double(data.currentWeek) / 40.0)),
                        height: 5
                    )
            }
        }
        .frame(height: 5)
    }

    // MARK: Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: isDark
                ? [Color(widgetHex: "#1E1520"), trimesterColor.opacity(0.20)]
                : [creamBg, trimesterColorLight.opacity(0.60)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Widget Configuration

struct PregnancyWeekWidget: Widget {
    let kind: String = "PregnancyWeekWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PregnancyWeekProvider()) { entry in
            PregnancyWeekWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Pregnancy Week")
        .description("Track your pregnancy progress week by week.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

#Preview("Small — Trimester 1", as: .systemSmall) {
    PregnancyWeekWidget()
} timeline: {
    PregnancyWeekEntry(
        date: .now,
        data: WidgetPregnancyData(
            currentWeek: 8,
            trimester: 1,
            daysUntilDue: 224,
            babySize: "Raspberry",
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
}

#Preview("Small — Trimester 2", as: .systemSmall) {
    PregnancyWeekWidget()
} timeline: {
    PregnancyWeekEntry(
        date: .now,
        data: WidgetPregnancyData(
            currentWeek: 20,
            trimester: 2,
            daysUntilDue: 140,
            babySize: "Banana",
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
}

#Preview("Small — Trimester 3", as: .systemSmall) {
    PregnancyWeekWidget()
} timeline: {
    PregnancyWeekEntry(
        date: .now,
        data: WidgetPregnancyData(
            currentWeek: 36,
            trimester: 3,
            daysUntilDue: 28,
            babySize: "Honeydew",
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
}

#Preview("Small — Placeholder", as: .systemSmall) {
    PregnancyWeekWidget()
} timeline: {
    PregnancyWeekEntry.placeholder()
}
