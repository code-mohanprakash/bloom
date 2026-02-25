import Foundation
import SwiftData

// MARK: - DataConfiguration

/// Factory namespace for constructing the app's `ModelContainer`.
///
/// The preferred configuration uses CloudKit private database sync so that the
/// user's health data is backed up and available across their devices.  If
/// CloudKit is unavailable (simulator, entitlement missing, network error at
/// startup), the factory falls back gracefully to a local-only store rather
/// than crashing the app.
///
/// Schema
/// ------
/// All 13 `@Model` types are registered in the schema so that SwiftData can
/// manage migrations automatically via `ModelContainer`'s lightweight migration.
///
/// Thread Safety
/// -------------
/// The `ModelContainer` is safe to share across actors.  Callers should use
/// `container.mainContext` on the main actor and `container.newBackgroundContext()`
/// for background work.
enum DataConfiguration {

    // MARK: - Production Container

    /// Creates the production `ModelContainer`.
    ///
    /// Attempts CloudKit sync first; falls back to local-only storage if the
    /// CloudKit configuration cannot be initialised (e.g. running in Simulator
    /// or a build without the CloudKit entitlement).
    static func makeModelContainer() -> ModelContainer {
        let schema = makeSchema()

        // Attempt CloudKit-backed configuration first.
        do {
            let cloudConfig = ModelConfiguration(
                schema:           schema,
                isStoredInMemoryOnly: false,
                allowsSave:       true,
                cloudKitDatabase: .private("iCloud.com.bloomher.app")
            )
            return try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            // CloudKit unavailable — fall back to local store.
            // This is expected in the Simulator and CI environments.
            return makeLocalContainer(schema: schema)
        }
    }

    // MARK: - In-Memory Container (Previews & Tests)

    /// Creates an ephemeral, in-memory `ModelContainer` with no persistence.
    ///
    /// Use this factory in SwiftUI `#Preview` blocks and XCTest targets to
    /// keep test runs isolated and avoid touching production databases.
    static func makeInMemoryContainer() -> ModelContainer {
        let schema = makeSchema()
        let config = ModelConfiguration(
            schema:               schema,
            isStoredInMemoryOnly: true,
            allowsSave:           true,
            cloudKitDatabase:     .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("BloomHer: Failed to create in-memory ModelContainer: \(error)")
        }
    }

    // MARK: - Private Helpers

    /// Constructs the `Schema` containing all 13 persistent model types.
    private static func makeSchema() -> Schema {
        Schema([
            CycleEntry.self,
            DailyLog.self,
            PregnancyProfile.self,
            KickSession.self,
            ContractionEntry.self,
            YogaSession.self,
            Appointment.self,
            WeightEntry.self,
            OPKResult.self,
            BBTEntry.self,
            Affirmation.self,
            PartnerShare.self,
            WeeklyChecklist.self
        ])
    }

    /// Creates a local (non-CloudKit) persistent `ModelContainer`.
    ///
    /// The store file is placed in the app's Application Support directory,
    /// which is excluded from iCloud Drive backup by default — appropriate for
    /// the local-only fallback path.
    private static func makeLocalContainer(schema: Schema) -> ModelContainer {
        let localConfig = ModelConfiguration(
            schema:               schema,
            isStoredInMemoryOnly: false,
            allowsSave:           true,
            cloudKitDatabase:     .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [localConfig])
        } catch {
            // Store is incompatible (schema change during development).
            // Delete the corrupt store and retry once before giving up.
            deleteExistingStore()
            do {
                return try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("BloomHer: Failed to create local ModelContainer after reset: \(error)")
            }
        }
    }

    /// Removes the default SwiftData store files from Application Support.
    private static func deleteExistingStore() {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let storeNames = ["default.store", "default.store-shm", "default.store-wal"]
        for name in storeNames {
            let url = appSupport.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: url)
        }
    }
}
