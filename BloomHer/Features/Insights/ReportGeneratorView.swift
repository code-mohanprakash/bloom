//
//  ReportGeneratorView.swift
//  BloomHer
//
//  Provides two report types — Cycle Summary and Pregnancy Summary — that
//  are generated as PDF data via `PDFGeneratorService` and shared using
//  the system share sheet (`ShareLink` / `ActivityViewController`).
//

import SwiftUI

// MARK: - ReportGeneratorView

/// Lets the user generate and share a branded PDF report.
///
/// Layout:
/// 1. Cycle Summary Report card — generates a PDF from all cycles and logs.
/// 2. Pregnancy Summary Report card — generates a PDF for the active pregnancy.
/// 3. Medical disclaimer footer.
///
/// Tapping a card triggers PDF generation (with a loading overlay), then
/// presents the system share sheet containing the resulting `Data`.
struct ReportGeneratorView: View {

    // MARK: - State

    let viewModel: InsightsViewModel

    @State private var isGeneratingCycle:     Bool = false
    @State private var isGeneratingPregnancy: Bool = false
    @State private var cyclePDFData:          Data?
    @State private var pregnancyPDFData:      Data?
    @State private var showCycleShare:        Bool = false
    @State private var showPregnancyShare:    Bool = false
    @State private var errorMessage:          String?
    @State private var showError:             Bool = false

    // MARK: - Dependencies (held locally for PDF generation)

    private let pdfGenerator: PDFGeneratorServiceProtocol
    private let pregnancyRepository: PregnancyRepositoryProtocol

    // MARK: - Init

    init(viewModel: InsightsViewModel, dependencies: AppDependencies) {
        self.viewModel            = viewModel
        self.pdfGenerator         = dependencies.pdfGenerator
        self.pregnancyRepository  = dependencies.pregnancyRepository
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                reportCards
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                disclaimerCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 3)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Reports")
        .alert("Report Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Something went wrong preparing your report.")
        })
        // Cycle PDF share sheet
        .sheet(isPresented: $showCycleShare, onDismiss: { cyclePDFData = nil }) {
            if let data = cyclePDFData {
                ActivityViewController(activityItems: [data])
                    .bloomSheet()
            }
        }
        // Pregnancy PDF share sheet
        .sheet(isPresented: $showPregnancyShare, onDismiss: { pregnancyPDFData = nil }) {
            if let data = pregnancyPDFData {
                ActivityViewController(activityItems: [data])
                    .bloomSheet()
            }
        }
    }

    // MARK: - Report Cards

    private var reportCards: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Text("Generate Report")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .staggeredAppear(index: 0)

            cycleSummaryCard
                .staggeredAppear(index: 1)

            pregnancySummaryCard
                .staggeredAppear(index: 2)
        }
    }

    // MARK: - Cycle Summary Card

    private var cycleSummaryCard: some View {
        Button {
            generateCycleReport()
        } label: {
            BloomCard {
                HStack(spacing: BloomHerTheme.Spacing.md) {
                    reportIconCircle(
                        icon:  BloomIcons.chartReport,
                        color: BloomHerTheme.Colors.primaryRose
                    )

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        Text("Cycle Summary Report")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Your cycle history, symptoms, and mood data in a shareable PDF")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    if isGeneratingCycle {
                        ProgressView()
                            .tint(BloomHerTheme.Colors.primaryRose)
                    } else {
                        Image(BloomIcons.share)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                }
                .padding(BloomHerTheme.Spacing.md)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isGeneratingCycle || isGeneratingPregnancy)
    }

    // MARK: - Pregnancy Summary Card

    private var pregnancySummaryCard: some View {
        Button {
            generatePregnancyReport()
        } label: {
            BloomCard {
                HStack(spacing: BloomHerTheme.Spacing.md) {
                    reportIconCircle(
                        icon:  BloomIcons.heartMonitor,
                        color: BloomHerTheme.Colors.sageGreen
                    )

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        Text("Pregnancy Summary Report")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Pregnancy progress, weight tracker, and appointments as a PDF")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    if isGeneratingPregnancy {
                        ProgressView()
                            .tint(BloomHerTheme.Colors.sageGreen)
                    } else {
                        Image(BloomIcons.share)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }
                }
                .padding(BloomHerTheme.Spacing.md)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isGeneratingCycle || isGeneratingPregnancy)
    }

    // MARK: - Icon Helper

    private func reportIconCircle(icon: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 48, height: 48)
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }

    // MARK: - Disclaimer Card

    private var disclaimerCard: some View {
        BloomCard {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.info)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(BloomHerTheme.Colors.info)
                    .padding(.top, BloomHerTheme.Spacing.xxxs)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Medical Disclaimer")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    Text(
                        "Reports generated by BloomHer are for personal reference only " +
                        "and do not constitute medical advice. Please consult a qualified " +
                        "healthcare provider for any health concerns."
                    )
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Generation Actions

    private func generateCycleReport() {
        guard !isGeneratingCycle else { return }
        isGeneratingCycle = true
        BloomHerTheme.Haptics.medium()

        Task.detached(priority: .userInitiated) {
            let data = await MainActor.run {
                self.pdfGenerator.generateCycleSummaryPDF(
                    cycles: self.viewModel.cycles,
                    logs:   self.viewModel.dailyLogs
                )
            }
            await MainActor.run {
                self.cyclePDFData      = data
                self.isGeneratingCycle = false
                self.showCycleShare    = true
                BloomHerTheme.Haptics.success()
            }
        }
    }

    private func generatePregnancyReport() {
        guard !isGeneratingPregnancy else { return }

        guard let activePregnancy = pregnancyRepository.fetchActivePregnancy() else {
            errorMessage  = "No active pregnancy found. Please set up pregnancy tracking first."
            showError     = true
            BloomHerTheme.Haptics.error()
            return
        }

        isGeneratingPregnancy = true
        BloomHerTheme.Haptics.medium()

        Task.detached(priority: .userInitiated) {
            let data = await MainActor.run {
                self.pdfGenerator.generatePregnancySummaryPDF(pregnancy: activePregnancy)
            }
            await MainActor.run {
                self.pregnancyPDFData      = data
                self.isGeneratingPregnancy = false
                self.showPregnancyShare    = true
                BloomHerTheme.Haptics.success()
            }
        }
    }
}

// MARK: - ActivityViewController

/// A thin UIKit wrapper that presents `UIActivityViewController` for data sharing.
///
/// Used to present the share sheet with the generated PDF `Data` so the user
/// can save to Files, AirDrop, or any other system share target.
private struct ActivityViewController: UIViewControllerRepresentable {

    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems:  activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

// MARK: - Preview

#Preview("Report Generator") {
    let dependencies = AppDependencies.preview()
    return NavigationStack {
        ReportGeneratorView(
            viewModel:    InsightsViewModel(dependencies: dependencies),
            dependencies: dependencies
        )
    }
    .environment(\.currentCyclePhase, .follicular)
}
