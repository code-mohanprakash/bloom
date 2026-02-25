//
//  ContractionTimerView.swift
//  BloomHer
//
//  Contraction timing interface with a pulsing ring animation,
//  5-1-1 rule indicator, interval tracking, and color-coded status.
//

import SwiftUI

// MARK: - ContractionTimerView

struct ContractionTimerView: View {

    // MARK: State

    @State private var viewModel: PregnancyViewModel
    @State private var isTimingContraction: Bool = false
    @State private var currentContraction: ContractionEntry?
    @State private var currentDurationSeconds: Int = 0
    @State private var intervalSeconds: Int? = nil
    @State private var durationTimer: Timer?
    @State private var pulsePhase: Bool = false

    // MARK: Init

    init(viewModel: PregnancyViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: Computed

    private var contractionStatus: ContractionStatus {
        guard !viewModel.recentContractions.isEmpty else { return .early }
        guard let interval = intervalSeconds else { return .early }
        let intervalMinutes = interval / 60
        if intervalMinutes <= 5 { return .transition }
        if intervalMinutes <= 10 { return .active }
        return .early
    }

    private var fiveOneOneTriggered: Bool {
        // 5+ contractions in past hour each <=5 min apart, each lasting >=60 sec
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let recent = viewModel.recentContractions.filter { $0.startTime >= oneHourAgo }
        guard recent.count >= 5 else { return false }
        let longEnough = recent.filter { $0.durationSeconds >= 60 }
        guard longEnough.count >= 5 else { return false }
        // Check spacing
        let sorted = recent.sorted { $0.startTime < $1.startTime }
        for i in 1..<sorted.count {
            let gap = sorted[i].startTime.timeIntervalSince(sorted[i-1].startTime)
            if gap > 5 * 60 { return false }
        }
        return true
    }

    private var durationFormatted: String {
        let minutes = currentDurationSeconds / 60
        let seconds = currentDurationSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var intervalFormatted: String {
        guard let secs = intervalSeconds else { return "--:--" }
        let minutes = secs / 60
        let seconds = secs % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                if fiveOneOneTriggered {
                    hospitalAlertBanner
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }

                pulsingRingSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                timingInfoRow
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                controlButton
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                fiveOneOneCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                contractionHistorySection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Contractions")
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Hospital Alert Banner

    private var hospitalAlertBanner: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.warning)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("5-1-1 Rule Reached")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(.white)
                Text("Consider going to hospital")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer()
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.error, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large))
    }

    // MARK: - Pulsing Ring

    private var pulsingRingSection: some View {
        ZStack {
            // Outer animated ring — expands when timing
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(
                        contractionStatus.color.opacity(0.12 - Double(i) * 0.03),
                        lineWidth: 16 - CGFloat(i * 4)
                    )
                    .frame(width: 280 + CGFloat(i * 30), height: 280 + CGFloat(i * 30))
                    .scaleEffect(isTimingContraction && pulsePhase ? 1.0 + CGFloat(i) * 0.04 : 1.0)
                    .animation(
                        isTimingContraction
                            ? .easeInOut(duration: 1.2 + Double(i) * 0.3).repeatForever(autoreverses: true)
                            : BloomHerTheme.Animation.standard,
                        value: pulsePhase
                    )
            }

            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            contractionStatus.color.opacity(isTimingContraction ? 0.9 : 0.7),
                            contractionStatus.color.opacity(isTimingContraction ? 0.65 : 0.4)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .bloomShadow(
                    BloomShadow(
                        color: contractionStatus.color.opacity(0.3),
                        radius: 16,
                        x: 0,
                        y: 8
                    )
                )

            // Center content
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                if isTimingContraction {
                    Text(durationFormatted)
                        .font(BloomHerTheme.Typography.cycleDay)
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("Timing contraction")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                } else {
                    Image(BloomIcons.timer)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    Text(viewModel.recentContractions.isEmpty ? "Tap Start" : "Tap to Time")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(height: 320)
        .animation(BloomHerTheme.Animation.standard, value: contractionStatus)
    }

    // MARK: - Timing Info Row

    private var timingInfoRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            timingCard(
                label: "Duration",
                value: isTimingContraction ? durationFormatted : formattedLastDuration(),
                icon: BloomIcons.clock,
                color: contractionStatus.color
            )

            timingCard(
                label: "Interval",
                value: intervalFormatted,
                icon: BloomIcons.swap,
                color: BloomHerTheme.Colors.accentLavender
            )

            timingCard(
                label: "Count",
                value: "\(viewModel.recentContractions.count)",
                icon: BloomIcons.listNumber,
                color: BloomHerTheme.Colors.accentPeach
            )
        }
    }

    private func timingCard(label: String, value: String, icon: String, color: Color) -> some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(value)
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(label)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Control Button

    private var controlButton: some View {
        BloomButton(
            isTimingContraction ? "Stop Contraction" : "Start Contraction",
            style: isTimingContraction ? .danger : .primary,
            icon: isTimingContraction ? BloomIcons.stopCircle : BloomIcons.play,
            isFullWidth: true,
            action: toggleContraction
        )
    }

    // MARK: - 5-1-1 Card

    private var fiveOneOneCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.firstAid)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("The 5-1-1 Rule")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                ruleRow(
                    number: "5",
                    title: "Minutes apart",
                    detail: "Contractions coming every 5 minutes",
                    met: contractionStatus == .transition || contractionStatus == .active
                )

                ruleRow(
                    number: "1",
                    title: "Minute long",
                    detail: "Each contraction lasting about 60 seconds",
                    met: (viewModel.recentContractions.first?.durationSeconds ?? 0) >= 60
                )

                ruleRow(
                    number: "1",
                    title: "Hour duration",
                    detail: "This pattern persisting for at least 1 hour",
                    met: fiveOneOneTriggered
                )

                Text("When all three conditions are met, contact your midwife or go to hospital.")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .padding(.top, BloomHerTheme.Spacing.xxs)
            }
        }
    }

    private func ruleRow(number: String, title: String, detail: String, met: Bool) -> some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
            Text(number)
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(met ? BloomHerTheme.Colors.sageGreen : BloomHerTheme.Colors.textTertiary, in: Circle())

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(detail)
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            Spacer()

            if met {
                Image(BloomIcons.checkmarkCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BloomHerTheme.Colors.sageGreen)
            }
        }
        .animation(BloomHerTheme.Animation.standard, value: met)
    }

    // MARK: - Contraction History

    private var contractionHistorySection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Contraction Log")

            if viewModel.recentContractions.isEmpty {
                BloomCard {
                    HStack {
                        Image(BloomIcons.timer)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("No contractions recorded yet")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(viewModel.recentContractions.prefix(10)) { contraction in
                        ContractionRow(
                            contraction: contraction,
                            interval: computeInterval(for: contraction)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func toggleContraction() {
        if isTimingContraction {
            stopContraction()
        } else {
            startContraction()
        }
    }

    private func startContraction() {
        let entry = ContractionEntry(pregnancy: viewModel.pregnancyProfile)
        currentContraction = entry
        currentDurationSeconds = 0
        isTimingContraction = true
        pulsePhase = true

        durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentDurationSeconds += 1
        }
        BloomHerTheme.Haptics.medium()
    }

    private func stopContraction() {
        guard let entry = currentContraction else { return }
        entry.endTime = Date()
        viewModel.saveContraction(entry)

        // Compute interval from last completed contraction
        let lastCompleted = viewModel.recentContractions.first(where: { $0.endTime != nil })
        if let last = lastCompleted {
            intervalSeconds = Int(entry.startTime.timeIntervalSince(last.startTime))
        }

        isTimingContraction = false
        pulsePhase = false
        currentContraction = nil
        stopTimer()
        BloomHerTheme.Haptics.success()
    }

    private func stopTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }

    private func formattedLastDuration() -> String {
        guard let last = viewModel.recentContractions.first else { return "--:--" }
        let secs = last.durationSeconds
        return String(format: "%02d:%02d", secs / 60, secs % 60)
    }

    private func computeInterval(for contraction: ContractionEntry) -> Int? {
        let sorted = viewModel.recentContractions.sorted { $0.startTime > $1.startTime }
        guard let index = sorted.firstIndex(where: { $0.id == contraction.id }),
              index + 1 < sorted.count else { return nil }
        let next = sorted[index + 1]
        return Int(contraction.startTime.timeIntervalSince(next.startTime))
    }
}

// MARK: - ContractionStatus

private enum ContractionStatus {
    case early, active, transition

    var color: Color {
        switch self {
        case .early:      return BloomHerTheme.Colors.sageGreen
        case .active:     return BloomHerTheme.Colors.accentPeach
        case .transition: return BloomHerTheme.Colors.error
        }
    }

    var label: String {
        switch self {
        case .early:      return "Early Labour"
        case .active:     return "Active Labour"
        case .transition: return "Transition"
        }
    }
}

// MARK: - ContractionRow

private struct ContractionRow: View {
    let contraction: ContractionEntry
    let interval: Int?

    private var statusColor: Color {
        guard let mins = interval.map({ $0 / 60 }) else { return BloomHerTheme.Colors.sageGreen }
        if mins <= 5 { return BloomHerTheme.Colors.error }
        if mins <= 10 { return BloomHerTheme.Colors.accentPeach }
        return BloomHerTheme.Colors.sageGreen
    }

    private var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: contraction.startTime)
    }

    private var durationFormatted: String {
        let secs = contraction.durationSeconds
        return "\(secs)s"
    }

    private var intervalFormatted: String {
        guard let secs = interval else { return "--" }
        let mins = secs / 60
        let rem = secs % 60
        return "\(mins)m \(rem)s"
    }

    var body: some View {
        BloomCard {
            HStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                    .fill(statusColor)
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(timeFormatted)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Duration: \(durationFormatted)")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                Spacer()

                if interval != nil {
                    VStack(alignment: .trailing, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Interval")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        Text(intervalFormatted)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(statusColor)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Contraction Timer") {
    NavigationStack {
        ContractionTimerView(viewModel: PregnancyViewModel(repository: PreviewContractionRepo()))
    }
}

private class PreviewContractionRepo: PregnancyRepositoryProtocol {
    func fetchActivePregnancy() -> PregnancyProfile? { nil }
    func fetchAllPregnancies() -> [PregnancyProfile] { [] }
    func savePregnancy(_ pregnancy: PregnancyProfile) {}
    func deletePregnancy(_ pregnancy: PregnancyProfile) {}
    func fetchKickSessions(for pregnancy: PregnancyProfile) -> [KickSession] { [] }
    func saveKickSession(_ session: KickSession) {}
    func fetchContractions(for pregnancy: PregnancyProfile) -> [ContractionEntry] { [] }
    func saveContraction(_ contraction: ContractionEntry) {}
    func fetchWeightEntries(for pregnancy: PregnancyProfile) -> [WeightEntry] { [] }
    func saveWeightEntry(_ entry: WeightEntry) {}
    func fetchAppointments(for pregnancy: PregnancyProfile) -> [Appointment] { [] }
    func saveAppointment(_ appointment: Appointment) {}
    func deleteAppointment(_ appointment: Appointment) {}
}
