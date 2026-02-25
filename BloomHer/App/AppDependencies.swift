import Foundation
import SwiftData

// MARK: - AppDependencies

/// The single composition root for BloomHer.
///
/// `AppDependencies` owns every repository and service, wires them together,
/// and is injected into the SwiftUI environment at the root of the app.
/// View-models receive individual dependencies from the environment rather
/// than the whole container; this keeps coupling minimal and facilitates
/// targeted testing.
///
/// Marked `@Observable` so the root view can reactively reconfigure the app
/// when, for example, `settingsManager.appMode` changes.
@Observable
@MainActor
final class AppDependencies {

    // MARK: - Settings

    let settingsManager: SettingsManager

    // MARK: - Repositories

    let cycleRepository: CycleRepositoryProtocol
    let pregnancyRepository: PregnancyRepositoryProtocol
    let yogaRepository: YogaRepositoryProtocol
    let wellnessRepository: WellnessRepositoryProtocol
    let ttcRepository: TTCRepositoryProtocol

    // MARK: - Services

    let cyclePredictionService: CyclePredictorProtocol
    let healthKitService: HealthKitServiceProtocol
    let notificationService: NotificationServiceProtocol
    let partnerService: PartnerSharingServiceProtocol
    let pdfGenerator: PDFGeneratorServiceProtocol
    let authenticationService: AuthenticationService
    let aiAssistantService:    AIAssistantService

    // MARK: - Init

    /// Constructs all dependencies from the provided `ModelContext`.
    ///
    /// The `ModelContext` comes from the `ModelContainer` configured by
    /// `DataConfiguration.makeModelContainer()` and is owned by the SwiftUI
    /// scene, ensuring a single source of truth for all persistent data.
    ///
    /// - Parameter modelContext: The SwiftData model context for the main actor.
    init(modelContext: ModelContext) {
        // 1. Settings — pure UserDefaults, no context dependency.
        settingsManager = SettingsManager()

        // 2. Repositories — each takes the same context so mutations are
        //    automatically visible across all repositories within a session.
        cycleRepository     = CycleRepository(context: modelContext)
        pregnancyRepository = PregnancyRepository(context: modelContext)
        yogaRepository      = YogaRepository(context: modelContext)
        wellnessRepository  = WellnessRepository(context: modelContext)
        ttcRepository       = TTCRepository(context: modelContext)

        // 3. Services — stateless algorithm implementations.
        cyclePredictionService = CyclePredictionService()
        healthKitService       = HealthKitService()
        notificationService    = NotificationService()
        partnerService         = PartnerSharingService()
        pdfGenerator           = PDFGeneratorService()
        authenticationService  = AuthenticationService()
        aiAssistantService     = AIAssistantService()
    }
}

// MARK: - Testing Support

extension AppDependencies {
    /// Convenience factory for unit tests and SwiftUI previews.
    ///
    /// Creates an in-memory `ModelContainer` with no CloudKit sync so that tests
    /// remain isolated and do not touch production storage.
    @MainActor
    static func preview() -> AppDependencies {
        let container = DataConfiguration.makeInMemoryContainer()
        return AppDependencies(modelContext: container.mainContext)
    }
}
