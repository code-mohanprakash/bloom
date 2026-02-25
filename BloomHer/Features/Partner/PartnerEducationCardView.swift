//
//  PartnerEducationCardView.swift
//  BloomHer
//
//  Reusable education card component for partner tips and educational content.
//  Expandable for longer content with phase-colored accent.
//

import SwiftUI

// MARK: - PartnerEducationCardView

struct PartnerEducationCardView: View {

    let icon: String
    let title: String
    let contentText: String
    let category: String
    let accentColor: Color

    @State private var isExpanded = false

    init(
        icon: String,
        title: String,
        content: String,
        category: String,
        accentColor: Color
    ) {
        self.icon = icon
        self.title = title
        self.contentText = content
        self.category = category
        self.accentColor = accentColor
    }

    var body: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                // Header
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text(title)
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                        Text(category)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BloomHerTheme.Spacing.xs)
                            .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                            .background(accentColor.opacity(0.8), in: Capsule())
                    }

                    Spacer()

                    Image(BloomIcons.chevronDown)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(BloomHerTheme.Animation.quick, value: isExpanded)
                }

                // Body text
                if isExpanded {
                    Text(contentText)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Text(contentText)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(BloomHerTheme.Animation.standard) {
                isExpanded.toggle()
            }
            BloomHerTheme.Haptics.light()
        }
    }
}

// MARK: - Convenience Initializers

extension PartnerEducationCardView {
    /// Initialize from a `PartnerEducationData.EducationCard`.
    init(card: PartnerEducationData.EducationCard, accentColor: Color = BloomHerTheme.Colors.accentLavender) {
        self.icon = card.icon
        self.title = card.title
        self.contentText = card.body
        self.category = card.category
        self.accentColor = accentColor
    }

    /// Initialize from a `PartnerTip` (from PartnerEducationData).
    init(tip: PartnerTip, accentColor: Color) {
        self.icon = tip.icon
        self.title = tip.title
        self.contentText = tip.description
        self.category = tip.phase?.displayName ?? "General"
        self.accentColor = accentColor
    }
}

// MARK: - Preview

#Preview("Education Card — Expanded") {
    VStack(spacing: BloomHerTheme.Spacing.md) {
        PartnerEducationCardView(
            icon: BloomIcons.calendarCheck,
            title: "The Four Phases",
            content: "A typical menstrual cycle is 21–35 days. It has four phases: menstrual, follicular, ovulation, and luteal. Each phase brings distinct hormonal and physical changes.",
            category: "Basics",
            accentColor: BloomHerTheme.Colors.primaryRose
        )

        PartnerEducationCardView(
            icon: BloomIcons.heartFilled,
            title: "Emotional Support",
            content: "The best support isn't fixing problems — it's listening, validating, and being present. Ask 'What do you need right now?' rather than assuming.",
            category: "Support",
            accentColor: BloomHerTheme.Colors.accentLavender
        )
    }
    .padding()
    .bloomBackground()
}
