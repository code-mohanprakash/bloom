//
//  QuickLogSection.swift
//  BloomHer
//
//  Horizontally-scrolling row of quick-action pill buttons on the Home screen.
//  Each pill carries an SF Symbol icon, a label, and a themed color.
//

import SwiftUI

// MARK: - QuickActionItem

/// A single quick-action descriptor used to drive the scroll row.
private struct QuickActionItem: Identifiable {
    let id: String
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void
}

// MARK: - QuickLogSection

/// A horizontally scrollable row of quick-action chips on the Home screen.
///
/// The set of visible actions adapts to the current cycle state:
/// - Shows **"Log Period"** when no period is active.
/// - Shows **"End Period"** when a period is already in progress.
/// - Always shows **"Log Symptoms"** and **"Quick Log"**.
///
/// ```swift
/// QuickLogSection(
///     isPeriodActive: viewModel.isPeriodActive,
///     showQuickLog:   $viewModel.showQuickLog,
///     showDayDetail:  $viewModel.showDayDetail,
///     onLogPeriod:    { viewModel.logPeriodStart() },
///     onEndPeriod:    { viewModel.endPeriod() }
/// )
/// ```
struct QuickLogSection: View {

    // MARK: - Input

    /// Whether a period is currently active (determines which period action to show).
    let isPeriodActive: Bool

    /// Binding that controls the quick-log sheet presentation.
    @Binding var showQuickLog: Bool

    /// Binding that controls the day-detail sheet presentation.
    @Binding var showDayDetail: Bool

    /// Called when the user taps "Log Period".
    let onLogPeriod: () -> Void

    /// Called when the user taps "End Period".
    let onEndPeriod: () -> Void

    // MARK: - Environment

    @Environment(\.currentCyclePhase) private var phase

    /// Phase accent color used for non-period action buttons.
    private var phaseAccent: Color {
        BloomColors.color(for: phase)
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                ForEach(actions) { item in
                    quickActionChip(for: item)
                }
            }
            .padding(.vertical, BloomHerTheme.Spacing.xxs)
            .padding(.horizontal, BloomHerTheme.Spacing.xxs)
        }
    }

    // MARK: - Chip Builder

    private func quickActionChip(for item: QuickActionItem) -> some View {
        Button {
            BloomHerTheme.Haptics.medium()
            item.action()
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(item.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                Text(item.label)
                    .font(BloomHerTheme.Typography.subheadline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(item.color)
            .clipShape(Capsule())
            .shadow(color: item.color.opacity(0.28), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Actions

    private var actions: [QuickActionItem] {
        var items: [QuickActionItem] = []

        // Period action (contextual)
        if isPeriodActive {
            items.append(QuickActionItem(
                id:     "endPeriod",
                label:  "End Period",
                icon:   BloomIcons.checkmarkCircle,
                color:  BloomColors.menstrual,
                action: onEndPeriod
            ))
        } else {
            items.append(QuickActionItem(
                id:     "logPeriod",
                label:  "Log Period",
                icon:   BloomIcons.drop,
                color:  BloomColors.menstrual,
                action: onLogPeriod
            ))
        }

        // Log symptoms
        items.append(QuickActionItem(
            id:     "logSymptoms",
            label:  "Log Symptoms",
            icon:   BloomIcons.checklist,
            color:  phaseAccent,
            action: { showDayDetail = true }
        ))

        // Quick log (full entry)
        items.append(QuickActionItem(
            id:     "quickLog",
            label:  "Quick Log",
            icon:   BloomIcons.plusCircle,
            color:  phaseAccent,
            action: { showQuickLog = true }
        ))

        // Mood log shortcut
        items.append(QuickActionItem(
            id:     "logMood",
            label:  "Log Mood",
            icon:   BloomIcons.faceSmiling,
            color:  phaseAccent,
            action: { showQuickLog = true }
        ))

        return items
    }
}

// MARK: - Preview

#Preview("Quick Log Section") {
    struct PreviewWrapper: View {
        @State private var showQuickLog = false
        @State private var showDayDetail = false

        var body: some View {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                Text("Period NOT active")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                QuickLogSection(
                    isPeriodActive: false,
                    showQuickLog:   $showQuickLog,
                    showDayDetail:  $showDayDetail,
                    onLogPeriod:    {},
                    onEndPeriod:    {}
                )

                Divider()

                Text("Period ACTIVE")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                QuickLogSection(
                    isPeriodActive: true,
                    showQuickLog:   $showQuickLog,
                    showDayDetail:  $showDayDetail,
                    onLogPeriod:    {},
                    onEndPeriod:    {}
                )
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.background)
        }
    }
    return PreviewWrapper()
}
