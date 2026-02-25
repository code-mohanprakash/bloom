//
//  PoseCardView.swift
//  BloomHer
//
//  Reusable card for displaying a single yoga pose. Supports an expandable
//  detail overlay showing full instructions, benefits, and modifications.
//

import SwiftUI

// MARK: - PoseCardView

/// Displays a `YogaPose` as a compact card with expandable full instructions.
///
/// When `isPregnant` and `trimester` are provided the card overlays a
/// safety badge coloured by `SafetyLevel` (safe / modified / avoid).
struct PoseCardView: View {

    // MARK: - Configuration

    let pose: YogaPose
    var isPregnant: Bool = false
    var trimester: Int? = nil
    var holdDuration: Int? = nil   // Override from routine context

    // MARK: - State

    @State private var isExpanded: Bool = false

    // MARK: - Body

    var body: some View {
        BloomCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: 0) {
                // Collapsed header — always visible
                headerRow
                    .padding(BloomHerTheme.Spacing.md)

                // Expandable detail section
                if isExpanded {
                    Divider()
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                    expandedDetail
                        .padding(BloomHerTheme.Spacing.md)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .onTapGesture {
            BloomHerTheme.Haptics.light()
            withAnimation(BloomHerTheme.Animation.standard) {
                isExpanded.toggle()
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            // Pose icon circle
            poseIconCircle

            // Names column
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(pose.name)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                if let sanskrit = pose.sanskritName {
                    Text(sanskrit)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .italic()
                }

                badgeRow
            }

            Spacer()

            // Expand chevron
            Image(BloomIcons.chevronDown)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(BloomHerTheme.Animation.quick, value: isExpanded)
        }
    }

    // MARK: - Icon Circle

    private var poseIconCircle: some View {
        ZStack {
            Circle()
                .fill(difficultyColor.opacity(0.12))
                .frame(width: 50, height: 50)
            Image(BloomIcons.yoga)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }

    // MARK: - Badge Row

    private var badgeRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            // Difficulty
            DifficultyBadge(difficulty: pose.difficulty, size: .small)

            // Duration
            durationBadge

            // Safety (pregnancy)
            if isPregnant {
                pregnancySafetyBadge
            }
        }
    }

    private var durationBadge: some View {
        let seconds = holdDuration ?? pose.defaultHoldDurationSeconds
        let label = seconds >= 60
            ? "\(seconds / 60) min"
            : "\(seconds)s"
        return HStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Image(BloomIcons.timer)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
            Text(label)
        }
        .font(BloomHerTheme.Typography.caption2)
        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        .padding(.horizontal, BloomHerTheme.Spacing.xxs + 2)
        .padding(.vertical, BloomHerTheme.Spacing.xxxs)
        .background(Color.primary.opacity(0.06), in: Capsule())
    }

    @ViewBuilder
    private var pregnancySafetyBadge: some View {
        if let trimester {
            let level = pose.isSafe(forTrimester: trimester)
            HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                Image(BloomIcons.checkmarkShield)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                Text(level.displayName)
            }
            .font(BloomHerTheme.Typography.caption2)
            .foregroundStyle(safetyColor(for: level))
            .padding(.horizontal, BloomHerTheme.Spacing.xxs + 2)
            .padding(.vertical, BloomHerTheme.Spacing.xxxs)
            .background(safetyColor(for: level).opacity(0.12), in: Capsule())
        }
    }

    // MARK: - Expanded Detail

    private var expandedDetail: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
            // Instructions
            if !pose.instructions.isEmpty {
                detailSection(title: "Instructions", icon: BloomIcons.listNumber) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(Array(pose.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                                Text("\(index + 1)")
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .background(BloomHerTheme.Colors.primaryRose, in: Circle())

                                Text(step)
                                    .font(BloomHerTheme.Typography.footnote)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }

            // Benefits
            if !pose.benefits.isEmpty {
                detailSection(title: "Benefits", icon: BloomIcons.sparkles) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        ForEach(pose.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                                Image(BloomIcons.leaf)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                Text(benefit)
                                    .font(BloomHerTheme.Typography.footnote)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
            }

            // Contraindications
            if !pose.contraindications.isEmpty {
                detailSection(title: "Cautions", icon: BloomIcons.warning) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        ForEach(pose.contraindications, id: \.self) { item in
                            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                                Image(BloomIcons.errorCircle)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(BloomHerTheme.Colors.warning)
                                Text(item)
                                    .font(BloomHerTheme.Typography.footnote)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
            }

            // Pregnancy note
            if isPregnant, let trimester, let note = pose.safetyMatrix.notes {
                pregnancyNote(trimester: trimester, note: note)
            }
        }
    }

    private func detailSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text(title)
            }
            .font(BloomHerTheme.Typography.footnote)
            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            content()
        }
    }

    private func pregnancyNote(trimester: Int, note: String) -> some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.heartFilled)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("Pregnancy Note — T\(trimester)")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(note)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
        }
        .padding(BloomHerTheme.Spacing.sm)
        .background(BloomHerTheme.Colors.primaryRose.opacity(0.08), in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small))
    }

    // MARK: - Color Helpers

    private var difficultyColor: Color {
        switch pose.difficulty {
        case .beginner:     return BloomHerTheme.Colors.sageGreen
        case .intermediate: return BloomHerTheme.Colors.accentPeach
        case .advanced:     return BloomHerTheme.Colors.primaryRose
        }
    }

    private func safetyColor(for level: SafetyLevel) -> Color {
        switch level {
        case .safe:     return BloomHerTheme.Colors.success
        case .modified: return BloomHerTheme.Colors.warning
        case .avoid:    return BloomHerTheme.Colors.error
        }
    }
}

// MARK: - Preview

#Preview("Pose Card — Collapsed") {
    if let pose = YogaPoseLibrary.allPoses.first {
        PoseCardView(pose: pose, isPregnant: true, trimester: 2)
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.background)
    }
}

#Preview("Pose Card — Expanded") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ForEach(YogaPoseLibrary.allPoses.prefix(3)) { pose in
                PoseCardView(pose: pose, isPregnant: false)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
}
