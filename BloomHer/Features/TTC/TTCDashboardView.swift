//
//  TTCDashboardView.swift
//  BloomHer
//
//  TTC mode home screen. Shows the fertile window countdown, OPK status,
//  a BBT sparkline, conception tips, cycle attempt counter, and quick actions.
//

import SwiftUI
import Charts

// MARK: - TTCDashboardView

struct TTCDashboardView: View {

    // MARK: State

    @State private var viewModel: TTCViewModel
    @State private var showOPKSheet    = false
    @State private var showBBTSheet    = false
    @State private var showJournal     = false
    @State private var showFertileView = false
    @State private var sparkleScale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.6

    // MARK: Init

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: TTCViewModel(dependencies: dependencies))
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                // Mode header
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(BloomIcons.iconTTC)
                        .resizable()
                        .scaledToFit()
                        .frame(width: BloomHerTheme.IconSize.hero, height: BloomHerTheme.IconSize.hero)

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Trying to Conceive")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Cycle \(viewModel.cycleCount)")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.accentPeach)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .staggeredAppear(index: 0)

                fertileWindowCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                cycleCounterRow
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                opkStatusCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 3)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                bbtSparklineCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 4)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                quickActionsSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 5)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                conceptionTipsCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 6)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                medicalDisclaimer
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 7)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Trying to Conceive")
        .refreshable { viewModel.refresh() }
        .onAppear { viewModel.refresh(); startSparkleAnimation() }
        .sheet(isPresented: $showOPKSheet) {
            OPKLoggingView(viewModel: viewModel)
                .bloomSheet()
        }
        .sheet(isPresented: $showBBTSheet) {
            BBTChartView(viewModel: viewModel)
                .bloomSheet()
        }
        .sheet(isPresented: $showJournal) {
            TTCJournalView(viewModel: viewModel)
                .bloomSheet()
        }
        .sheet(isPresented: $showFertileView) {
            FertileWindowView(viewModel: viewModel)
                .bloomSheet()
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Fertile Window Card

    @ViewBuilder
    private var fertileWindowCard: some View {
        Button {
            BloomHerTheme.Haptics.light()
            showFertileView = true
        } label: {
            ZStack {
                // Rich layered gradient background
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: fertileGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Decorative bokeh circles
                fertileDecoCircles

                // Glass overlay for depth
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.08))

                // Inner top highlight
                VStack {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.30), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 64)
                    Spacer()
                }

                // Soft glass border
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.50), Color.white.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )

                VStack(spacing: BloomHerTheme.Spacing.md) {
                    if viewModel.isInFertileWindow {
                        fertileNowContent
                    } else {
                        countdownContent
                    }
                }
                .padding(BloomHerTheme.Spacing.xl)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .shadow(
            color: fertileWindowBaseColor.opacity(0.25),
            radius: 28, x: 0, y: 12
        )
    }

    /// Soft bokeh circles inside the fertile window card.
    private var fertileDecoCircles: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 100, height: 100)
                .offset(x: -90, y: -30)
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 140, height: 140)
                .offset(x: 80, y: 50)
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 60, height: 60)
                .offset(x: 100, y: -50)
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 80, height: 80)
                .offset(x: -70, y: 60)
        }
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous))
    }

    private var fertileNowContent: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            // Icon row
            Image(BloomIcons.fertileWindow)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .scaleEffect(sparkleScale)
                .opacity(sparkleOpacity)

            Text("Fertile Now!")
                .font(BloomHerTheme.Typography.title1)
                .foregroundStyle(.white)

            Text("This is your peak conception window")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(.white.opacity(0.90))
                .multilineTextAlignment(.center)

            if let end = viewModel.fertileWindowEnd {
                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Image(BloomIcons.calendarClock)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                    Text("Window closes \(end, style: .relative) from now")
                }
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.top, BloomHerTheme.Spacing.xxs)
            }
        }
    }

    private var countdownContent: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            Image(BloomIcons.fertileWindow)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)

            Text("Fertile Window")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(.white.opacity(0.90))

            let days = viewModel.daysUntilFertileWindow
            if days > 0 && days < 100 {
                Text("\(days)")
                    .font(BloomHerTheme.Typography.cycleDay)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(BloomHerTheme.Animation.standard, value: days)
                Text(days == 1 ? "day away" : "days away")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            } else {
                Text("Calculating...")
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(.white.opacity(0.85))
                Text("Log more cycles to see predictions")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(.white.opacity(0.70))
            }

            if let start = viewModel.fertileWindowStart {
                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Image(BloomIcons.calendarClock)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                    Text("Starts \(start, style: .date)")
                }
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.top, BloomHerTheme.Spacing.xxs)
            }
        }
    }

    private var fertileWindowBaseColor: Color {
        viewModel.isInFertileWindow
            ? BloomHerTheme.Colors.sageGreen
            : BloomHerTheme.Colors.primaryRose
    }

    private var fertileGradientColors: [Color] {
        if viewModel.isInFertileWindow {
            return [
                BloomHerTheme.Colors.sageGreen,
                BloomHerTheme.Colors.sageGreen.opacity(0.85),
                Color(hex: "#7EC8A0")
            ]
        } else {
            return [
                BloomHerTheme.Colors.primaryRose,
                BloomHerTheme.Colors.primaryRose.opacity(0.85),
                BloomHerTheme.Colors.accentPeach.opacity(0.8)
            ]
        }
    }

    // MARK: - Cycle Counter Row

    private var cycleCounterRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {

            // Cycle attempt badge
            BloomCard {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(BloomHerTheme.Colors.primaryRose.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text("\(viewModel.cycleCount)")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            .contentTransition(.numericText())
                    }
                    Text("Cycles")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Text("Trying")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(BloomHerTheme.Spacing.md)
            }

            // Current phase badge
            BloomCard(isPhaseAware: true) {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(viewModel.currentPhase.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    Text(viewModel.currentPhase.displayName)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("Phase")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(BloomHerTheme.Spacing.md)
            }

            // OPK trend badge
            BloomCard {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.ttcTestStick)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    Text("OPK")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Text(viewModel.recentOPKResults.isEmpty ? "No data" : viewModel.opkTrend == .stable ? "Stable" : viewModel.opkTrend == .rising ? "Rising" : "Positive")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(BloomHerTheme.Spacing.md)
            }
        }
    }

    // MARK: - OPK Status Card

    private var opkStatusCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Ovulation Test (OPK)")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(viewModel.opkTrend.displayMessage)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(viewModel.opkTrend.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }

                // Last 7 OPK results as colored dots
                if !viewModel.recentOPKResults.isEmpty {
                    let last7 = Array(viewModel.recentOPKResults.suffix(7))
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(last7) { result in
                            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                                Circle()
                                    .fill(result.result.color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(result.result.icon)
                                            .resizable()
                                            .renderingMode(.template)
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundStyle(.white)
                                    )
                                Text(result.date, format: .dateTime.day())
                                    .font(BloomHerTheme.Typography.caption2)
                                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            }
                        }
                        Spacer()
                    }
                }

                BloomButton("Log Today's OPK", style: .primary, icon: BloomIcons.plus, isFullWidth: true) {
                    showOPKSheet = true
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - BBT Sparkline Card

    private var bbtSparklineCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Basal Body Temperature")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        if viewModel.hasThermalShift {
                            HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                                Image(BloomIcons.arrowUpCircle)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 13, height: 13)
                                Text("Thermal shift detected")
                            }
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                        } else {
                            Text("Last 7 days")
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }
                    }
                    Spacer()
                    Button {
                        BloomHerTheme.Haptics.light()
                        showBBTSheet = true
                    } label: {
                        Image(BloomIcons.bbtChart)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }

                if viewModel.recentBBTEntries.isEmpty {
                    emptyBBTPlaceholder
                } else {
                    bbtSparkline
                }

                BloomButton("Log BBT", style: .secondary, icon: BloomIcons.thermometer, isFullWidth: true) {
                    showBBTSheet = true
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var emptyBBTPlaceholder: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            Image(BloomIcons.ttcThermometer)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text("No BBT data yet")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 80)
    }

    private var bbtSparkline: some View {
        let last7 = Array(viewModel.recentBBTEntries.suffix(7))
        return Chart(last7) { entry in
            LineMark(
                x: .value("Date", entry.date, unit: .day),
                y: .value("Temp", entry.temperatureCelsius)
            )
            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Date", entry.date, unit: .day),
                y: .value("Temp", entry.temperatureCelsius)
            )
            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            .symbolSize(30)

            if let coverline = viewModel.coverlineTemperature {
                RuleMark(y: .value("Coverline", coverline))
                    .foregroundStyle(BloomHerTheme.Colors.accentLavender.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                AxisValueLabel {
                    if let temp = value.as(Double.self) {
                        Text(String(format: "%.1f°", temp))
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
            }
        }
        .frame(minHeight: 90)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Quick Actions")

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                // OPK Log — kawaii icon
                Button {
                    BloomHerTheme.Haptics.light()
                    showOPKSheet = true
                } label: {
                    VStack(spacing: BloomHerTheme.Spacing.xxs) {
                        ZStack {
                            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                                .fill(BloomHerTheme.Colors.accentPeach.opacity(0.15))
                                .frame(height: 56)
                            Image(BloomIcons.ttcTestStick)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }
                        Text("OPK Log")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ScaleButtonStyle())

                // BBT Chart — kawaii icon
                Button {
                    BloomHerTheme.Haptics.light()
                    showBBTSheet = true
                } label: {
                    VStack(spacing: BloomHerTheme.Spacing.xxs) {
                        ZStack {
                            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                                .fill(BloomHerTheme.Colors.primaryRose.opacity(0.15))
                                .frame(height: 56)
                            Image(BloomIcons.ttcThermometer)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }
                        Text("BBT Chart")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ScaleButtonStyle())

                quickActionButton(icon: BloomIcons.ttcTeapot, label: "Journal", color: BloomHerTheme.Colors.accentLavender) {
                    showJournal = true
                }
                // Fertile Window — kawaii icon
                Button {
                    BloomHerTheme.Haptics.light()
                    showFertileView = true
                } label: {
                    VStack(spacing: BloomHerTheme.Spacing.xxs) {
                        ZStack {
                            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                                .fill(BloomHerTheme.Colors.sageGreen.opacity(0.15))
                                .frame(height: 56)
                            Image(BloomIcons.ttcFertilityCalendar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }
                        Text("Fertile")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            BloomHerTheme.Haptics.light()
            action()
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                ZStack {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(height: 56)
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                Text(label)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Conception Tips Card

    private var conceptionTipsCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.ttcFamilyHeart)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    Text("Conception Tips")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(Array(PartnerEducationData.conceptionTips.prefix(3).enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                            Circle()
                                .fill(BloomHerTheme.Colors.primaryRose)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(tip.description)
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Medical Disclaimer

    private var medicalDisclaimer: some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
            Image(BloomIcons.info)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            Text("BloomHer provides fertility awareness information for educational purposes only. This is not medical advice. If you have concerns about fertility, please consult a qualified healthcare provider.")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        )
    }

    // MARK: - Sparkle Animation

    private func startSparkleAnimation() {
        withAnimation(BloomHerTheme.Animation.pulse) {
            sparkleScale   = 1.2
            sparkleOpacity = 1.0
        }
    }
}

// MARK: - Preview

#Preview("TTC Dashboard") {
    TTCDashboardView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .ovulation)
}

#Preview("TTC Dashboard — Fertile Window") {
    TTCDashboardView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .follicular)
}
