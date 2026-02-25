//
//  MedicalDisclaimerView.swift
//  BloomHer
//
//  Full medical disclaimer with source attribution list.
//  Scrollable. Navigation-pushed from Settings > About.
//

import SwiftUI

// MARK: - MedicalDisclaimerView

/// Displays the full medical disclaimer and source attribution for BloomHer.
///
/// This view is a legal and ethical requirement. It makes clear that BloomHer
/// is an informational tool and not a substitute for professional medical advice.
/// Sources are listed with their institutional affiliations.
struct MedicalDisclaimerView: View {

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                disclaimerHeader
                disclaimerBody
                Divider()
                    .background(BloomHerTheme.Colors.textTertiary.opacity(0.3))
                sourcesSection
                Divider()
                    .background(BloomHerTheme.Colors.textTertiary.opacity(0.3))
                emergencyNote
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .bloomBackground()
        .bloomNavigation("Medical Disclaimer")
    }

    // MARK: - Header

    private var disclaimerHeader: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.stethoscope)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                Text("Medical Disclaimer")
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }
            Text("Please read this notice carefully before using BloomHer.")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Disclaimer Body

    private var disclaimerBody: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                ForEach(disclaimerParagraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Sources Section

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.books)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("Medical Sources & References")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }

            Text("BloomHer's cycle predictions and health content are informed by the following peer-reviewed sources and clinical guidelines:")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(medicalSources.indices, id: \.self) { index in
                sourceRow(source: medicalSources[index], index: index + 1)
            }
        }
    }

    private func sourceRow(source: MedicalSource, index: Int) -> some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
            Text("\(index).")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .frame(width: 18, alignment: .trailing)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(source.title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(source.institution)
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomColors.primaryRose)
                if let year = source.year {
                    Text(year)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
            }
        }
        .padding(.vertical, BloomHerTheme.Spacing.xxs)
    }

    // MARK: - Emergency Note

    private var emergencyNote: some View {
        BloomCard {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.warning)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BloomColors.menstrual)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("In a medical emergency")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("If you are experiencing a medical emergency, contact your local emergency services (e.g., 999 in the UK or 911 in the US) immediately. BloomHer cannot provide emergency medical assistance.")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .environment(\.currentCyclePhase, .menstrual)
    }

    // MARK: - Disclaimer Paragraphs

    private let disclaimerParagraphs: [String] = [
        "BloomHer is designed for informational and educational purposes only. The content, features, and functionality of this app do not constitute medical advice, diagnosis, or treatment.",

        "The cycle predictions, phase descriptions, symptom correlations, and health tips provided by BloomHer are based on generalised statistical models and published research. They are not personalised medical recommendations and may not be accurate for every individual.",

        "Menstrual cycle length, ovulation timing, and symptom presentation vary significantly between individuals and can be influenced by many factors including stress, illness, medication, and underlying health conditions.",

        "BloomHer should not be used as a contraceptive method or as a means to diagnose, treat, cure, or prevent any medical condition, including pregnancy.",

        "Always consult a qualified healthcare professional — such as a GP, gynaecologist, or midwife — for personalised medical advice, especially if you experience irregular cycles, severe pain, unexpected bleeding, or any other concerning symptoms.",

        "The developers and publishers of BloomHer accept no liability for decisions made based on the information provided by this app."
    ]

    // MARK: - Sources Data

    private struct MedicalSource {
        let title:       String
        let institution: String
        let year:        String?
    }

    private let medicalSources: [MedicalSource] = [
        MedicalSource(
            title:       "Menstrual Cycle: Normal Characteristics and Common Disorders",
            institution: "National Health Service (NHS), UK",
            year:        "2023"
        ),
        MedicalSource(
            title:       "Committee Opinion: Menstruation in Girls and Adolescents",
            institution: "American College of Obstetricians and Gynecologists (ACOG)",
            year:        "2015, Reaffirmed 2022"
        ),
        MedicalSource(
            title:       "Fertility Awareness Methods: Effectiveness and Reliability",
            institution: "World Health Organization (WHO)",
            year:        "2018"
        ),
        MedicalSource(
            title:       "The Luteal Phase: Physiology and Clinical Importance",
            institution: "Human Reproduction Update, Oxford Academic",
            year:        "2020"
        ),
        MedicalSource(
            title:       "Premenstrual Syndrome and Premenstrual Dysphoric Disorder",
            institution: "Royal College of Obstetricians and Gynaecologists (RCOG)",
            year:        "2019"
        ),
        MedicalSource(
            title:       "Cycle Variability and Predictive Modelling in Women's Health Apps",
            institution: "Journal of Medical Internet Research",
            year:        "2019"
        )
    ]
}

// MARK: - Preview

#Preview("Medical Disclaimer") {
    NavigationStack {
        MedicalDisclaimerView()
    }
    .environment(AppDependencies.preview())
}
