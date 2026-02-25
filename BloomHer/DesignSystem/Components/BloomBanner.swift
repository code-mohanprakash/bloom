//
//  BloomBanner.swift
//  BloomHer
//
//  An in-app notification banner with four semantic styles (info, success,
//  warning, error), a matching tinted background, icon, and an optional
//  dismiss action.
//

import SwiftUI

// MARK: - BloomBannerStyle

/// The semantic intent of a `BloomBanner`, which controls its icon and tint.
public enum BloomBannerStyle {
    /// Neutral information — blue tint, info circle icon.
    case info
    /// Positive confirmation — green tint, checkmark icon.
    case success
    /// Caution notice — amber tint, exclamationmark triangle icon.
    case warning
    /// Error or destructive alert — rose tint, xmark circle icon.
    case error

    // MARK: Internal tokens

    fileprivate var icon: String {
        switch self {
        case .info:    return BloomIcons.info
        case .success: return BloomIcons.checkmarkCircle
        case .warning: return BloomIcons.warning
        case .error:   return BloomIcons.xmarkCircle
        }
    }

    fileprivate var color: Color {
        switch self {
        case .info:    return BloomHerTheme.Colors.info
        case .success: return BloomHerTheme.Colors.success
        case .warning: return BloomHerTheme.Colors.warning
        case .error:   return BloomHerTheme.Colors.error
        }
    }
}

// MARK: - BloomBanner

/// An in-app notification banner for transient feedback.
///
/// Displays a colored icon, title, optional message, and an optional dismiss
/// button in a horizontally-laid-out card. Use with a conditional modifier or
/// `transition(.move(edge: .top))` for animated entrance/exit.
///
/// ```swift
/// if showBanner {
///     BloomBanner(
///         title: "Sync Complete",
///         message: "Your cycle data is up to date.",
///         style: .success
///     ) {
///         showBanner = false
///     }
///     .transition(.move(edge: .top).combined(with: .opacity))
/// }
/// ```
public struct BloomBanner: View {

    // MARK: Configuration

    private let title: String
    private let message: String?
    private let style: BloomBannerStyle
    private let onDismiss: (() -> Void)?

    // MARK: Init

    /// Creates a `BloomBanner`.
    ///
    /// - Parameters:
    ///   - title: The primary message headline.
    ///   - message: Optional supporting detail text.
    ///   - style: The semantic style controlling color and icon.
    ///   - onDismiss: Optional closure executed when the dismiss button is tapped.
    ///     Pass `nil` to hide the dismiss button.
    public init(
        title: String,
        message: String? = nil,
        style: BloomBannerStyle = .info,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.onDismiss = onDismiss
    }

    // MARK: Body

    public var body: some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
            // Icon
            Image(style.icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(style.color)
                .frame(width: 24, height: 24)

            // Text content
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                if let message {
                    Text(message)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            // Dismiss button
            if let onDismiss {
                Button {
                    onDismiss()
                } label: {
                    Image(BloomIcons.xmark)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .padding(BloomHerTheme.Spacing.xxs)
                }
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(bannerBackground)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .strokeBorder(style.color.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: Background

    private var bannerBackground: some View {
        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
            .fill(style.color.opacity(0.10))
    }
}

// MARK: - Preview

#Preview("Bloom Banner") {
    VStack(spacing: BloomHerTheme.Spacing.md) {
        BloomBanner(
            title: "Sync Complete",
            message: "Your cycle data is up to date.",
            style: .success
        ) { }

        BloomBanner(
            title: "Period Predicted",
            message: "Your next period is expected in 3 days.",
            style: .info
        ) { }

        BloomBanner(
            title: "Low BBT Detected",
            message: "Your temperature dip may indicate ovulation. Log it now.",
            style: .warning
        ) { }

        BloomBanner(
            title: "Sync Failed",
            message: "Unable to connect. Check your internet connection and try again.",
            style: .error
        ) { }

        // No dismiss button, title only
        BloomBanner(title: "Reminder set for 8:00 AM", style: .success)
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
