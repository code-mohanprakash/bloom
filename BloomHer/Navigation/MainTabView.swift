//
//  MainTabView.swift
//  BloomHer
//
//  The root tab container that hosts all five primary navigation stacks
//  and overlays the custom BloomTabBar above the content area.
//
//  Architecture
//  ------------
//  - A single @State selectedTab drives both the native TabView(selection:)
//    and the BloomTabBar binding.
//  - TabView(selection:) is used as the switching engine because it maps
//    directly to UIKit's UITabBarController under the hood, giving reliable
//    content swapping regardless of SwiftUI's structural diffing behavior.
//    The native tab bar is hidden via .toolbar(.hidden, for: .tabBar);
//    only the custom BloomTabBar overlay is visible.
//  - Each tab owns a @State router so navigation state survives tab switches.
//  - The cycle phase is resolved once per app-foreground event and injected
//    via .environment(\.currentCyclePhase, …) at this level so every child
//    view inherits it without prop drilling.
//  - The app mode is forwarded from SettingsManager via the same mechanism.
//  - .safeAreaInset(edge: .bottom) on the TabView pushes scroll content
//    above the floating bar so nothing is obscured.
//
//  Why TabView instead of the ZStack opacity trick
//  -----------------------------------------------
//  The previous ZStack approach gave every tab opacity(0)/allowsHitTesting(false)
//  for non-selected tabs, but SwiftUI's view reconciler treats all five
//  NavigationStack children as structurally identical siblings. It cannot
//  reliably distinguish which one to promote as "active," so the first child
//  (Home) effectively owned the rendered slot and content never changed.
//  TabView(selection:) delegates switching to UIKit, which has no such
//  ambiguity.
//

import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {

    // MARK: Dependencies

    @Environment(AppDependencies.self) private var dependencies

    // MARK: Tab State

    @State private var selectedTab: AppTab = .home

    // MARK: Per-Tab Routers

    @State private var homeRouter      = HomeRouter()
    @State private var calendarRouter  = CalendarRouter()
    @State private var wellnessRouter  = WellnessRouter()
    @State private var insightsRouter  = InsightsRouter()
    @State private var profileRouter   = ProfileRouter()
    @State private var showAIChat      = false
    @State private var showPartnerSetup = false
    @State private var showModeAction  = false

    // MARK: Phase Resolution

    /// The current cycle phase, resolved from persisted cycle data each time
    /// the view appears or the active app-mode changes.
    @State private var currentPhase: CyclePhase = .follicular

    // MARK: Layout Constants

    /// The height reserved at the bottom for the floating tab bar so
    /// scrollable content is never obscured by it.
    private let tabBarReservedHeight: CGFloat = 104

    // MARK: - Init

    init() {
        // Fully suppress the native UIKit tab bar so the iOS 26
        // Liquid Glass floating capsule doesn't render behind BloomTabBar.
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isHidden = true
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // TabView drives content switching through UIKit's tab controller,
            // guaranteeing that the displayed content matches selectedTab.
            // The native tab bar chrome is hidden; BloomTabBar replaces it.
            TabView(selection: $selectedTab) {
                homeTab
                    .tag(AppTab.home)

                calendarTab
                    .tag(AppTab.calendar)

                wellnessTab
                    .tag(AppTab.wellness)

                insightsTab
                    .tag(AppTab.insights)

                profileTab
                    .tag(AppTab.profile)
            }
            // Push scroll content above the floating BloomTabBar.
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: tabBarReservedHeight)
            }
            // Suppress UIKit's native tab bar; BloomTabBar is the only UI.
            .toolbar(.hidden, for: .tabBar)

            // Floating custom tab bar overlay.
            BloomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, bottomSafeAreaInset)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAIChat) {
            if dependencies.aiAssistantService.availability.isAvailable {
                AIAssistantChatView(service: dependencies.aiAssistantService)
                    .bloomSheet()
            }
        }
        .sheet(isPresented: $showPartnerSetup) {
            PartnerSetupView(dependencies: dependencies)
                .bloomSheet()
        }
        .sheet(isPresented: $showModeAction) {
            modeActionSheet
                .bloomSheet()
        }
        .onChange(of: dependencies.settingsManager.appMode) { _, mode in
            if dependencies.aiAssistantService.availability.isAvailable {
                dependencies.aiAssistantService.configure(
                    mode: mode,
                    phase: currentPhase,
                    userName: dependencies.settingsManager.userName
                )
            }
        }
        // Propagate resolved phase and app mode into the entire subtree.
        .environment(\.currentCyclePhase, currentPhase)
        .environment(\.appMode, dependencies.settingsManager.appMode)
        .task {
            await resolveCurrentPhase()
            if dependencies.aiAssistantService.availability.isAvailable {
                dependencies.aiAssistantService.configure(
                    mode: dependencies.settingsManager.appMode,
                    phase: currentPhase,
                    userName: dependencies.settingsManager.userName
                )
            }
        }
        // Re-resolve whenever the mode changes (e.g. switching cycle → pregnant).
        .onChange(of: dependencies.settingsManager.appMode) { _, _ in
            Task { await resolveCurrentPhase() }
        }
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack(path: $homeRouter.path) {
            HomeContainerView()
                .toolbar {
                    HomeToolbarContent(
                        appMode: dependencies.settingsManager.appMode,
                        settingsManager: dependencies.settingsManager,
                        aiAvailable: dependencies.aiAssistantService.availability.isAvailable,
                        showAIChat: $showAIChat,
                        showPartnerSetup: $showPartnerSetup,
                        onModeAction: { showModeAction = true }
                    )
                }
                .navigationDestination(for: HomeDestination.self) { destination in
                    homeDestinationView(destination)
                }
        }
        .environment(homeRouter)
    }

    @ViewBuilder
    private func homeDestinationView(_ destination: HomeDestination) -> some View {
        switch destination {
        case .cycleDetail(let date):
            DayDetailSheet(
                viewModel: DayDetailViewModel(
                    date: date,
                    cycleRepository: dependencies.cycleRepository
                )
            )
        case .symptomLog(let date):
            SymptomLogQuickSheet(
                viewModel: DayDetailViewModel(
                    date: date,
                    cycleRepository: dependencies.cycleRepository
                )
            )
        case .pregnancyWeek(let week):
            WeekByWeekView(currentWeek: week)
        case .kickCounter:
            KickCounterView(
                viewModel: PregnancyViewModel(
                    repository: dependencies.pregnancyRepository
                )
            )
        case .contractionTimer:
            ContractionTimerView(
                viewModel: PregnancyViewModel(
                    repository: dependencies.pregnancyRepository
                )
            )
        case .waterTracker:
            WaterTrackerView(
                viewModel: WellnessViewModel(dependencies: dependencies)
            )
        case .affirmation:
            AffirmationCardView(
                viewModel: WellnessViewModel(dependencies: dependencies)
            )
        }
    }

    // MARK: - Calendar Tab

    private var calendarTab: some View {
        NavigationStack(path: $calendarRouter.path) {
            CalendarContainerView()
                .navigationDestination(for: CalendarDestination.self) { destination in
                    calendarDestinationView(destination)
                }
        }
        .environment(calendarRouter)
    }

    @ViewBuilder
    private func calendarDestinationView(_ destination: CalendarDestination) -> some View {
        switch destination {
        case .dayDetail(let date):
            ComingSoonView(title: "Day Detail", subtitle: date.formatted(date: .long, time: .omitted))
        case .cycleInsights:
            ComingSoonView(title: "Cycle Insights", subtitle: nil)
        }
    }

    // MARK: - Wellness Tab

    private var wellnessTab: some View {
        NavigationStack(path: $wellnessRouter.path) {
            WellnessHomeView(dependencies: dependencies)
                .navigationDestination(for: WellnessDestination.self) { destination in
                    wellnessDestinationView(destination)
                }
        }
        .environment(wellnessRouter)
    }

    @ViewBuilder
    private func wellnessDestinationView(_ destination: WellnessDestination) -> some View {
        switch destination {
        case .routineList(let category):
            let yogaVM = YogaViewModel(yogaRepository: dependencies.yogaRepository)
            let _ = yogaVM.loadData()
            RoutineListView(category: category, viewModel: yogaVM)
        case .routineDetail(let id):
            let yogaVM = YogaViewModel(yogaRepository: dependencies.yogaRepository)
            let _ = yogaVM.loadData()
            if let routine = YogaContentProvider.allRoutines.first(where: { $0.id == id }) {
                RoutineDetailView(routine: routine, viewModel: yogaVM)
            } else {
                ComingSoonView(title: "Routine", subtitle: id)
            }
        case .activeRoutine(let id):
            let yogaVM = YogaViewModel(yogaRepository: dependencies.yogaRepository)
            let _ = yogaVM.loadData()
            if let routine = YogaContentProvider.allRoutines.first(where: { $0.id == id }) {
                ActiveRoutineView(routine: routine, viewModel: yogaVM)
            } else {
                ComingSoonView(title: "Active Routine", subtitle: id)
            }
        case .poseLibrary:
            PoseLibraryView()
        case .pelvicFloor:
            PelvicFloorView()
        case .breathing:
            BreathingExerciseView()
        case .affirmationFull:
            AffirmationCardView(
                viewModel: WellnessViewModel(dependencies: dependencies)
            )
        case .gratitudeJournal:
            GratitudeJournalView(
                viewModel: WellnessViewModel(dependencies: dependencies)
            )
        case .nutritionTips:
            NutritionTipsView(phase: currentPhase)
        case .selfCare:
            SelfCareChecklistView(
                viewModel: WellnessViewModel(dependencies: dependencies)
            )
        case .supplementReminder:
            SupplementReminderView(phase: currentPhase)
        }
    }

    // MARK: - Insights Tab

    private var insightsTab: some View {
        NavigationStack(path: $insightsRouter.path) {
            InsightsContainerView()
                .navigationDestination(for: InsightsDestination.self) { destination in
                    insightsDestinationView(destination)
                }
        }
        .environment(insightsRouter)
    }

    @ViewBuilder
    private func insightsDestinationView(_ destination: InsightsDestination) -> some View {
        switch destination {
        case .cycleInsights:
            ComingSoonView(title: "Cycle Insights", subtitle: nil)
        case .reportGenerator:
            ComingSoonView(title: "Report Generator", subtitle: nil)
        case .symptomHeatmap:
            ComingSoonView(title: "Symptom Heatmap", subtitle: nil)
        case .moodPatterns:
            ComingSoonView(title: "Mood Patterns", subtitle: nil)
        }
    }

    // MARK: - Profile Tab

    private var profileTab: some View {
        NavigationStack(path: $profileRouter.path) {
            SettingsView(dependencies: dependencies)
                .navigationDestination(for: ProfileDestination.self) { destination in
                    profileDestinationView(destination)
                }
        }
        .environment(profileRouter)
    }

    @ViewBuilder
    private func profileDestinationView(_ destination: ProfileDestination) -> some View {
        switch destination {
        case .privacySettings:
            ComingSoonView(title: "Privacy", subtitle: nil)
        case .notificationSettings:
            ComingSoonView(title: "Notifications", subtitle: nil)
        case .appearanceSettings:
            ComingSoonView(title: "Appearance", subtitle: nil)
        case .healthKitSettings:
            ComingSoonView(title: "Health", subtitle: "HealthKit Permissions")
        case .partnerSetup:
            PartnerSetupView(dependencies: dependencies)
        case .about:
            ComingSoonView(title: "About BloomHer", subtitle: nil)
        case .medicalDisclaimer:
            ComingSoonView(title: "Medical Disclaimer", subtitle: nil)
        case .dataDeletion:
            ComingSoonView(title: "Delete My Data", subtitle: nil)
        }
    }

    // MARK: - Phase Resolution

    /// Resolves the current cycle phase from the prediction service and
    /// the user's most recent cycle data.
    ///
    /// Falls back to `.follicular` when no cycle data exists or the app is
    /// running in pregnancy / TTC mode (where phase is less meaningful).
    @MainActor
    private func resolveCurrentPhase() async {
        // Phase-based theming only applies in cycle and TTC modes.
        guard dependencies.settingsManager.appMode != .pregnant else {
            currentPhase = .follicular
            return
        }

        let cycles = dependencies.cycleRepository.fetchAllCycles()
        let sorted = cycles.sorted { $0.startDate < $1.startDate }

        guard let lastStart = sorted.last?.startDate else {
            currentPhase = .follicular
            return
        }

        let prediction = dependencies.cyclePredictionService.predictNextPeriod(from: sorted)
        currentPhase = dependencies.cyclePredictionService.currentPhase(
            lastPeriodStart: lastStart,
            prediction: prediction
        )
    }

    // MARK: - Safe Area Helpers

    private var bottomSafeAreaInset: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: \.isKeyWindow)?
            .safeAreaInsets
            .bottom) ?? 0
    }

    // MARK: - Mode Action Sheet

    @ViewBuilder
    private var modeActionSheet: some View {
        switch dependencies.settingsManager.appMode {
        case .cycle:
            NavigationStack {
                ComingSoonView(title: "Notifications", subtitle: "Cycle reminders coming soon")
            }
        case .pregnant:
            KickCounterView(
                viewModel: PregnancyViewModel(
                    repository: dependencies.pregnancyRepository
                )
            )
        case .ttc:
            OPKLoggingView(
                viewModel: TTCViewModel(dependencies: dependencies)
            )
        }
    }
}

// MARK: - ComingSoonView

/// Placeholder view rendered for navigation destinations whose feature
/// screens have not yet been implemented. Replaced in subsequent phases.
private struct ComingSoonView: View {

    let title: String
    let subtitle: String?

    @Environment(\.currentCyclePhase) private var phase

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            Spacer()

            Image(BloomIcons.flower)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Text(title)
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomColors.textSecondary)
                }

                Text("Coming soon")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomColors.textTertiary)
                    .padding(.top, BloomHerTheme.Spacing.xxs)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(BloomColors.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ThemeToggleCapsule

/// A small capsule that lets the user cycle between Dark, Light, and Auto
/// (system) appearance. Tapping it cycles: Dark -> Light -> Auto -> Dark.
struct ThemeToggleCapsule: View {

    let settingsManager: SettingsManager

    @State private var isAnimating = false

    var body: some View {
        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                isAnimating = true
                settingsManager.selectedThemeMode = settingsManager.selectedThemeMode.next
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isAnimating = false
            }
        } label: {
            HStack(spacing: 5) {
                Image(settingsManager.selectedThemeMode.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .rotationEffect(.degrees(isAnimating ? 20 : 0))

                Text(settingsManager.selectedThemeMode.shortLabel)
                    .font(BloomHerTheme.Typography.caption2.weight(.semibold))
            }
            .foregroundStyle(.primary.opacity(0.75))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Change appearance theme")
        .animation(BloomHerTheme.Animation.quick, value: settingsManager.selectedThemeMode)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(AppDependencies.preview())
        .modelContainer(DataConfiguration.makeInMemoryContainer())
}
