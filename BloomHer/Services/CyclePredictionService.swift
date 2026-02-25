import Foundation

// MARK: - Supporting Types

/// The confidence level associated with a cycle-length prediction.
enum PredictionConfidence: String, Codable {
    case low
    case medium
    case high

    /// A user-facing label used in the UI.
    var displayName: String {
        switch self {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        }
    }
}

/// A fully calculated prediction produced by `CyclePredictionService`.
struct CyclePrediction {
    /// The calendar date on which the next period is expected to begin.
    let predictedNextStart: Date
    /// The predicted duration of the next period in days.
    let predictedPeriodLength: Int
    /// The predicted total cycle length in days.
    let predictedCycleLength: Int
    /// Estimated date of ovulation (predictedNextStart − lutealPhaseLength).
    let estimatedOvulationDate: Date
    /// First day of the fertile window (ovulation − 5 days).
    let fertileWindowStart: Date
    /// Last day of the fertile window (ovulation day itself).
    let fertileWindowEnd: Date
    /// Reliability level of the prediction.
    let confidence: PredictionConfidence
    /// True when cycle variability exceeds the irregularity threshold.
    let isIrregular: Bool
}

// MARK: - Protocol

/// Defines the prediction surface consumed by view-models.
protocol CyclePredictorProtocol {
    /// Calculates a `CyclePrediction` from a chronologically-ordered list of past cycles.
    func predictNextPeriod(from cycles: [CycleEntry]) -> CyclePrediction

    /// Returns the current cycle phase given when the last period started and the current prediction.
    func currentPhase(lastPeriodStart: Date, prediction: CyclePrediction) -> CyclePhase

    /// Returns the number of days the period is late, or nil if it is not late yet.
    func daysLate(prediction: CyclePrediction) -> Int?

    /// Returns the fertile window as a `DateInterval`, or nil when confidence is insufficient.
    func fertileWindow(prediction: CyclePrediction) -> DateInterval?

    /// Returns true when the supplied cycles have a coefficient of variation above the threshold.
    func isIrregular(cycles: [CycleEntry]) -> Bool

    /// Returns the current cycle day (day 1 = first day of last period).
    func cycleDay(from lastPeriodStart: Date) -> Int
}

// MARK: - CyclePredictionService

/// Implements the weighted-moving-average prediction algorithm described in the PRD.
///
/// Algorithm overview
/// ==================
/// 1. Derive cycle lengths from consecutive CycleEntry startDates.
/// 2. Clamp the window to the most-recent N cycles
///    (3 ≤ N ≤ Constants.Cycle.maxHistoryForPrediction).
/// 3. Apply exponential decay weights (w_i = 0.85^i, most-recent = weight 1.0).
/// 4. Weighted mean → predicted cycle length.
/// 5. Simple mean of last 6 period durations → predicted period length.
/// 6. Ovulation date = predictedNextStart − lutealPhaseLength.
/// 7. Fertile window = [ovulationDate − 5, ovulationDate].
/// 8. If CV > irregularCVThreshold, widen fertile window by ±2 days and set confidence = .low.
/// 9. Confidence: <3 cycles → .low; 3–5 → .medium; ≥6 and regular → .high.
final class CyclePredictionService: CyclePredictorProtocol {

    // MARK: - predictNextPeriod

    func predictNextPeriod(from cycles: [CycleEntry]) -> CyclePrediction {
        // Sort ascending so index arithmetic is natural.
        let sorted = cycles.sorted { $0.startDate < $1.startDate }

        // ----------------------------------------------------------------
        // Step 1: Derive cycle lengths from consecutive start-date pairs.
        // ----------------------------------------------------------------
        let cycleLengths = derivedCycleLengths(from: sorted)

        // ----------------------------------------------------------------
        // Step 2: Clamp to the window of recent cycles.
        // ----------------------------------------------------------------
        let windowedLengths = Array(cycleLengths.suffix(Constants.Cycle.maxHistoryForPrediction))

        // ----------------------------------------------------------------
        // Step 3–4: Weighted mean.
        // If fewer than minCyclesForPrediction, fall back to default.
        // ----------------------------------------------------------------
        let predictedCycleLength: Int
        let confidence: PredictionConfidence
        let irregular: Bool

        if windowedLengths.count < Constants.Cycle.minCyclesForPrediction {
            predictedCycleLength = Constants.Cycle.defaultLength
            confidence           = .low
            irregular            = false
        } else {
            let weighted = weightedMean(lengths: windowedLengths)
            predictedCycleLength = Int(weighted.rounded())

            // Compute CV for irregularity check.
            let mean   = arithmeticMean(lengths: windowedLengths)
            let stddev = standardDeviation(lengths: windowedLengths, mean: mean)
            let cv     = mean > 0 ? stddev / mean : 0.0
            irregular  = cv > Constants.Cycle.irregularCVThreshold

            if windowedLengths.count >= 6 && !irregular {
                confidence = .high
            } else if windowedLengths.count >= Constants.Cycle.minCyclesForPrediction {
                confidence = irregular ? .low : .medium
            } else {
                confidence = .low
            }
        }

        // ----------------------------------------------------------------
        // Step 5: Period length = simple mean of up to last 6 durations.
        // ----------------------------------------------------------------
        let predictedPeriodLength = averagePeriodLength(from: sorted)

        // ----------------------------------------------------------------
        // Base date for the prediction: the most-recent confirmed startDate.
        // ----------------------------------------------------------------
        guard let lastStart = sorted.last?.startDate else {
            return defaultPrediction()
        }

        let predictedNextStart = Calendar.current.date(
            byAdding: .day,
            value: predictedCycleLength,
            to: lastStart
        ) ?? lastStart.addingTimeInterval(TimeInterval(predictedCycleLength * 86400))

        // ----------------------------------------------------------------
        // Step 6: Ovulation estimate.
        // ----------------------------------------------------------------
        let ovulationDate = Calendar.current.date(
            byAdding: .day,
            value: -Constants.Cycle.lutealPhaseLength,
            to: predictedNextStart
        ) ?? predictedNextStart

        // ----------------------------------------------------------------
        // Step 7 & 8: Fertile window, widened if irregular.
        // ----------------------------------------------------------------
        let windowOffset = irregular ? 2 : 0
        let fertileStart = Calendar.current.date(
            byAdding: .day,
            value: -(Constants.Cycle.fertileWindowDays - 1 + windowOffset),
            to: ovulationDate
        ) ?? ovulationDate

        let fertileEnd = Calendar.current.date(
            byAdding: .day,
            value: windowOffset,
            to: ovulationDate
        ) ?? ovulationDate

        return CyclePrediction(
            predictedNextStart:   predictedNextStart,
            predictedPeriodLength: predictedPeriodLength,
            predictedCycleLength:  predictedCycleLength,
            estimatedOvulationDate: ovulationDate,
            fertileWindowStart:    fertileStart,
            fertileWindowEnd:      fertileEnd,
            confidence:            confidence,
            isIrregular:           irregular
        )
    }

    // MARK: - currentPhase

    func currentPhase(lastPeriodStart: Date, prediction: CyclePrediction) -> CyclePhase {
        let day = cycleDay(from: lastPeriodStart)
        let ovulationDay = max(prediction.predictedCycleLength - Constants.Cycle.lutealPhaseLength, prediction.predictedPeriodLength + 1)

        if day >= 1 && day <= prediction.predictedPeriodLength {
            return .menstrual
        } else if day >= ovulationDay - 1 && day <= ovulationDay + 1 {
            return .ovulation
        } else if day < ovulationDay - 1 {
            return .follicular
        } else {
            return .luteal
        }
    }

    // MARK: - daysLate

    func daysLate(prediction: CyclePrediction) -> Int? {
        let today = Calendar.current.startOfDay(for: Date())
        let expected = Calendar.current.startOfDay(for: prediction.predictedNextStart)
        guard today > expected else { return nil }
        return Calendar.current.dateComponents([.day], from: expected, to: today).day
    }

    // MARK: - fertileWindow

    func fertileWindow(prediction: CyclePrediction) -> DateInterval? {
        // Return nil only when confidence is low AND the cycle is regular
        // (meaning we have fewer than 3 cycles and no data to widen the window).
        // For irregular cycles the window is surfaced with a widened range
        // so the user can act on it even with reduced certainty.
        if prediction.confidence == .low && !prediction.isIrregular {
            return nil
        }
        guard prediction.fertileWindowStart <= prediction.fertileWindowEnd else { return nil }
        return DateInterval(start: prediction.fertileWindowStart, end: prediction.fertileWindowEnd)
    }

    // MARK: - isIrregular

    func isIrregular(cycles: [CycleEntry]) -> Bool {
        let sorted  = cycles.sorted { $0.startDate < $1.startDate }
        let lengths = derivedCycleLengths(from: sorted)
        guard lengths.count >= Constants.Cycle.minCyclesForPrediction else { return false }
        let mean   = arithmeticMean(lengths: lengths)
        let stddev = standardDeviation(lengths: lengths, mean: mean)
        return mean > 0 && (stddev / mean) > Constants.Cycle.irregularCVThreshold
    }

    // MARK: - cycleDay

    func cycleDay(from lastPeriodStart: Date) -> Int {
        let start = Calendar.current.startOfDay(for: lastPeriodStart)
        let today = Calendar.current.startOfDay(for: Date())
        let days  = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }

    // MARK: - Private Helpers

    /// Derives an array of integer cycle lengths from consecutive CycleEntry startDates.
    ///
    /// The array is ordered oldest → newest, matching the input sort order.
    private func derivedCycleLengths(from sorted: [CycleEntry]) -> [Double] {
        guard sorted.count >= 2 else { return [] }
        var lengths: [Double] = []
        for i in 1..<sorted.count {
            let days = Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: sorted[i - 1].startDate),
                to:   Calendar.current.startOfDay(for: sorted[i].startDate)
            ).day ?? 0
            // Sanity-clamp: ignore implausibly short (<10) or long (>60) cycles.
            if days >= 10 && days <= 60 {
                lengths.append(Double(days))
            }
        }
        return lengths
    }

    /// Computes the weighted mean of `lengths` where the last element carries
    /// weight 1.0 and each preceding element is discounted by `weightDecayFactor`.
    ///
    /// weights = [0.85^(n-1), ..., 0.85^1, 0.85^0]  (oldest to newest)
    private func weightedMean(lengths: [Double]) -> Double {
        let n = lengths.count
        var weightedSum = 0.0
        var totalWeight = 0.0

        for (index, length) in lengths.enumerated() {
            // index 0 = oldest, index n-1 = newest (weight = 1.0)
            let exponent = Double(n - 1 - index)
            let weight   = pow(Constants.Cycle.weightDecayFactor, exponent)
            weightedSum += weight * length
            totalWeight += weight
        }
        guard totalWeight > 0 else { return Double(Constants.Cycle.defaultLength) }
        return weightedSum / totalWeight
    }

    /// Simple arithmetic mean.
    private func arithmeticMean(lengths: [Double]) -> Double {
        guard !lengths.isEmpty else { return 0 }
        return lengths.reduce(0, +) / Double(lengths.count)
    }

    /// Population standard deviation.
    private func standardDeviation(lengths: [Double], mean: Double) -> Double {
        guard lengths.count > 1 else { return 0 }
        let variance = lengths.map { pow($0 - mean, 2) }.reduce(0, +) / Double(lengths.count)
        return sqrt(variance)
    }

    /// Returns the average period duration from the most-recent 6 entries
    /// that have both a startDate and endDate.  Falls back to the default (5).
    private func averagePeriodLength(from sorted: [CycleEntry]) -> Int {
        let durations: [Int] = sorted
            .compactMap { entry -> Int? in
                guard let end = entry.endDate else { return nil }
                let days = Calendar.current.dateComponents(
                    [.day],
                    from: Calendar.current.startOfDay(for: entry.startDate),
                    to:   Calendar.current.startOfDay(for: end)
                ).day ?? 0
                return days > 0 ? days : nil
            }
            .suffix(6)

        guard !durations.isEmpty else { return Constants.Cycle.defaultPeriodLength }
        let total = durations.reduce(0, +)
        return Int((Double(total) / Double(durations.count)).rounded())
    }

    /// Returns a safe default prediction anchored to today when no cycle data exists.
    private func defaultPrediction() -> CyclePrediction {
        let today          = Date()
        let nextStart      = Calendar.current.date(byAdding: .day, value: Constants.Cycle.defaultLength, to: today) ?? today
        let ovulation      = Calendar.current.date(byAdding: .day, value: -Constants.Cycle.lutealPhaseLength, to: nextStart) ?? nextStart
        let fertileStart   = Calendar.current.date(byAdding: .day, value: -(Constants.Cycle.fertileWindowDays - 1), to: ovulation) ?? ovulation

        return CyclePrediction(
            predictedNextStart:    nextStart,
            predictedPeriodLength: Constants.Cycle.defaultPeriodLength,
            predictedCycleLength:  Constants.Cycle.defaultLength,
            estimatedOvulationDate: ovulation,
            fertileWindowStart:    fertileStart,
            fertileWindowEnd:      ovulation,
            confidence:            .low,
            isIrregular:           false
        )
    }
}
