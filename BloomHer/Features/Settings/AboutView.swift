//
//  AboutView.swift
//  BloomHer
//
//  App information screen: icon, version, mission statement, and links to
//  Privacy Policy, Terms of Service, and Medical Disclaimer.
//

import SwiftUI

// MARK: - AboutView

/// Displays app information, the privacy-first mission, and external links.
///
/// The "Made with love" footer is a deliberate brand touchpoint that reinforces
/// the app's ethos of care and warmth.
struct AboutView: View {

    // MARK: - Input

    let version: String

    // MARK: - Body

    var body: some View {
        List {
            appHeaderSection
            missionSection
            linksSection
            footerSection
        }
        .bloomBackground()
        .bloomNavigation("About BloomHer")
    }

    // MARK: - App Header Section

    private var appHeaderSection: some View {
        Section {
            VStack(spacing: BloomHerTheme.Spacing.md) {
                // App icon placeholder (uses gradient flower motif)
                ZStack {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xl, style: .continuous)
                        .fill(BloomColors.primaryRose)
                        .frame(width: 90, height: 90)
                        .shadow(color: BloomColors.primaryRose.opacity(0.35), radius: 14, y: 6)
                    Image(BloomIcons.leaf)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                }

                VStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Text("BloomHer")
                        .font(BloomHerTheme.Typography.title1)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Version \(version)")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.lg)
            .listRowBackground(Color.clear)
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Mission Section

    private var missionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Our Mission")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(missionText)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, BloomHerTheme.Spacing.xs)
            .listRowBackground(BloomHerTheme.Colors.surface)
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Links Section

    private var linksSection: some View {
        Section {
            ForEach(externalLinks, id: \.title) { link in
                linkRow(link: link)
            }
        } header: {
            sectionHeader("Legal & Resources")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    private func linkRow(link: ExternalLink) -> some View {
        if let url = URL(string: link.url) {
            return AnyView(
                Link(destination: url) {
                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        Image(link.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .frame(width: 22)
                        Text(link.title)
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Spacer()
                        Image(BloomIcons.externalLink)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
            )
        } else {
            return AnyView(
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(link.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .frame(width: 22)
                    Text(link.title)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                }
            )
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        Section {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Text("Made with love for women's health")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                Text("Copyright 2026 BloomHer. All rights reserved.")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .listRowBackground(Color.clear)
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BloomHerTheme.Typography.footnote)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .textCase(nil)
    }

    // MARK: - Content Data

    private let missionText = """
BloomHer is a privacy-first women's health app designed to help you understand your body throughout every phase of your cycle.

We believe your health data belongs to you — and only you. That's why everything stays on your device by default, with no third-party analytics, no data selling, and no advertising.

Our goal is to give you the confidence that comes from understanding your own patterns, with compassionate, science-backed insights at every stage of your journey.
"""

    private struct ExternalLink {
        let title: String
        let icon:  String
        let url:   String
    }

    private let externalLinks: [ExternalLink] = [
        ExternalLink(title: "Privacy Policy",       icon: BloomIcons.lockShield,    url: "https://bloomher.app/privacy"),
        ExternalLink(title: "Terms of Service",      icon: BloomIcons.document,      url: "https://bloomher.app/terms"),
        ExternalLink(title: "Medical Sources",       icon: BloomIcons.books,         url: "https://bloomher.app/sources"),
        ExternalLink(title: "Support",               icon: BloomIcons.faceSmiling,   url: "https://bloomher.app/support")
    ]
}

// MARK: - Preview

#Preview("About View") {
    NavigationStack {
        AboutView(version: "1.0 (42)")
    }
    .environment(AppDependencies.preview())
}
