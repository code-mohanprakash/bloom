//
//  WeekByWeekView.swift
//  BloomHer
//
//  Horizontal paged TabView showing development content for all 40 weeks.
//  Each page features a BloomFruitBaby illustration, baby measurements,
//  and bullet-point development highlights, body changes, and tips.
//

import SwiftUI

// MARK: - WeekByWeekView

struct WeekByWeekView: View {

    // MARK: State

    @State private var selectedWeek: Int
    @State private var showJumpToWeek: Bool = false

    // MARK: Init

    init(currentWeek: Int = 1) {
        _selectedWeek = State(wrappedValue: max(1, min(40, currentWeek)))
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            weekHeader
            weekPager
        }
        .bloomBackground()
        .bloomNavigation("Week by Week")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    BloomHerTheme.Haptics.light()
                    showJumpToWeek = true
                } label: {
                    Image(BloomIcons.listNumber)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
        }
        .confirmationDialog("Jump to Week", isPresented: $showJumpToWeek, titleVisibility: .visible) {
            ForEach([4, 8, 12, 16, 20, 24, 28, 32, 36, 40], id: \.self) { week in
                Button("Week \(week)") {
                    withAnimation(BloomHerTheme.Animation.standard) {
                        selectedWeek = week
                    }
                    BloomHerTheme.Haptics.selection()
                }
            }
        }
    }

    // MARK: - Week Header Strip

    private var weekHeader: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(1...40, id: \.self) { week in
                        weekChip(week: week, proxy: proxy)
                            .id(week)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.vertical, BloomHerTheme.Spacing.sm)
            }
            .background(BloomHerTheme.Colors.surface)
            .onChange(of: selectedWeek) { _, newWeek in
                withAnimation(BloomHerTheme.Animation.quick) {
                    proxy.scrollTo(newWeek, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(selectedWeek, anchor: .center)
            }
        }
    }

    private func weekChip(week: Int, proxy: ScrollViewProxy) -> some View {
        let isSelected = week == selectedWeek
        let trimester = weekTrimester(week)
        let color = trimesterColor(trimester)

        return Button {
            withAnimation(BloomHerTheme.Animation.quick) {
                selectedWeek = week
            }
            BloomHerTheme.Haptics.selection()
        } label: {
            Text("W\(week)")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, BloomHerTheme.Spacing.sm)
                .padding(.vertical, BloomHerTheme.Spacing.xxs)
                .background(
                    Capsule().fill(isSelected ? color : color.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
        .animation(BloomHerTheme.Animation.quick, value: selectedWeek)
    }

    // MARK: - Pager

    private var weekPager: some View {
        TabView(selection: $selectedWeek) {
            ForEach(1...40, id: \.self) { week in
                WeekDetailPage(week: week)
                    .tag(week)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(BloomHerTheme.Animation.standard, value: selectedWeek)
        .onChange(of: selectedWeek) { _, _ in
            BloomHerTheme.Haptics.light()
        }
    }

    // MARK: - Helpers

    private func weekTrimester(_ week: Int) -> Int {
        switch week {
        case 1...12: return 1
        case 13...26: return 2
        default: return 3
        }
    }

    private func trimesterColor(_ trimester: Int) -> Color {
        switch trimester {
        case 1: return BloomHerTheme.Colors.primaryRose
        case 2: return BloomHerTheme.Colors.sageGreen
        default: return BloomHerTheme.Colors.accentLavender
        }
    }
}

// MARK: - WeekDetailPage

private struct WeekDetailPage: View {
    let week: Int

    private var trimester: Int {
        switch week {
        case 1...12: return 1
        case 13...26: return 2
        default: return 3
        }
    }

    private var trimesterLabel: String {
        switch trimester {
        case 1: return "First Trimester"
        case 2: return "Second Trimester"
        default: return "Third Trimester"
        }
    }

    private var trimesterColor: Color {
        switch trimester {
        case 1: return BloomHerTheme.Colors.primaryRose
        case 2: return BloomHerTheme.Colors.sageGreen
        default: return BloomHerTheme.Colors.accentLavender
        }
    }

    private var content: PregnancyWeekContent {
        PregnancyWeekData.content(for: week)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                weekBadgeHeader
                fruitBabySection
                measurementRow
                developmentSection
                bodyChangesSection
                tipsSection
                sourceSection
                navigationArrows
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.top, BloomHerTheme.Spacing.md)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
    }

    // MARK: - Week Badge Header

    private var weekBadgeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("Week \(week)")
                    .font(BloomHerTheme.Typography.largeTitle)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(trimesterLabel)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(trimesterColor)
            }

            Spacer()

            // Trimester badge
            Text("T\(trimester)")
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(trimesterColor, in: Circle())
        }
    }

    // MARK: - Fruit Baby

    private var fruitBabySection: some View {
        BloomFruitBaby(week: week, size: 160)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
    }

    // MARK: - Measurements

    private var measurementRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            measurementCard(icon: BloomIcons.figureStand, label: "Length", value: content.babyLength, color: trimesterColor)
            measurementCard(icon: BloomIcons.scales, label: "Weight", value: content.babyWeight, color: trimesterColor)
        }
    }

    private func measurementCard(icon: String, label: String, value: String, color: Color) -> some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(value)
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(label)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Development Highlights

    private var developmentSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                sectionHeader(icon: BloomIcons.sparkles, title: "Baby's Development", color: trimesterColor)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(content.developmentHighlights, id: \.self) { highlight in
                        bulletRow(text: highlight, color: trimesterColor)
                    }
                }
            }
        }
    }

    // MARK: - Body Changes

    private var bodyChangesSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                sectionHeader(icon: BloomIcons.figureStand, title: "Your Body", color: BloomHerTheme.Colors.accentPeach)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(content.bodyChanges, id: \.self) { change in
                        bulletRow(text: change, color: BloomHerTheme.Colors.accentPeach)
                    }
                }
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                sectionHeader(icon: BloomIcons.sparkles, title: "Tips for This Week", color: BloomHerTheme.Colors.sageGreen)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(content.tips, id: \.self) { tip in
                        bulletRow(text: tip, color: BloomHerTheme.Colors.sageGreen, style: .checkmark)
                    }
                }
            }
        }
    }

    private var sourceSection: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            Image(BloomIcons.book)
                .resizable()
                .scaledToFit()
                .frame(width: 11, height: 11)
            Text("Sources: \(content.source)")
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Navigation Arrows

    private var navigationArrows: some View {
        HStack {
            if week > 1 {
                Text("Previous week")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            Spacer()
            if week < 40 {
                Text("Swipe for next week")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, BloomHerTheme.Spacing.xs)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(title)
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
        }
    }

    enum BulletStyle { case dot, checkmark }

    private func bulletRow(text: String, color: Color, style: BulletStyle = .dot) -> some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
            Image(style == .checkmark ? BloomIcons.checkmarkCircle : BloomIcons.checkmark)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: style == .checkmark ? 16 : 8, height: style == .checkmark ? 16 : 8)
                .foregroundStyle(color)
                .padding(.top, style == .checkmark ? 1 : 5)
            Text(text)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview("Week by Week") {
    NavigationStack {
        WeekByWeekView(currentWeek: 20)
    }
}

#Preview("Week by Week — Third Trimester") {
    NavigationStack {
        WeekByWeekView(currentWeek: 36)
    }
}
