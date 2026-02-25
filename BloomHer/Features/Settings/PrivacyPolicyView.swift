//
//  PrivacyPolicyView.swift
//  BloomHer
//
//  Comprehensive privacy policy compliant with:
//  • GDPR (EU / EEA / UK)
//  • CCPA (California, USA)
//  • Privacy Act 1988 (Australia)
//  • PIPEDA (Canada)
//  • Apple App Store Review Guidelines
//
//  Verified against actual data-flow audit:
//  — Zero external servers or third-party SDKs
//  — All health data stored on-device only
//  — Optional iCloud sync via Apple's encrypted CloudKit
//  — On-device AI via Apple Intelligence (no data leaves device)
//

import SwiftUI

// MARK: - PrivacyPolicyView

struct PrivacyPolicyView: View {

    private let effectiveDate = "21 February 2026"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {

                headerCard
                    .padding(.top, BloomHerTheme.Spacing.xs)

                policySection("1", "Who We Are",          whoWeAre)
                policySection("2", "Data We Collect",     dataWeCollect)
                policySection("3", "Data We Do Not Collect", dataWeDoNotCollect)
                policySection("4", "HealthKit Integration", healthKit)
                policySection("5", "iCloud Sync (Optional)", iCloudSync)
                policySection("6", "AI Assistant — On-Device Only", aiAssistant)
                policySection("7", "Partner Sharing",     partnerSharing)
                policySection("8", "Sign in with Apple",  signInWithApple)
                policySection("9", "Local Notifications", localNotifications)
                policySection("10", "Children's Privacy", childrensPrivacy)
                policySection("11", "Your Rights",        yourRights)
                policySection("12", "Data Retention & Deletion", dataRetention)
                policySection("13", "Changes to This Policy", policyChanges)
                policySection("14", "Contact Us",         contactUs)

                Text("Effective \(effectiveDate)")
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, BloomHerTheme.Spacing.xl)
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .bloomBackground()
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.sm) {
                BloomImage(BloomIcons.lockShield, size: 44)

                Text("Your privacy is our foundation")
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("BloomHer is built privacy-first. Your health data lives on your device — it is never sold, shared, or sent to any external server.")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: BloomHerTheme.Spacing.xl) {
                    trustBadge(icon: BloomIcons.checkmarkShield, label: "No servers")
                    trustBadge(icon: BloomIcons.checkmarkShield, label: "No tracking")
                    trustBadge(icon: BloomIcons.checkmarkShield, label: "No ads")
                }
                .padding(.top, BloomHerTheme.Spacing.xs)
            }
            .frame(maxWidth: .infinity)
            .padding(BloomHerTheme.Spacing.lg)
        }
    }

    private func trustBadge(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            BloomImage(icon, size: 22, color: BloomHerTheme.Colors.sageGreen)
            Text(label)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Section Builder

    private func policySection(_ number: String, _ title: String, _ content: String) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack(alignment: .center, spacing: BloomHerTheme.Spacing.sm) {
                Text(number)
                    .font(BloomHerTheme.Typography.caption2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(BloomHerTheme.Colors.primaryRose))

                Text(title)
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }

            Text(content)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BloomHerTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        )
    }

    // MARK: - Policy Content

    private var whoWeAre: String {
        """
        BloomHer is a women's health and wellness application. This Privacy Policy describes how data is handled when you use the app.

        Controller: BloomHer App (contact details below)
        Effective date: \(effectiveDate)
        Jurisdiction: This policy applies globally, with additional provisions for EU/EEA, UK, California, Australian and Canadian users.
        """
    }

    private var dataWeCollect: String {
        """
        All data is stored locally on your device. Nothing is sent to any BloomHer server. Data is collected only when you choose to enter it:

        • Display name (optional)
        • Cycle records — period start/end dates, cycle length, daily logs (flow, mood, symptoms, energy, sleep, water intake, notes)
        • Pregnancy information — LMP date, due date, baby name (optional), weight entries, kick sessions, contractions, appointments
        • Fertility data — basal body temperature, OPK results, fertile window records
        • Wellness entries — affirmations, gratitude notes
        • Yoga and exercise sessions
        • Partner sharing preferences (device-local only)
        • App preferences — notification settings, theme, iCloud sync toggle, default cycle length

        None of this data is transmitted to BloomHer or any third party.
        """
    }

    private var dataWeDoNotCollect: String {
        """
        BloomHer explicitly does NOT collect, process, or transmit:

        • Your precise or approximate location
        • Advertising identifiers (IDFA / IDFV used for tracking)
        • Device fingerprinting data
        • Crash or usage analytics sent to any server
        • Behavioural or session tracking data
        • Your date of birth or age
        • Data through any third-party SDKs — none are included in this app
        • Payment information — all purchases are handled entirely by Apple

        BloomHer contains zero third-party analytics, advertising, or tracking SDKs.
        """
    }

    private var healthKit: String {
        """
        HealthKit integration is fully optional. When you grant permission, BloomHer may:

        Read: Menstrual flow records, basal body temperature, sleep analysis
        Write: Menstrual flow records, basal body temperature, yoga/mindfulness workout sessions

        HealthKit data is governed by Apple's Privacy Policy and is never used for advertising or sold to third parties. BloomHer accesses HealthKit only in response to explicit user actions.

        Revoke at any time: iOS Settings → Privacy & Security → Health → BloomHer.
        """
    }

    private var iCloudSync: String {
        """
        iCloud sync is disabled by default. If you enable it in Settings → Privacy & Data:

        • Your health data is synced via Apple's CloudKit private database
        • All data is end-to-end encrypted — Apple cannot read its contents
        • BloomHer has no access to your iCloud data; Apple manages the infrastructure
        • You can disable sync or delete your iCloud data at any time

        Apple's iCloud Privacy Policy governs CloudKit-synced data (apple.com/legal/privacy).

        Legal basis (GDPR): Consent — you may withdraw consent by disabling iCloud sync in Settings at any time.
        """
    }

    private var aiAssistant: String {
        """
        Bloom AI is powered entirely by Apple Intelligence (FoundationModels framework, iOS 26+). All inference runs on your device.

        • No conversation data is sent to BloomHer or any external server
        • Chat history is not stored persistently — messages exist only in the active session and are cleared when you close the chat
        • Apple Intelligence processes your queries using on-device models
        • The AI is for educational wellness context only — it does not provide medical diagnosis or treatment

        Apple's AI privacy practices apply (apple.com/legal/privacy).
        """
    }

    private var partnerSharing: String {
        """
        Partner sharing is entirely local — BloomHer does not operate a server for this feature.

        • A 6-character share code is generated on your device
        • Shared data (mood, cycle phase, pregnancy week) is stored locally on your device
        • No partner data is transmitted to any external server
        • Partner activity logs are stored in on-device app storage only

        You can disable or reset partner sharing at any time in Settings → Partner.
        """
    }

    private var signInWithApple: String {
        """
        Sign in with Apple is optional. If you choose to use it:

        • Your Apple credential is stored in your device's secure Keychain
        • BloomHer receives only an opaque Apple-generated user identifier — not your Apple ID email, unless you explicitly choose to share it
        • No sign-in data is sent to BloomHer servers
        • Authentication is managed entirely by Apple's ASAuthorizationAppleIDProvider framework

        Revoke at any time: iOS Settings → [Your Name] → Password & Security → Apps Using Apple ID → BloomHer → Stop Using Apple ID.
        """
    }

    private var localNotifications: String {
        """
        All notifications are local — scheduled on your device via iOS's UNUserNotificationCenter. No push notification server is used by BloomHer.

        Notification types (all opt-in):
        • Period and ovulation reminders
        • Supplement or medication reminders
        • Appointment reminders
        • Water intake reminders

        Manage or disable: iOS Settings → Notifications → BloomHer, or Settings → Notifications within the app.
        """
    }

    private var childrensPrivacy: String {
        """
        BloomHer is intended for users aged 17 and older and is rated 17+ in the App Store. The app is not directed at children under 13 (or under 16 in the EU, per GDPR Article 8).

        We do not knowingly collect personal information from children. If you believe a child has entered personal information in the app, please contact mohanprakash462@gmail.com and we will assist with removal.
        """
    }

    private var yourRights: String {
        """
        Because BloomHer stores data locally on your device, you can exercise most rights directly in the app. For any request requiring our assistance, contact mohanprakash462@gmail.com.

        ─── GDPR (EU / EEA / UK residents) ───
        • Access — view all data stored about you (it is visible within the app)
        • Rectification — correct any entry directly in the app
        • Erasure — delete all data via Settings → Privacy & Data → Delete All My Data
        • Restriction — disable iCloud sync to restrict cloud processing
        • Portability — export your data from within the app
        • Object — you may object to processing; as no profiling or automated decisions occur, this is largely inapplicable
        • Withdraw consent — revoke HealthKit or iCloud permissions in iOS Settings at any time
        EU/UK residents may lodge a complaint with their national Data Protection Authority (DPA) or the UK ICO (ico.org.uk).

        ─── CCPA (California residents) ───
        • Right to Know — all categories of personal information are disclosed in Section 2 of this policy
        • Right to Delete — use Settings → Privacy & Data → Delete All My Data
        • Right to Opt-Out of Sale — BloomHer does not sell your personal information
        • Right to Non-Discrimination — we will not discriminate for exercising your privacy rights

        ─── Privacy Act 1988 (Australian residents) ───
        • Access and correction rights apply; contact mohanprakash462@gmail.com for assistance

        ─── PIPEDA (Canadian residents) ───
        • Right to access and correct personal information held about you
        """
    }

    private var dataRetention: String {
        """
        You are in full control of data retention. BloomHer does not retain copies of your data on any server.

        • Data persists on your device until you delete the app or use the in-app deletion feature
        • Deleting the app removes all local data from your device
        • If iCloud sync is enabled, use Settings → Privacy & Data → Delete All My Data to also remove iCloud copies
        • Individual entries (logs, journal notes, appointments, etc.) can be deleted directly within the app at any time

        There is no server-side data to request deletion of — it does not exist.
        """
    }

    private var policyChanges: String {
        """
        We may update this Privacy Policy as the app evolves. When changes occur:

        • The "Effective Date" at the top of this policy will be updated
        • Material changes will be communicated via an in-app notification
        • Continued use of the app after the effective date constitutes acceptance of the revised policy

        The current version is always available in the app: Settings → Privacy Policy.
        """
    }

    private var contactUs: String {
        """
        For privacy questions, rights requests, or concerns:

        Email: mohanprakash462@gmail.com
        Response time: We aim to respond within 30 days (as required by GDPR Article 12). Mark urgent data subject requests "URGENT — DATA REQUEST."

        Supervisory Authorities:
        • EU / EEA — contact your national Data Protection Authority (DPA)
        • UK — Information Commissioner's Office: ico.org.uk
        • Australia — Office of the Australian Information Commissioner: oaic.gov.au
        • California — California Privacy Protection Agency: cppa.ca.gov
        • Canada — Office of the Privacy Commissioner: priv.gc.ca
        """
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
    .environment(AppDependencies.preview())
    .modelContainer(DataConfiguration.makeInMemoryContainer())
}
