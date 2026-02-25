# BloomHer

A privacy-first women's health companion for iOS that provides menstrual cycle prediction using weighted moving averages, pregnancy week-by-week tracking, fertility window estimation, yoga routines, and an on-device AI wellness assistant -- all with zero third-party dependencies and no data leaving the device.

## The Problem

Mainstream period tracking apps harvest intimate health data and sell it to advertisers. Women deserve a comprehensive health companion that keeps menstrual cycles, pregnancy details, fertility data, and wellness logs entirely on-device while still providing medically-informed predictions and insights.

## Features

### Cycle Tracking
- **Weighted Moving Average prediction engine** -- predicts next period start, cycle length, and period duration using exponential decay weighting (0.85 decay factor) across up to 12 historical cycles
- **Four-phase detection** -- automatically determines current cycle phase (menstrual, follicular, ovulation, luteal) based on predicted cycle length and a 14-day luteal phase model
- **Irregularity detection** -- flags irregular cycles when coefficient of variation exceeds 15% threshold, automatically widening fertile window estimates by +/-2 days
- **Daily logging** -- flow level (light/medium/heavy/spotting), mood tracking (12 moods), 20+ symptoms, discharge type, cramp intensity, skin condition, sexual activity, temperature, and free-text notes
- **Period late detection** -- calculates days late from predicted start date with confidence-aware display
- **Interactive cycle calendar** -- month view with phase-coloured day indicators, period/fertile/ovulation overlays

### Pregnancy Mode
- **40-week tracker** -- week-by-week fetal development with size comparisons, body changes, and medical milestones
- **Kick counter** -- real-time session timer tracking individual kicks with timestamps, session history, and movement pattern analysis
- **Contraction timer** -- tracks duration and interval between contractions with visual timeline
- **Weight tracker** -- logs weight entries with chart visualization across trimesters
- **Weekly checklists** -- trimester-appropriate to-do lists (appointments, preparations, symptoms to watch)
- **Appointment manager** -- schedule and track prenatal visits with notification reminders

### Trying to Conceive (TTC)
- **Fertile window prediction** -- 6-day window ending on estimated ovulation day, derived from cycle prediction engine
- **OPK (Ovulation Predictor Kit) logging** -- tracks test results (negative/low/high/peak) with trend visualization
- **BBT (Basal Body Temperature) charting** -- daily temperature logging with 7-day trend chart and thermal shift detection
- **Conception tips** -- phase-aware educational content about timing, lifestyle factors, and fertility optimization

### Wellness
- **Guided breathing exercises** -- box breathing, 4-7-8, and custom patterns with animated visual guide and haptic pacing
- **Water intake tracker** -- daily hydration goal with quick-add buttons, progress ring, and streak tracking
- **Affirmations** -- curated phase-aware affirmations with favouriting and daily rotation
- **Nutrition tips** -- cycle-phase-specific dietary guidance (iron-rich foods during menstruation, folate during follicular, etc.)
- **Self-care suggestions** -- contextual self-care activities matched to current cycle phase

### Yoga
- **Pose library** -- categorized yoga poses with difficulty levels, benefits, and duration guidance
- **Guided routines** -- pre-built sequences for menstrual relief, prenatal yoga, pelvic floor strengthening, and general wellness
- **Session tracking** -- logs completed yoga sessions with duration and pose count, synced to HealthKit as mindfulness workouts

### On-Device AI Assistant
- **Bloom AI** -- conversational wellness companion powered by Apple FoundationModels framework (iOS 26+)
- **Mode-aware context** -- system prompt adapts to current app mode (cycle/pregnancy/TTC) and cycle phase
- **Streaming responses** -- real-time token streaming with chunked haptic feedback
- **Medical guardrails** -- system prompt explicitly prevents diagnosis, treatment advice, and clinical claims
- **Privacy** -- all inference runs on-device via Apple Intelligence; no API calls, no data transmission

### Partner Sharing
- **6-character share codes** -- generate a code to share cycle/pregnancy status with a partner
- **Partner dashboard** -- read-only view of current phase, upcoming predictions, and symptoms
- **Educational content** -- partner-specific tips for supporting each cycle phase

### Reports & Insights
- **PDF export** -- generates formatted cycle summary and pregnancy reports using PDFKit
- **Cycle analytics** -- average cycle length, period duration trends, symptom frequency heatmaps
- **Phase distribution charts** -- Swift Charts visualization of time spent in each cycle phase
- **Cycle length history** -- bar chart of historical cycle lengths with trend line

### Widgets
- **Cycle Day widget** -- shows current cycle day and phase at a glance
- **Pregnancy Week widget** -- displays current week and baby size comparison
- **Water Intake widget** -- shows daily hydration progress

### Other
- **Sign in with Apple** -- optional authentication with Keychain-backed credential storage
- **HealthKit integration** -- writes menstrual flow, basal body temperature, and workout data
- **Smart notifications** -- period reminders (configurable days before), pill/supplement reminders, water intake reminders, appointment alerts
- **Dark/Light/Auto theming** -- three-mode theme toggle with system-adaptive glassmorphic UI
- **Onboarding flow** -- multi-step setup capturing cycle history, app mode selection, and notification preferences

## Tech Stack

- **UI**: SwiftUI, Swift Charts, PDFKit, AVFoundation (haptics timing)
- **AI/ML**: FoundationModels (Apple Intelligence on-device LLM, iOS 26+)
- **Data**: SwiftData (13 `@Model` entities), Keychain (via Security framework), UserDefaults (via SettingsManager)
- **Apple Services**: HealthKit (menstrual flow, BBT, workouts), UserNotifications (local scheduling), AuthenticationServices (Sign in with Apple), WidgetKit (3 home screen widgets)
- **Observation**: `@Observable` macro (Observation framework) for all ViewModels
- **Third Party**: **None** -- zero external dependencies. No SPM packages, no CocoaPods, no Carthage.

## Architecture

**MVVM + Services + Repository** with protocol-oriented dependency injection.

```
BloomHer/
├── App/                        # App entry point, AppDependencies (DI container)
├── Navigation/                 # MainTabView, HomeToolbarContent, tab routing
├── Models/
│   ├── Enums/                  # 12 enums (AppMode, CyclePhase, Mood, FlowLevel, Symptom, etc.)
│   ├── SwiftData/              # 13 @Model entities (CycleEntry, DailyLog, BBTEntry, etc.)
│   └── Static/                 # Value types (YogaPose, YogaRoutine, NutritionTip, etc.)
├── Repositories/               # 5 repository protocols + implementations
│   ├── RepositoryProtocols.swift   # All protocol definitions
│   ├── CycleRepository.swift       # SwiftData CRUD for cycles & logs
│   ├── PregnancyRepository.swift   # Pregnancy profiles, kicks, contractions
│   ├── TTCRepository.swift         # OPK results, BBT entries
│   ├── WellnessRepository.swift    # Affirmations, water intake
│   └── YogaRepository.swift        # Yoga sessions
├── Services/                   # 8 stateless/stateful services
│   ├── CyclePredictionService.swift    # WMA algorithm (core prediction engine)
│   ├── AIAssistantService.swift        # FoundationModels integration
│   ├── HealthKitService.swift          # HKHealthStore read/write
│   ├── NotificationService.swift       # UNUserNotificationCenter scheduling
│   ├── PartnerSharingService.swift     # Share code generation & validation
│   ├── PDFGeneratorService.swift       # Report generation
│   ├── AuthenticationService.swift     # Sign in with Apple + Keychain
│   └── SettingsManager.swift           # UserDefaults wrapper
├── Features/                   # 13 feature modules, each with View + ViewModel
│   ├── Home/                   # HomeView, PhaseInfoCard, DaysLateBanner
│   ├── Calendar/               # CycleCalendarView, CalendarContainerView
│   ├── Logging/                # DailyLogView, symptom/mood/flow selectors
│   ├── Pregnancy/              # Dashboard, WeekByWeek, KickCounter, Contractions
│   ├── TTC/                    # Dashboard, OPKLogger, BBTChart, FertileWindow
│   ├── Wellness/               # Breathing, WaterTracker, Affirmations, Nutrition
│   ├── Yoga/                   # PoseLibrary, RoutinePlayer, PelvicFloor
│   ├── Insights/               # Charts, analytics, cycle trends
│   ├── Reports/                # PDF generation UI
│   ├── Partner/                # Setup, CodeEntry, Dashboard, Education
│   ├── AI/                     # Chat interface, message bubbles
│   ├── Settings/               # Preferences, account, notifications
│   └── Onboarding/             # Multi-step setup flow
├── DesignSystem/
│   ├── Theme/                  # BloomHerTheme (Colors, Typography, Spacing, Radius, Shadows, Animation, Haptics)
│   ├── Components/             # 14 reusable components (BloomCard, BloomButton, BloomChip, etc.)
│   ├── Modifiers/              # bloomGlass(), bloomBackground(), bloomNavigation(), bloomSheet()
│   └── BloomIcons.swift        # 160+ icon constants registry
├── ContentData/                # 8 static data files (yoga poses, nutrition tips, affirmations, etc.)
├── Utilities/                  # Constants, extensions
└── Resources/                  # Assets.xcassets (167 custom icons, 0 SF Symbols)
```

### Key Architectural Patterns

- **Dependency Injection**: `AppDependencies` is an `@Observable` composition root that holds all repositories and services. ViewModels receive it via `init(dependencies:)`.
- **ViewModels**: All `@Observable @MainActor final class`. Parent views create them with `@State private var viewModel = ViewModel(dependencies:)`.
- **Repositories**: Protocol-first design (`CycleRepositoryProtocol`, etc.) enabling mock injection for previews via `AppDependencies.preview()`.
- **Phase-Aware Theming**: `@Environment(\.currentCyclePhase)` propagates the current cycle phase through the view hierarchy, enabling phase-responsive colors and content.
- **Zero SF Symbols**: Every icon in the app uses custom assets from the `BloomIcons` registry. `BloomImage` convenience view handles resizable rendering with optional template mode.

## On-Device AI

BloomHer integrates Apple's **FoundationModels** framework (iOS 26+) for a fully on-device AI wellness companion:

- **Model**: `SystemLanguageModel.default` -- Apple's on-device foundation model via Apple Intelligence
- **Input**: User text messages + mode-aware system prompt that includes current app mode (cycle/pregnancy/TTC) and cycle phase
- **Output**: Streaming text responses via `LanguageModelSession.streamResponse()` with real-time UI updates and haptic chunk pacing
- **Fallback**: Graceful degradation -- checks `SystemLanguageModel.default.availability` and shows specific error messages for: device not eligible, Apple Intelligence not enabled, model still downloading
- **Context overflow**: Catches `GenerationError.exceededContextWindowSize`, silently creates a fresh `LanguageModelSession` with the same system prompt, and notifies the user
- **Safety**: System prompt enforces: never diagnose, never recommend treatment, always suggest consulting healthcare provider for medical concerns. All AI responses are labelled in the UI.

## Cycle Prediction Algorithm

The core prediction engine (`CyclePredictionService`) implements a **Weighted Moving Average (WMA)** algorithm:

### Parameters
| Parameter | Value | Description |
|-----------|-------|-------------|
| `weightDecayFactor` | 0.85 | Exponential decay -- recent cycles weighted more heavily |
| `maxHistoryForPrediction` | 12 | Maximum cycles considered in prediction window |
| `minCyclesForPrediction` | 3 | Minimum cycles before WMA activates (falls back to 28-day default) |
| `lutealPhaseLength` | 14 days | Fixed luteal phase assumption for ovulation estimation |
| `fertileWindowDays` | 6 | Fertile window span (ovulation day - 5 through ovulation day) |
| `irregularCVThreshold` | 0.15 | Coefficient of variation above which cycles are flagged irregular |
| `defaultLength` | 28 days | Fallback cycle length when insufficient data |
| `defaultPeriodLength` | 5 days | Fallback period duration |

### Algorithm Steps
1. **Derive cycle lengths** from consecutive `CycleEntry.startDate` pairs, clamping to 10-60 day sanity range
2. **Window** to most recent 12 cycles
3. **Apply exponential decay weights**: `w[i] = 0.85^(n-1-i)` where `i=0` is oldest, `i=n-1` is newest (weight 1.0)
4. **Weighted mean** produces predicted cycle length
5. **Period length** = simple mean of last 6 period durations
6. **Ovulation date** = predicted next start - 14 days (luteal phase)
7. **Fertile window** = [ovulation - 5 days, ovulation day]
8. **Irregularity check**: if CV > 0.15, widen fertile window by +/-2 days and set confidence to `.low`
9. **Confidence levels**: <3 cycles = `.low`, 3-5 cycles = `.medium`, >=6 cycles + regular = `.high`

### Phase Detection
Current cycle phase is determined from cycle day relative to predicted parameters:
- **Menstrual**: Day 1 through predicted period length
- **Ovulation**: Ovulation day +/- 1
- **Follicular**: After menstrual, before ovulation window
- **Luteal**: After ovulation through end of cycle

## SwiftData Models

13 persistent `@Model` entities:

| Model | Purpose | Key Fields |
|-------|---------|------------|
| `CycleEntry` | One menstrual cycle | startDate, endDate, cycleLength |
| `DailyLog` | Daily symptom/mood entry | date, flowLevel, mood, symptoms[], crampLevel, temperature, notes |
| `BBTEntry` | Basal body temperature | date, temperature, time |
| `OPKResult` | Ovulation test result | date, level (negative/low/high/peak), photoData |
| `PregnancyProfile` | Active pregnancy | dueDate, lastMenstrualPeriod, babyName, trimester |
| `KickSession` | Fetal movement session | startTime, endTime, kicks[] with timestamps |
| `ContractionEntry` | Labor contraction | startTime, endTime, duration, interval |
| `WeightEntry` | Pregnancy weight log | date, weight, unit |
| `Appointment` | Prenatal appointment | title, date, location, notes, reminderMinutes |
| `WeeklyChecklist` | Pregnancy to-do | week, items[], completedItems[] |
| `Affirmation` | Favourite affirmation | text, category, isFavourite, dateAdded |
| `PartnerShare` | Partner sharing session | shareCode, isActive, createdDate, permissions |
| `YogaSession` | Completed yoga session | date, duration, routineId, posesCompleted |

## HealthKit Integration

Writes three data types (read-only access not requested for privacy):

| HealthKit Type | Identifier | Usage |
|----------------|-----------|-------|
| `HKCategoryType` | `.menstrualFlow` | Syncs period flow level (unspecified/light/medium/heavy) |
| `HKQuantityType` | `.basalBodyTemperature` | Syncs BBT readings in degrees Celsius |
| `HKWorkoutType` | `.workout` | Logs yoga sessions as mindfulness workouts with duration |

## Design System

`BloomHerTheme` provides a comprehensive design token namespace:

- **Colors**: Phase-adaptive palette (`primaryRose`, `accentPeach`, `accentLavender`, `sageGreen`, `warmCream`) + semantic tokens (`textPrimary`, `textSecondary`, `cardBackground`)
- **Typography**: SF Rounded throughout -- 12 type styles from `caption` (11pt) to `cycleDay` (48pt) + specialty styles (`emojiHero` 40pt, `affirmationQuote` 64pt serif, `shareCode` 40pt mono)
- **Spacing**: 4pt grid system (`xxs`=4, `xs`=8, `sm`=12, `md`=16, `lg`=24, `xl`=32, `xxl`=40)
- **Glassmorphism**: `.bloomGlass()` modifier, `GlassCard` component, `BloomHerTheme.Glass` namespace with `.ultraThinMaterial` backgrounds
- **Components**: 14 reusable components -- `BloomCard`, `BloomButton` (with `ScaleButtonStyle`), `BloomChip`, `BloomBanner`, `BloomTextField`, `BloomSlider`, `BloomProgressBar`, `BloomSegmentedControl`, `BloomDatePicker`, `BloomShareSheet`, `BloomMedicalDisclaimer`, and more
- **Icons**: 167 custom icon assets (icons8.com color/96 + cute-clipart styles), zero SF Symbols. `BloomIcons` enum registers all constants. Two-tier rendering: template mode for UI controls, original mode for decorative/feature icons.
- **Haptics**: `BloomHerTheme.Haptics` -- `.light()`, `.medium()`, `.heavy()`, `.selection()`, `.success()`, `.error()` wrappers around `UIImpactFeedbackGenerator`

## Build Stats

| Metric | Count |
|--------|-------|
| Lines of Swift code | 56,223 |
| Total `.swift` files | 203 |
| View files | 64 |
| ViewModel files | 11 |
| SwiftData models | 13 |
| Service files | 8 |
| Repository files | 6 |
| Design system components | 14 |
| Content data files | 8 |
| Custom icon assets | 167 |
| Widget targets | 3 |
| Unit tests | 6 test files |
| External dependencies | **0** |

## Claude Code Prompts

> This app was built using **Claude Code** (Anthropic's CLI agent) as part of an iOS development project.

The entire 56,000+ line codebase was generated through iterative Claude Code sessions covering:
- Phase 0: Foundation (theme, enums, models, repositories, services, navigation)
- Phase 1: Core Cycle (onboarding, logging, calendar, home, settings)
- Phase 2: Pregnancy (dashboard, week-by-week, kick counter, contractions)
- Phase 3: Yoga (routines, pose library, pelvic floor)
- Phase 4: Wellness (affirmations, breathing, water tracker, nutrition)
- Phase 5: TTC & Partner (fertility, BBT, OPK, partner sharing)
- Phase 6: Reports & Polish (insights, charts, PDF reports, widgets, tests)
- Design audit: Apple HIG compliance, glassmorphism, Dynamic Type, accessibility
- Icon integration: 167 custom icons replacing all SF Symbols
- AI integration: FoundationModels on-device assistant with medical guardrails

## What Could Be Improved

1. **Test coverage is minimal** -- only 6 test files exist (`CyclePredictionServiceTests`, `WeightedMovingAverageTests`, `CycleRepositoryTests`, `HomeViewModelTests`, `PartnerSharingServiceTests`, `EnumTests`). The 64 views and 11 ViewModels have no UI or snapshot tests. Critical paths like the fertile window calculation and irregularity detection need edge-case coverage.

2. **Partner sharing is local-only** -- `PartnerSharingService` generates share codes and validates them, but the sharing is entirely in-memory within the same device. There is no CloudKit, server, or peer-to-peer transport. The partner feature would need a real backend (CloudKit private database or CKShare) to work across devices.

3. **HealthKit is write-only** -- the app writes menstrual flow, BBT, and workouts to HealthKit but never reads existing HealthKit data. Importing historical menstrual data from Apple Health would improve prediction accuracy for new users switching from other apps.

4. **No localization** -- all strings are hardcoded in English. The 8 content data files (yoga poses, nutrition tips, pregnancy week descriptions, affirmations) contain substantial educational text that would need professional medical translation.

5. **AI assistant requires iOS 26+** -- the FoundationModels framework is only available on iOS 26 with Apple Intelligence-capable devices. Users on older devices or non-eligible hardware get no AI features. A lightweight rule-based fallback could provide basic wellness responses.

## Privacy

BloomHer is built on a **zero-telemetry, device-only** architecture:

- All health data stored locally via SwiftData
- No analytics SDKs, no crash reporting services, no network calls
- AI inference runs entirely on-device via Apple Intelligence
- HealthKit data is write-only (app never reads user's existing health data)
- Authentication uses Sign in with Apple (credentials stored in device Keychain)
- No third-party dependencies that could exfiltrate data

## Requirements

- iOS 17.0+ (core features)
- iOS 26.0+ (Bloom AI assistant -- FoundationModels framework)
- Apple Intelligence-capable device (for AI features)
- Xcode 26+ for building

## App Store

- Status: In development
- Link: --
- Downloads: --

## License

MIT

---

*Built with [Claude Code](https://claude.ai/claude-code) by Anthropic*
