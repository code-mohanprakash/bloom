//
//  CycleDayWidget.swift
//  BloomHerWidget
//
//  Displays the user's current cycle day and phase.
//  Supports .systemSmall (circle + day + phase name) and
//  .systemMedium (adds days-until-next-period + progress arc).
//
//  Data source: WidgetDataProvider → App Group UserDefaults
//  Refresh cadence: every 15 minutes (8 entries per timeline)
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CycleDayEntry: TimelineEntry {
    let date: Date
    let data: WidgetCycleData
    let isPlaceholder: Bool

    static func placeholder() -> CycleDayEntry {
        CycleDayEntry(date: Date(), data: .placeholder, isPlaceholder: true)
    }
}

// MARK: - Timeline Provider

struct CycleDayProvider: TimelineProvider {

    func placeholder(in context: Context) -> CycleDayEntry {
        .placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (CycleDayEntry) -> Void) {
        let data  = context.isPreview ? .placeholder : WidgetDataProvider.fetchCycleData()
        let entry = CycleDayEntry(date: Date(), data: data, isPlaceholder: context.isPreview)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CycleDayEntry>) -> Void) {
        let now  = Date()
        let data = WidgetDataProvider.fetchCycleData()

        // Build 8 entries spaced 15 minutes apart so the widget refreshes
        // roughly every 15 minutes while keeping the system battery-friendly.
        let entries: [CycleDayEntry] = (0..<8).map { offset in
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: offset * 15,
                to: now
            ) ?? now
            return CycleDayEntry(date: entryDate, data: data, isPlaceholder: false)
        }

        // After the last entry, ask WidgetKit to refresh the timeline.
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now
        let timeline    = Timeline(entries: entries, policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Small Widget View

private struct CycleDaySmallView: View {
    let entry: CycleDayEntry
    @Environment(\.colorScheme) private var colorScheme

    private var data: WidgetCycleData { entry.data }
    private var phase: WidgetCyclePhase { data.phase }
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        ZStack {
            // Background gradient — phase-tinted
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 4) {
                Spacer(minLength: 0)

                // Phase icon
                Image(systemName: phase.icon)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(isDark ? Color.white.opacity(0.85) : phaseIconColor)

                // Cycle day number — hero
                Text("\(data.cycleDay)")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(isDark ? Color.white : textPrimaryColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                // "Day" label
                Text("Day")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(isDark ? Color.white.opacity(0.6) : textSecondaryColor)

                // Phase name
                Text(phase.displayName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(isDark ? phase.color.opacity(0.9) : phase.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(phase.color.opacity(isDark ? 0.25 : 0.18))
                    )

                Spacer(minLength: 0)
            }
            .padding(12)
        }
    }

    // MARK: Gradient

    private var backgroundGradient: some View {
        LinearGradient(
            colors: isDark
                ? [Color(widgetHex: "#1E1520"), phase.color.opacity(0.25)]
                : [Color(widgetHex: "#FFF8F5"), phase.lightColor.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: Colors

    private var textPrimaryColor: Color { Color(widgetHex: "#3D2C2E") }
    private var textSecondaryColor: Color { Color(widgetHex: "#3D2C2E").opacity(0.55) }
    private var phaseIconColor: Color { phase.color.opacity(0.75) }
}

// MARK: - Medium Widget View

private struct CycleDayMediumView: View {
    let entry: CycleDayEntry
    @Environment(\.colorScheme) private var colorScheme

    private var data: WidgetCycleData { entry.data }
    private var phase: WidgetCyclePhase { data.phase }
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        ZStack {
            // Background
            backgroundGradient
                .ignoresSafeArea()

            HStack(spacing: 0) {
                // Left panel — cycle day + phase
                leftPanel
                    .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(isDark ? Color.white.opacity(0.12) : Color(widgetHex: "#3D2C2E").opacity(0.08))
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // Right panel — progress arc + next period
                rightPanel
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 14)
        }
    }

    // MARK: Left Panel

    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Phase icon + name row
            HStack(spacing: 5) {
                Image(systemName: phase.icon)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(phase.color)

                Text(phase.displayName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(phase.color)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(phase.color.opacity(isDark ? 0.22 : 0.15))
            )

            // Cycle day hero
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(data.cycleDay)")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(isDark ? Color.white : Color(widgetHex: "#3D2C2E"))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text("/ \(data.cycleLength)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(isDark ? Color.white.opacity(0.45) : Color(widgetHex: "#3D2C2E").opacity(0.40))
                    .alignmentGuide(.firstTextBaseline) { $0[.firstTextBaseline] }
            }

            Text(phase.shortDescription)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(isDark ? Color.white.opacity(0.55) : Color(widgetHex: "#3D2C2E").opacity(0.50))
                .lineLimit(1)
        }
        .padding(.leading, 4)
    }

    // MARK: Right Panel

    private var rightPanel: some View {
        VStack(alignment: .center, spacing: 8) {
            // Progress arc
            ZStack {
                // Track
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        isDark ? Color.white.opacity(0.10) : phase.color.opacity(0.18),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Fill
                Circle()
                    .trim(from: 0, to: CGFloat(data.cycleProgress))
                    .stroke(
                        phase.color,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: data.cycleProgress)

                // Inner label
                VStack(spacing: 0) {
                    Text("\(Int(data.cycleProgress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(isDark ? Color.white : Color(widgetHex: "#3D2C2E"))

                    Text("done")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(isDark ? Color.white.opacity(0.45) : Color(widgetHex: "#3D2C2E").opacity(0.45))
                }
            }
            .frame(width: 64, height: 64)

            // Days until next period
            if let daysUntil = data.daysUntilNextPeriod {
                VStack(spacing: 1) {
                    Text("\(daysUntil)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isDark ? Color.white.opacity(0.9) : Color(widgetHex: "#3D2C2E"))

                    Text(daysUntil == 1 ? "day left" : "days left")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(isDark ? Color.white.opacity(0.45) : Color(widgetHex: "#3D2C2E").opacity(0.45))
                }
            } else {
                Text("Tracking...")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(isDark ? Color.white.opacity(0.35) : Color(widgetHex: "#3D2C2E").opacity(0.35))
            }
        }
        .padding(.trailing, 4)
    }

    // MARK: Gradient

    private var backgroundGradient: some View {
        LinearGradient(
            colors: isDark
                ? [Color(widgetHex: "#1E1520"), Color(widgetHex: "#2A1F2E")]
                : [Color(widgetHex: "#FFF8F5"), phase.lightColor.opacity(0.40)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Widget Entry View (dispatcher)

struct CycleDayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CycleDayEntry

    var body: some View {
        switch family {
        case .systemSmall:
            CycleDaySmallView(entry: entry)
        case .systemMedium:
            CycleDayMediumView(entry: entry)
        default:
            CycleDaySmallView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct CycleDayWidget: Widget {
    let kind: String = "CycleDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CycleDayProvider()) { entry in
            CycleDayWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // The widget views handle their own backgrounds via ZStack;
                    // this keeps the system container transparent.
                    Color.clear
                }
        }
        .configurationDisplayName("Cycle Day")
        .description("Track your current cycle day and phase.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews

#Preview("Small — Light", as: .systemSmall) {
    CycleDayWidget()
} timeline: {
    CycleDayEntry(
        date: .now,
        data: WidgetCycleData(
            cycleDay: 5,
            cycleLength: 28,
            phase: .menstrual,
            daysUntilNextPeriod: 23,
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
    CycleDayEntry(
        date: .now,
        data: WidgetCycleData(
            cycleDay: 14,
            cycleLength: 28,
            phase: .follicular,
            daysUntilNextPeriod: 14,
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
    CycleDayEntry(
        date: .now,
        data: WidgetCycleData(
            cycleDay: 16,
            cycleLength: 28,
            phase: .ovulation,
            daysUntilNextPeriod: 12,
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
    CycleDayEntry(
        date: .now,
        data: WidgetCycleData(
            cycleDay: 22,
            cycleLength: 28,
            phase: .luteal,
            daysUntilNextPeriod: 6,
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
}

#Preview("Medium — Light", as: .systemMedium) {
    CycleDayWidget()
} timeline: {
    CycleDayEntry(
        date: .now,
        data: WidgetCycleData(
            cycleDay: 14,
            cycleLength: 28,
            phase: .follicular,
            daysUntilNextPeriod: 14,
            lastUpdated: .now
        ),
        isPlaceholder: false
    )
}

#Preview("Small — Placeholder", as: .systemSmall) {
    CycleDayWidget()
} timeline: {
    CycleDayEntry.placeholder()
}
