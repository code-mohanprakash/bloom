//
//  WaterTrackerView.swift
//  BloomHer
//
//  Dedicated water tracking screen.
//  Features:
//  • Large BloomWaterDrop illustration (300pt) — expression tracks fill level
//  • Current intake / goal display (large numerics)
//  • Quick add buttons: +100ml, +250ml, +500ml
//  • Custom amount entry via alert
//  • Daily progress ring
//  • 7-day bar chart (Swift Charts)
//  • Goal editor
//  • Streak counter for hitting daily goal
//

import SwiftUI
import Charts

// MARK: - WaterTrackerView

struct WaterTrackerView: View {

    // MARK: State

    @Bindable var viewModel: WellnessViewModel
    @State private var showCustomEntry: Bool = false
    @State private var customAmount: String = ""
    @State private var showGoalEditor: Bool = false
    @State private var newGoalText: String = ""
    @State private var weekHistory: [DayWaterEntry] = []
    @State private var showCelebration: Bool = false

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                // Hero drop illustration
                heroSection
                    .staggeredAppear(index: 0)

                // Quick add buttons
                quickAddSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)

                // Progress ring + stats
                progressStatsSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)

                // 7-day chart
                weeklyChartSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 3)

                // Goal setting
                goalSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 4)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Water Tracker")
        .onAppear { buildWeekHistory() }
        .onChange(of: viewModel.waterIntake) { _, newValue in
            if newValue >= viewModel.waterGoal && !showCelebration {
                showCelebration = true
                BloomHerTheme.Haptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCelebration = false
                }
            }
        }
        .overlay {
            if showCelebration {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { showCelebration = false }

                    VStack(spacing: BloomHerTheme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(BloomColors.waterBlueTint.opacity(0.35))
                                .frame(width: 120, height: 120)
                            KawaiiFace(expression: .excited, size: 80)
                        }

                        Text("Goal reached!")
                            .font(BloomHerTheme.Typography.title3)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                        Text("You're blooming beautifully today")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(BloomHerTheme.Spacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xl, style: .continuous)
                            .fill(BloomHerTheme.Colors.surface)
                            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
                    )
                    .padding(.horizontal, BloomHerTheme.Spacing.xl)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
                .animation(BloomHerTheme.Animation.gentle, value: showCelebration)
            }
        }
        .alert("Custom Amount", isPresented: $showCustomEntry) {
            TextField("e.g. 330", text: $customAmount)
                .keyboardType(.numberPad)
            Button("Add") {
                if let ml = Int(customAmount), ml > 0 {
                    viewModel.addWater(ml: ml)
                    buildWeekHistory()
                }
                customAmount = ""
            }
            Button("Cancel", role: .cancel) { customAmount = "" }
        } message: {
            Text("Enter amount in millilitres.")
        }
        .alert("Daily Goal", isPresented: $showGoalEditor) {
            TextField("\(viewModel.waterGoal)", text: $newGoalText)
                .keyboardType(.numberPad)
            Button("Save") {
                if let goal = Int(newGoalText), goal > 0 {
                    viewModel.setWaterGoal(goal)
                }
                newGoalText = ""
            }
            Button("Cancel", role: .cancel) { newGoalText = "" }
        } message: {
            Text("Set your daily water goal in millilitres.")
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            BloomWaterDrop(
                currentMl: viewModel.waterIntake,
                goalMl: viewModel.waterGoal
            )
            .scaleEffect(1.5, anchor: .center)
            .frame(height: 260)

            // Large intake display
            HStack(alignment: .lastTextBaseline, spacing: BloomHerTheme.Spacing.xxs) {
                Text("\(viewModel.waterIntake)")
                    .font(BloomHerTheme.Typography.cycleDay)
                    .foregroundStyle(BloomColors.waterBlue)
                    .contentTransition(.numericText())
                    .animation(BloomHerTheme.Animation.standard, value: viewModel.waterIntake)
                Text("/ \(viewModel.waterGoal) ml")
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            // Streak badge
            if waterStreak > 0 {
                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Image(BloomIcons.flame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("\(waterStreak) day streak")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.vertical, BloomHerTheme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(BloomHerTheme.Colors.accentPeach.opacity(0.15))
                )
            }
        }
    }

    // MARK: - Quick Add

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Add Water")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                waterQuickButton(ml: 100, icon: BloomIcons.drop, label: "Sip")
                waterQuickButton(ml: 250, icon: BloomIcons.drop, label: "Glass")
                waterQuickButton(ml: 500, icon: BloomIcons.hydration, label: "Bottle")
                customButton
            }
        }
    }

    private func waterQuickButton(ml: Int, icon: String, label: String) -> some View {
        Button {
            viewModel.addWater(ml: ml)
            buildWeekHistory()
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text("+\(ml)")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(label)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(BloomColors.waterBlueTint.opacity(0.18))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var customButton: some View {
        Button {
            showCustomEntry = true
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(BloomIcons.plusCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                Text("Custom")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("ml")
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(BloomHerTheme.Colors.accentLavender.opacity(0.12))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Progress Stats

    private var progressFraction: CGFloat {
        let goal = max(viewModel.waterGoal, 1)
        return min(CGFloat(viewModel.waterIntake) / CGFloat(goal), 1.0)
    }

    private var progressPercent: Int {
        Int(progressFraction * 100)
    }

    private var progressStatsSection: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(BloomColors.waterBlueTint.opacity(0.25), lineWidth: 12)
                    .frame(width: 110, height: 110)

                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        LinearGradient(
                            colors: [BloomColors.waterBlueTint, BloomColors.waterBlue],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(BloomHerTheme.Animation.slow, value: viewModel.waterIntake)

                VStack(spacing: 2) {
                    Text("\(progressPercent)%")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomColors.waterBlue)
                    Text("done")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
            }

            // Stats grid
            VStack(spacing: BloomHerTheme.Spacing.sm) {
                waterStatRow(label: "Today", value: "\(viewModel.waterIntake) ml", icon: BloomIcons.drop)
                waterStatRow(label: "Goal", value: "\(viewModel.waterGoal) ml", icon: BloomIcons.target)
                waterStatRow(
                    label: "Remaining",
                    value: "\(max(viewModel.waterGoal - viewModel.waterIntake, 0)) ml",
                    icon: BloomIcons.arrowUpCircle
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xl, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    private func waterStatRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .frame(width: 20)
            Text(label)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(BloomHerTheme.Animation.standard, value: value)
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChartSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Text("Last 7 Days")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Circle()
                            .fill(BloomColors.waterBlue)
                            .frame(width: 8, height: 8)
                        Text("Intake")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Rectangle()
                            .fill(BloomHerTheme.Colors.accentPeach.opacity(0.6))
                            .frame(width: 16, height: 2)
                        Text("Goal")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                Chart {
                    ForEach(weekHistory) { entry in
                        BarMark(
                            x: .value("Day", entry.label),
                            y: .value("ml", entry.ml)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BloomColors.waterBlue, BloomColors.waterBlueTint],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                    }

                    RuleMark(y: .value("Goal", viewModel.waterGoal))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .foregroundStyle(BloomHerTheme.Colors.accentPeach.opacity(0.8))
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let ml = value.as(Int.self) {
                                Text("\(ml / 1000)L")
                                    .font(BloomHerTheme.Typography.caption2)
                                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(BloomHerTheme.Typography.caption2)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Goal Section

    private var goalSection: some View {
        BloomCard {
            HStack {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Daily Goal")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Text("\(viewModel.waterGoal) ml")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }
                Spacer()
                BloomButton("Edit", style: .outline, icon: BloomIcons.edit) {
                    newGoalText = "\(viewModel.waterGoal)"
                    showGoalEditor = true
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Helpers

    private var waterStreak: Int {
        // Count consecutive days where goal was met (mock for now)
        weekHistory.filter { $0.ml >= viewModel.waterGoal }.count
    }

    private func buildWeekHistory() {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        weekHistory = (0..<7).reversed().compactMap { offset -> DayWaterEntry? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: .now)) else { return nil }
            let label = dayFormatter.string(from: date)
            // Today: use the user's actual tracked intake.
            // Past days: show zero — we have no persisted history for prior
            // days, and fabricating random values erodes user trust.
            let ml = offset == 0 ? viewModel.waterIntake : 0
            return DayWaterEntry(id: label + "\(offset)", label: label, ml: ml, date: date)
        }
    }
}

// MARK: - DayWaterEntry

private struct DayWaterEntry: Identifiable {
    let id: String
    let label: String
    let ml: Int
    let date: Date
}

// MARK: - Preview

#Preview("Water Tracker") {
    let deps = AppDependencies.preview()
    let vm = WellnessViewModel(dependencies: deps)
    vm.loadDailyContent()
    return NavigationStack {
        WaterTrackerView(viewModel: vm)
    }
    .environment(\.currentCyclePhase, .follicular)
}
