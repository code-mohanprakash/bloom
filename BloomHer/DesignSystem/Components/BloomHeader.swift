//
//  BloomHeader.swift
//  BloomHer
//
//  A reusable section header component with a left-aligned title, an optional
//  subtitle, and an optional trailing action button (e.g. "See All").
//

import SwiftUI

// MARK: - BloomHeader

/// A standardised section header aligned to the leading edge.
///
/// Use `BloomHeader` at the top of content sections to provide consistent
/// titling, optional context text, and a shortcut to a fuller view.
///
/// ```swift
/// BloomHeader(title: "Today's Log", subtitle: "3 symptoms recorded") {
///     NavigationLink("See All") { SymptomHistoryView() }
/// }
///
/// // Title-only variant:
/// BloomHeader(title: "Insights")
/// ```
public struct BloomHeader<TrailingContent: View>: View {

    // MARK: Configuration

    private let title: String
    private let subtitle: String?
    private let trailingContent: TrailingContent?

    // MARK: Init (generic trailing content)

    /// Creates a `BloomHeader` with a custom trailing view.
    ///
    /// - Parameters:
    ///   - title: The section title displayed in headline font.
    ///   - subtitle: Optional supporting text in subheadline font, textSecondary color.
    ///   - trailing: A `@ViewBuilder` closure producing the trailing content.
    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> TrailingContent
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingContent = trailing()
    }

    // MARK: Body

    public var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(title)
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }

            Spacer(minLength: BloomHerTheme.Spacing.sm)

            trailingContent
        }
    }
}

// MARK: - Convenience init (no trailing content)

extension BloomHeader where TrailingContent == EmptyView {

    /// Creates a title-only (or title + subtitle) `BloomHeader` with no trailing content.
    ///
    /// - Parameters:
    ///   - title: The section title.
    ///   - subtitle: Optional subtitle.
    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailingContent = nil
    }
}

// MARK: - Convenience init ("See All" trailing button)

extension BloomHeader where TrailingContent == Button<Text> {

    /// Creates a `BloomHeader` with a "See All" trailing button.
    ///
    /// - Parameters:
    ///   - title: The section title.
    ///   - subtitle: Optional subtitle.
    ///   - seeAllAction: Action executed when "See All" is tapped.
    public init(title: String, subtitle: String? = nil, seeAllAction: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.trailingContent = Button("See All", action: seeAllAction)
            // Styling cannot be applied inline in the convenience init body,
            // so we leave tint to the parent's .tint() — typically primaryRose
            // via .bloomBackground().
    }
}

// MARK: - Preview

#Preview("Bloom Header") {
    VStack(spacing: BloomHerTheme.Spacing.xxl) {
        // Title only
        BloomHeader(title: "Today")
            .padding(.horizontal, BloomHerTheme.Spacing.md)

        // Title + subtitle
        BloomHeader(title: "Cycle Insights", subtitle: "Last 3 months")
            .padding(.horizontal, BloomHerTheme.Spacing.md)

        // Title + See All button
        BloomHeader(title: "Symptoms", subtitle: "4 logged today") {
            Button("See All") { }
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)

        // Title + icon button
        BloomHeader(title: "Appointments") {
            Button {
            } label: {
                Image(BloomIcons.plus)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            }
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
    }
    .padding(.vertical, BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
