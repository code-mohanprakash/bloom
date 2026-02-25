//
//  Constants.swift
//  BloomHer
//
//  App-wide numeric and domain constants.
//
//  Guidelines:
//  - All values are expressed in their natural unit (days, ml, ratio).
//  - No magic numbers should appear in business logic; reference these instead.
//  - Constants are organised into nested enums so the call-site reads like
//    prose: `Constants.Cycle.defaultLength`, `Constants.Hydration.waterGoalMl`.
//

import Foundation

// MARK: - Constants

/// Top-level namespace for app-wide constants.
public enum Constants {

    // MARK: Cycle

    /// Domain constants related to menstrual cycle tracking.
    public enum Cycle {

        /// Assumed cycle length (days) when no historical data is available.
        public static let defaultLength: Int = 28

        /// Assumed period length (days) when no historical data is available.
        public static let defaultPeriodLength: Int = 5

        /// Maximum number of past cycles used when building a prediction model.
        ///
        /// Older cycles are discarded to keep the model responsive to recent
        /// changes in the user's physiology.
        public static let maxHistoryForPrediction: Int = 12

        /// Minimum number of recorded cycles required before the app attempts
        /// to surface cycle-length predictions.
        public static let minCyclesForPrediction: Int = 3

        /// Fixed luteal phase length used in ovulation estimation.
        ///
        /// The luteal phase (ovulation → menstruation) is typically 12–16 days
        /// and is relatively consistent across individuals. 14 days is the
        /// widely-used clinical default.
        public static let lutealPhaseLength: Int = 14

        /// Number of days in the fertile window (the 5 days before ovulation
        /// plus the day of ovulation itself).
        public static let fertileWindowDays: Int = 6

        /// Coefficient of variation threshold above which a cycle is flagged
        /// as irregular.
        ///
        /// 0.15 (15 %) is a commonly-cited clinical threshold. Cycles with
        /// a CV above this value trigger the "irregular cycle" UI state.
        public static let irregularCVThreshold: Double = 0.15

        /// Exponential weight-decay factor applied when computing a
        /// weighted-average cycle length across historical cycles.
        ///
        /// A factor of 0.85 means each cycle is weighted at 85 % of the
        /// previous one's weight, giving recent cycles more influence.
        public static let weightDecayFactor: Double = 0.85

        /// Clinical duration of a full-term pregnancy in days (40 weeks).
        public static let pregnancyDurationDays: Int = 280
    }

    // MARK: Hydration

    /// Constants for water-intake tracking.
    public enum Hydration {

        /// Default daily water intake goal in millilitres for a non-pregnant user.
        public static let defaultGoalMl: Int = 2_000

        /// Recommended daily water intake in millilitres during pregnancy.
        ///
        /// Based on NHS / WHO guidance of ~2.3 L/day for pregnant women.
        public static let pregnancyGoalMl: Int = 2_300
    }
}
