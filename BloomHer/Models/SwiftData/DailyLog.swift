import Foundation
import SwiftData

@Model
final class DailyLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var flowIntensity: FlowLevel?
    var flowColour: FlowColour?
    var moods: [Mood]
    var symptoms: [Symptom]
    var crampIntensity: CrampLevel?
    var energyLevel: Int?       // 1-5
    var sleepHours: Double?
    var sleepQuality: Int?      // 1-5
    var waterIntakeMl: Int
    var hungerLevel: Int?       // 1-5
    var notes: String?
    var sexualActivity: SexualActivity?
    var dischargeType: DischargeType?
    var skinConditions: [SkinCondition]

    var cycleEntry: CycleEntry?

    init(date: Date) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.moods = []
        self.symptoms = []
        self.skinConditions = []
        self.waterIntakeMl = 0
    }
}
