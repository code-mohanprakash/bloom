//
//  BloomShareSheet.swift
//  BloomHer
//
//  A thin `UIViewControllerRepresentable` wrapper around `UIActivityViewController`
//  that presents the system share sheet with arbitrary items.
//

import SwiftUI
import UIKit

// MARK: - BloomShareSheet

/// A SwiftUI-compatible wrapper around `UIActivityViewController`.
///
/// Present `BloomShareSheet` via `.sheet(isPresented:)` to surface the system
/// share sheet for text, URLs, images, or any other shareable items.
///
/// ```swift
/// @State private var showShareSheet = false
///
/// Button("Share") { showShareSheet = true }
///     .sheet(isPresented: $showShareSheet) {
///         BloomShareSheet(items: ["Check out BloomHer!", URL(string: "https://bloomher.app")!])
///     }
/// ```
public struct BloomShareSheet: UIViewControllerRepresentable {

    // MARK: Configuration

    /// The items to share. May include `String`, `URL`, `UIImage`, or any
    /// type conforming to `UIActivityItemSource`.
    public let items: [Any]

    /// Optional array of `UIActivity` subclasses to include in the share sheet.
    public let applicationActivities: [UIActivity]?

    // MARK: Init

    /// Creates a `BloomShareSheet`.
    ///
    /// - Parameters:
    ///   - items: The shareable items to present.
    ///   - applicationActivities: Optional custom activities. Defaults to `nil`.
    public init(items: [Any], applicationActivities: [UIActivity]? = nil) {
        self.items = items
        self.applicationActivities = applicationActivities
    }

    // MARK: UIViewControllerRepresentable

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: applicationActivities
        )
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No dynamic updates required — the share sheet is presented once and dismissed.
    }
}

// MARK: - Preview

#Preview("Bloom Share Sheet") {
    ShareSheetPreviewContainer()
}

private struct ShareSheetPreviewContainer: View {
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            Text("Tap the button to present the system share sheet.")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            BloomButton("Share BloomHer", style: .primary, icon: BloomIcons.share, isFullWidth: true) {
                showShareSheet = true
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
        .sheet(isPresented: $showShareSheet) {
            BloomShareSheet(items: [
                "I've been tracking my cycle with BloomHer!",
                URL(string: "https://bloomher.app")!
            ])
            .presentationDetents([.medium, .large])
        }
    }
}
