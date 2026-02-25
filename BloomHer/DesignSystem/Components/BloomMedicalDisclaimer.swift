//
//  BloomMedicalDisclaimer.swift
//  BloomHer
//
//  A reusable disclaimer card informing users that app content is for
//  informational purposes only and is not a substitute for medical advice.
//

import SwiftUI

// MARK: - BloomMedicalDisclaimer

/// A standardised medical disclaimer card for BloomHer.
///
/// Place this component anywhere the app surfaces health-related content that
/// should not be interpreted as clinical advice — cycle predictions, symptom
/// analysis, fertility estimates, etc.
///
/// The card uses a `BloomCard` with an info-color accent bar and includes:
/// - An info SF Symbol icon.
/// - A configurable disclaimer text body.
/// - An optional "Learn More" link.
///
/// ```swift
/// BloomMedicalDisclaimer()
///
/// // Custom text:
/// BloomMedicalDisclaimer(
///     text: "Fertility predictions are estimates only. Consult your doctor.",
///     learnMoreURL: URL(string: "https://bloomher.app/legal")
/// )
/// ```
public struct BloomMedicalDisclaimer: View {

    // MARK: Configuration

    private let text: String
    private let learnMoreURL: URL?

    // MARK: Default disclaimer text

    public static let defaultText = "This information is for general wellness purposes only and is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider with any questions you may have regarding a medical condition."

    // MARK: Init

    /// Creates a `BloomMedicalDisclaimer`.
    ///
    /// - Parameters:
    ///   - text: The disclaimer body copy. Defaults to the standard BloomHer
    ///     medical disclaimer text.
    ///   - learnMoreURL: An optional URL opened when "Learn More" is tapped.
    ///     Pass `nil` to hide the link. Defaults to `nil`.
    public init(
        text: String? = nil,
        learnMoreURL: URL? = nil
    ) {
        self.text = text ?? Self.defaultText
        self.learnMoreURL = learnMoreURL
    }

    // MARK: Body

    public var body: some View {
        BloomCard(hasPhaseBorder: false, elevation: .small) {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                // Info icon
                Image(BloomIcons.info)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BloomHerTheme.Colors.info)
                    .frame(width: 22, height: 22)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text(text)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let url = learnMoreURL {
                        Link(destination: url) {
                            Text("Learn More")
                                .font(BloomHerTheme.Typography.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(BloomHerTheme.Colors.info)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .leading) {
            // Info-colored left accent bar (3pt, rounded)
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                .fill(BloomHerTheme.Colors.info)
                .frame(width: 3)
                .padding(.vertical, BloomHerTheme.Spacing.xs)
                .padding(.leading, BloomHerTheme.Spacing.xxs)
        }
    }
}

// MARK: - Preview

#Preview("Bloom Medical Disclaimer") {
    VStack(spacing: BloomHerTheme.Spacing.lg) {
        // Default disclaimer
        BloomMedicalDisclaimer()

        // With "Learn More" link
        BloomMedicalDisclaimer(
            text: "Fertility window estimates are based on historical data and may not be accurate for everyone. Always confirm with a healthcare professional.",
            learnMoreURL: URL(string: "https://example.com")
        )

        // Short custom text
        BloomMedicalDisclaimer(
            text: "Pregnancy predictions are estimates only. Consult your OB-GYN for confirmation."
        )
    }
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
