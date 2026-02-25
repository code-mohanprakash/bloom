//
//  BloomNavigationModifier.swift
//  BloomHer
//
//  A ViewModifier that configures the navigation bar appearance according
//  to the BloomHer design system: themed background color and navigation
//  title. Adapts automatically between light and dark mode.
//
//  Apply via the `.bloomNavigation(_:)` convenience extension on `View`
//  (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - BloomNavigationModifier

/// Applies themed navigation-bar styling and a navigation title.
///
/// In light mode the toolbar background uses the warm cream background color.
/// In dark mode it uses the deep plum dark background, keeping the navigation
/// bar integrated with the app's color scheme rather than defaulting to the
/// system's translucent material.
///
/// ```swift
/// List { ... }
///     .bloomNavigation("Today")
/// ```
public struct BloomNavigationModifier: ViewModifier {

    // MARK: Configuration

    /// The string to display as the navigation title.
    public let title: String

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview

#Preview("Bloom Navigation Modifier") {
    NavigationStack {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.md) {
                ForEach(0..<8) { index in
                    Text("Row \(index + 1)")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(BloomHerTheme.Spacing.md)
                        .background(BloomHerTheme.Colors.surface, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .background(BloomHerTheme.Colors.background)
        .modifier(BloomNavigationModifier(title: "BloomHer"))
    }
}
