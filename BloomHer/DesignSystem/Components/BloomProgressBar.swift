//
//  BloomProgressBar.swift
//  BloomHer
//
//  A themed horizontal progress bar with an animated gradient fill,
//  a capsule track, and an optional percentage label.
//

import SwiftUI

// MARK: - BloomProgressBar

/// A horizontal progress indicator styled with the BloomHer design language.
///
/// The track is a gray-tinted capsule at 15% opacity. The filled portion
/// uses a two-stop gradient from the supplied `color` to a lighter tint,
/// animating whenever `progress` changes.
///
/// ```swift
/// BloomProgressBar(progress: 0.65)
///
/// // With custom color and label:
/// BloomProgressBar(
///     progress: viewModel.cycleProgress,
///     color: BloomHerTheme.Colors.phase(phase),
///     height: 10,
///     showLabel: true
/// )
/// ```
public struct BloomProgressBar: View {

    // MARK: Configuration

    /// Fill ratio from `0.0` (empty) to `1.0` (full).
    public let progress: Double

    /// The color used for the gradient fill. Defaults to `primaryRose`.
    public let color: Color

    /// The track and fill height in points. Defaults to `8`.
    public let height: CGFloat

    /// When `true`, a percentage label is shown to the trailing side of the bar.
    public let showLabel: Bool

    // MARK: Init

    /// Creates a `BloomProgressBar`.
    ///
    /// - Parameters:
    ///   - progress: Fill ratio, clamped to `0...1`.
    ///   - color: Fill gradient base color. Defaults to `primaryRose`.
    ///   - height: Track height in points. Defaults to `8`.
    ///   - showLabel: Whether to show a `"XX%"` label. Defaults to `false`.
    public init(
        progress: Double,
        color: Color = BloomHerTheme.Colors.primaryRose,
        height: CGFloat = 8,
        showLabel: Bool = false
    ) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.height = height
        self.showLabel = showLabel
    }

    // MARK: Body

    public var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            progressTrack
            if showLabel {
                percentageLabel
            }
        }
        .animation(BloomHerTheme.Animation.standard, value: progress)
    }

    // MARK: Track

    private var progressTrack: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: height)

                // Filled portion
                Capsule()
                    .fill(fillGradient)
                    .frame(width: max(geometry.size.width * progress, height), height: height)
            }
        }
        .frame(height: height)
    }

    // MARK: Label

    private var percentageLabel: some View {
        Text("\(Int(progress * 100))%")
            .font(BloomHerTheme.Typography.caption)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .monospacedDigit()
            .frame(width: 36, alignment: .trailing)
    }

    // MARK: Gradient

    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.60)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#Preview("Bloom Progress Bar") {
    VStack(spacing: BloomHerTheme.Spacing.xl) {

        // Default
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            Text("Cycle Day Progress").font(BloomHerTheme.Typography.subheadline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
            BloomProgressBar(progress: 0.65)
        }

        // With label
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            Text("With Percentage Label").font(BloomHerTheme.Typography.subheadline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
            BloomProgressBar(progress: 0.42, showLabel: true)
        }

        // Phase colors
        ForEach(CyclePhase.allCases, id: \.self) { phase in
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                Text(phase.displayName).font(BloomHerTheme.Typography.caption).foregroundStyle(BloomHerTheme.Colors.textSecondary)
                BloomProgressBar(
                    progress: Double.random(in: 0.1...0.9),
                    color: BloomHerTheme.Colors.phase(phase),
                    height: 10,
                    showLabel: true
                )
            }
        }

        // Thick track
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            Text("Thick Track (14pt)").font(BloomHerTheme.Typography.subheadline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
            BloomProgressBar(progress: 0.78, color: BloomHerTheme.Colors.sageGreen, height: 14)
        }
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
