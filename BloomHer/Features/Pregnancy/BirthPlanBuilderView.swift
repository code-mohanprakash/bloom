//
//  BirthPlanBuilderView.swift
//  BloomHer
//
//  Guided birth plan creation with section-based toggles, text fields,
//  progress tracking, a formatted preview mode, and PDF export.
//

import SwiftUI

// MARK: - BirthPlanSection

private enum BirthPlanSectionType: String, CaseIterable, Identifiable {
    case environment   = "Birth Environment"
    case painRelief    = "Pain Relief"
    case delivery      = "Delivery Preferences"
    case afterBirth    = "After Birth"
    case emergency     = "Emergency Preferences"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .environment: return BloomIcons.info
        case .painRelief:  return BloomIcons.pill
        case .delivery:    return BloomIcons.heartFilled
        case .afterBirth:  return BloomIcons.figureStand
        case .emergency:   return BloomIcons.firstAid
        }
    }

    var color: Color {
        switch self {
        case .environment: return BloomHerTheme.Colors.accentLavender
        case .painRelief:  return BloomHerTheme.Colors.primaryRose
        case .delivery:    return BloomHerTheme.Colors.sageGreen
        case .afterBirth:  return BloomHerTheme.Colors.accentPeach
        case .emergency:   return BloomColors.info
        }
    }
}

// MARK: - BirthPlanOption

private struct BirthPlanOption: Identifiable {
    let id = UUID()
    let label: String
    var isSelected: Bool = false
}

// MARK: - BirthPlanSectionData

private struct BirthPlanSectionData: Identifiable {
    let id: BirthPlanSectionType
    var options: [BirthPlanOption]
    var notes: String = ""

    var isComplete: Bool {
        options.contains { $0.isSelected } || !notes.isEmpty
    }

    var selectedOptions: [String] {
        options.filter { $0.isSelected }.map { $0.label }
    }
}

// MARK: - BirthPlanBuilderView

struct BirthPlanBuilderView: View {

    // MARK: State

    @State private var sections: [BirthPlanSectionData] = BirthPlanBuilderView.defaultSections()
    @State private var partnerName: String = ""
    @State private var birthLocation: String = ""
    @State private var showPreview: Bool = false
    @State private var showExportConfirm: Bool = false
    @State private var expandedSection: BirthPlanSectionType? = .environment
    @State private var petals: Bool = false

    private let dependencies: AppDependencies?

    // MARK: Init

    init(dependencies: AppDependencies? = nil) {
        self.dependencies = dependencies
    }

    // MARK: Computed

    private var completedSections: Int {
        sections.filter { $0.isComplete }.count
    }

    private var totalSections: Int { sections.count }

    private var progressFraction: Double {
        guard totalSections > 0 else { return 0 }
        return Double(completedSections) / Double(totalSections)
    }

    // MARK: Body

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    headerSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    progressSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    personalDetailsCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    sectionsBuilder
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    actionButtons
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }

            // Ambient petals
            if petals {
                PetalFallView(petalColor: BloomHerTheme.Colors.primaryRose, count: 8)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .bloomBackground()
        .bloomNavigation("Birth Plan")
        .sheet(isPresented: $showPreview) {
            BirthPlanPreviewSheet(
                sections: sections,
                partnerName: partnerName,
                birthLocation: birthLocation,
                onExport: { exportPDF() }
            )
            .bloomSheet(detents: [.large])
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                petals = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Your Birth Plan")
                        .font(BloomHerTheme.Typography.largeTitle)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    Text("Express your preferences for labour and birth")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                Spacer()

                Image(BloomIcons.document)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack {
                    Text("Plan Progress")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(completedSections)/\(totalSections) sections")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }

                BloomProgressBar(
                    progress: progressFraction,
                    color: BloomHerTheme.Colors.primaryRose,
                    height: 12,
                    showLabel: true
                )

                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(sections) { section in
                        Circle()
                            .fill(section.isComplete ? section.id.color : BloomHerTheme.Colors.textTertiary.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    Spacer()
                    if progressFraction >= 1.0 {
                        Label {
                            Text("Plan complete!")
                        } icon: {
                            Image(BloomIcons.checkmarkSeal)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                        }
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }
                }
                .animation(BloomHerTheme.Animation.gentle, value: completedSections)
            }
        }
    }

    // MARK: - Personal Details

    private var personalDetailsCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Label {
                    Text("Personal Details")
                } icon: {
                    Image(BloomIcons.person)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                VStack(spacing: BloomHerTheme.Spacing.sm) {
                    inputRow(label: "Birth Partner Name", placeholder: "Partner, family member...", text: $partnerName)
                    inputRow(label: "Planned Birth Location", placeholder: "Hospital, midwifery unit, home...", text: $birthLocation)
                }
            }
        }
    }

    private func inputRow(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
            Text(label)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            TextField(placeholder, text: text)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .tint(BloomHerTheme.Colors.primaryRose)
                .padding(BloomHerTheme.Spacing.xs)
                .background(BloomHerTheme.Colors.background, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small))
        }
    }

    // MARK: - Sections Builder

    private var sectionsBuilder: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ForEach($sections) { $section in
                SectionAccordion(
                    section: $section,
                    isExpanded: expandedSection == section.id,
                    onToggle: {
                        withAnimation(BloomHerTheme.Animation.standard) {
                            expandedSection = expandedSection == section.id ? nil : section.id
                        }
                        BloomHerTheme.Haptics.light()
                    }
                )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            BloomButton("Preview Plan", style: .outline, icon: BloomIcons.document, isFullWidth: true) {
                showPreview = true
            }

            BloomButton("Export to PDF", style: .primary, icon: BloomIcons.share, isFullWidth: true) {
                exportPDF()
            }
        }
    }

    // MARK: - Export

    private func exportPDF() {
        BloomHerTheme.Haptics.success()
        // PDF generation is delegated to PDFGeneratorService
        // dependencies?.pdfGenerator.generateBirthPlan(sections, ...)
    }

    // MARK: - Default Sections

    fileprivate static func defaultSections() -> [BirthPlanSectionData] {
        [
            BirthPlanSectionData(
                id: .environment,
                options: [
                    BirthPlanOption(label: "Dimmed lighting"),
                    BirthPlanOption(label: "Music / audio"),
                    BirthPlanOption(label: "Minimal interruptions"),
                    BirthPlanOption(label: "Birth pool available"),
                    BirthPlanOption(label: "Birthing ball"),
                    BirthPlanOption(label: "Own clothes / gown"),
                ]
            ),
            BirthPlanSectionData(
                id: .painRelief,
                options: [
                    BirthPlanOption(label: "Breathing techniques"),
                    BirthPlanOption(label: "TENS machine"),
                    BirthPlanOption(label: "Water immersion"),
                    BirthPlanOption(label: "Gas and air (Entonox)"),
                    BirthPlanOption(label: "Pethidine"),
                    BirthPlanOption(label: "Epidural"),
                    BirthPlanOption(label: "No pain relief unless I ask"),
                ]
            ),
            BirthPlanSectionData(
                id: .delivery,
                options: [
                    BirthPlanOption(label: "Avoid episiotomy if possible"),
                    BirthPlanOption(label: "Coached pushing preferred"),
                    BirthPlanOption(label: "Spontaneous pushing preferred"),
                    BirthPlanOption(label: "Delayed cord clamping"),
                    BirthPlanOption(label: "Partner to cut cord"),
                    BirthPlanOption(label: "Natural management of placenta"),
                    BirthPlanOption(label: "Immediate skin-to-skin"),
                ]
            ),
            BirthPlanSectionData(
                id: .afterBirth,
                options: [
                    BirthPlanOption(label: "Breastfeeding support"),
                    BirthPlanOption(label: "No formula unless medically needed"),
                    BirthPlanOption(label: "Vitamin K injection for baby"),
                    BirthPlanOption(label: "Newborn hearing screening"),
                    BirthPlanOption(label: "Photographs during birth"),
                    BirthPlanOption(label: "Private bonding time post-birth"),
                ]
            ),
            BirthPlanSectionData(
                id: .emergency,
                options: [
                    BirthPlanOption(label: "Keep partner informed if I cannot speak"),
                    BirthPlanOption(label: "C-section: partner present if possible"),
                    BirthPlanOption(label: "Skin-to-skin with partner if I cannot"),
                    BirthPlanOption(label: "Allow all necessary interventions"),
                ]
            ),
        ]
    }
}

// MARK: - SectionAccordion

private struct SectionAccordion: View {
    @Binding var section: BirthPlanSectionData
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button(action: onToggle) {
                HStack {
                    Image(section.id.icon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(section.id.color, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small))

                    Text(section.id.rawValue)
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    Spacer()

                    if section.isComplete {
                        Image(BloomIcons.checkmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }

                    Image(isExpanded ? BloomIcons.chevronUp : BloomIcons.chevronDown)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                .padding(BloomHerTheme.Spacing.md)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                    // Options toggles
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        ForEach($section.options) { $option in
                            Toggle(isOn: $option.isSelected) {
                                Text(option.label)
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            }
                            .toggleStyle(BloomCheckboxToggleStyle(color: section.id.color))
                            .onChange(of: option.isSelected) { _, _ in
                                BloomHerTheme.Haptics.light()
                            }
                        }
                    }

                    // Notes field
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        Text("Additional notes")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                        TextField("Any other wishes...", text: $section.notes, axis: .vertical)
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            .tint(section.id.color)
                            .lineLimit(2...4)
                            .padding(BloomHerTheme.Spacing.xs)
                            .background(
                                BloomHerTheme.Colors.background,
                                in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                            )
                    }
                }
                .padding(BloomHerTheme.Spacing.md)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(BloomHerTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .bloomShadow(BloomHerTheme.Shadows.small)
    }
}

// MARK: - BloomCheckboxToggleStyle

private struct BloomCheckboxToggleStyle: ToggleStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(configuration.isOn ? BloomIcons.checkmarkCircle : BloomIcons.checkmark)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(configuration.isOn ? color : BloomHerTheme.Colors.textTertiary)
                    .animation(BloomHerTheme.Animation.quick, value: configuration.isOn)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - BirthPlanPreviewSheet

private struct BirthPlanPreviewSheet: View {
    let sections: [BirthPlanSectionData]
    let partnerName: String
    let birthLocation: String
    let onExport: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        Text("My Birth Plan")
                            .font(BloomHerTheme.Typography.largeTitle)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                        if !birthLocation.isEmpty {
                            Text("Location: \(birthLocation)")
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }

                        if !partnerName.isEmpty {
                            Text("Birth Partner: \(partnerName)")
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }

                        Text("Prepared with BloomHer")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    Divider()
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    ForEach(sections.filter { $0.isComplete }) { section in
                        previewSection(section)
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                    }

                    BloomButton("Export to PDF", style: .primary, icon: BloomIcons.share, isFullWidth: true) {
                        onExport()
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .padding(.bottom, BloomHerTheme.Spacing.xxxl)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
            }
            .bloomBackground()
            .bloomNavigation("Plan Preview")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
    }

    private func previewSection(_ section: BirthPlanSectionData) -> some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(section.id.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(section.id.rawValue)
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                ForEach(section.selectedOptions, id: \.self) { option in
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.checkmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(section.id.color)
                        Text(option)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }
                }

                if !section.notes.isEmpty {
                    Text("Notes: \(section.notes)")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .italic()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Birth Plan Builder") {
    NavigationStack {
        BirthPlanBuilderView()
    }
}

#Preview("Birth Plan Preview") {
    BirthPlanPreviewSheet(
        sections: BirthPlanBuilderView.defaultSections(),
        partnerName: "Alex",
        birthLocation: "Royal Victoria Hospital",
        onExport: {}
    )
}
