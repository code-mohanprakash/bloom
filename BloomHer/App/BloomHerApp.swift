//
//  BloomHerApp.swift
//  BloomHer
//
//  The @main entry point for the BloomHer iOS application.
//
//  Startup sequence
//  ----------------
//  1. `DataConfiguration.makeModelContainer()` attempts CloudKit-backed
//     SwiftData storage; falls back to local-only if CloudKit is unavailable.
//  2. `AppDependencies` wires together all repositories and services using
//     the container's main-actor context.
//  3. Both are injected into the SwiftUI environment at the scene root so
//     every view can read them without prop drilling.
//  4. `RootView` gates on `SettingsManager.hasCompletedOnboarding` and shows
//     either the onboarding flow or the main tab shell.
//
//  Global modifiers applied at the scene root
//  -------------------------------------------
//  - `.environment(dependencies)` — @Observable DI container.
//  - `.modelContainer(modelContainer)` — SwiftData context.
//  - `.preferredColorScheme(…)` — honours the user's theme preference
//    (system / light / dark) set in SettingsManager.
//  - `.tint(BloomHerTheme.Colors.primaryRose)` — seeds the global tint
//    so system controls (toggles, pickers, etc.) match the brand color
//    unless a more specific tint is applied lower in the hierarchy.
//

import SwiftUI
import SwiftData

// MARK: - BloomHerApp

@main
struct BloomHerApp: App {

    // MARK: - Scene-level Dependencies

    /// The shared SwiftData container for all persistent model types.
    ///
    /// Created once at launch and never re-created during the app lifecycle
    /// (iCloud sync toggle requires a restart, per `SettingsManager` documentation).
    let modelContainer: ModelContainer

    /// The composition root containing every repository and service.
    ///
    /// Passed into the view hierarchy as an `@Observable` environment object
    /// so child views can read individual properties reactively.
    let dependencies: AppDependencies

    /// Controls whether the splash screen is showing.
    @State private var showSplash = true

    // MARK: - Init

    init() {
        let container = DataConfiguration.makeModelContainer()
        self.modelContainer = container
        self.dependencies   = AppDependencies(modelContext: container.mainContext)
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    // Composition root — all repositories and services.
                    .environment(dependencies)
                    // SwiftData — enables @Query and model context in all views.
                    .modelContainer(modelContainer)
                    // Respect the user's stored theme preference.
                    .preferredColorScheme(
                        dependencies.settingsManager.selectedThemeMode.colorScheme
                    )
                    // Global tint seeds system controls with the brand color.
                    .tint(BloomHerTheme.Colors.primaryRose)

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                // Check Apple ID credential on launch.
                dependencies.authenticationService.checkExistingCredential()

                // Hold splash for 1.8 seconds, then fade out.
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}
