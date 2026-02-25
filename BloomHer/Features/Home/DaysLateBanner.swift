//
//  DaysLateBanner.swift
//  BloomHer
//
//  A contextual warning banner shown on the Home screen when the user's
//  predicted period start date has passed without a logged period start.
//

import SwiftUI

// MARK: - DaysLateBanner

/// A menstrual-tinted warning banner that surfaces when a period is overdue.
///
/// The day-count figure gently pulses to draw attention. The banner adopts
/// `BloomBanner` styling conventions — rounded card, colored border, icon —
/// while adding a phase-tinted gradient background and the pulse animation.
///
/// ```swift
/// if let daysLate = viewModel.daysLate, daysLate > 0 {
///     DaysLateBanner(daysLate: daysLate)
/// }
/// ```
struct DaysLateBanner: View {

    // MARK: - Configuration

    /// The number of days past the predicted start date.
    let daysLate: Int

    /// Optional action invoked when the banner is tapped (e.g., navigate to more info).
    var onTap: (() -> Void)? = nil

    // MARK: - Animation State

    @State private var isPulsing: Bool = false

    // MARK: - Body

    var body: some View {
        Button {
            onTap?()
        } label: {
            bannerContent
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            withAnimation(BloomHerTheme.Animation.pulse) {
                isPulsing = true
            }
        }
    }

    // MARK: - Banner Content

    private var bannerContent: some View {
        HStack(alignment: .center, spacing: BloomHerTheme.Spacing.sm) {
            // Pulsing kawaii period icon
            Image(BloomIcons.periodBloodDrop)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
                .animation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: isPulsing
                )

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                HStack(alignment: .firstTextBaseline, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Your period is")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    // Pulsing day count
                    Text("\(daysLate)")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomColors.menstrual)
                        .scaleEffect(isPulsing ? 1.08 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .contentTransition(.numericText())

                    Text("day\(daysLate == 1 ? "" : "s") late")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                Text("Tap to log your period or learn more")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            Spacer(minLength: 0)

            Image(BloomIcons.chevronRight)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(BloomColors.menstrual.opacity(0.6))
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(bannerBackground)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .strokeBorder(BloomColors.menstrual.opacity(0.30), lineWidth: 1)
        )
    }

    // MARK: - Background

    private var bannerBackground: some View {
        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        BloomColors.menstrual.opacity(0.12),
                        BloomColors.menstrual.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - Preview

#Preview("Days Late Banner") {
    VStack(spacing: BloomHerTheme.Spacing.lg) {
        DaysLateBanner(daysLate: 1)
        DaysLateBanner(daysLate: 3)
        DaysLateBanner(daysLate: 7) {
            print("Tapped")
        }
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
