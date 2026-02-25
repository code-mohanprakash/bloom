//
//  AppIconView.swift
//  BloomHer
//
//  A SwiftUI representation of the BloomHer app icon.
//  Renders an abstract dove centred on a warm rose-cream gradient
//  background.  Use this as the source design for exporting raster PNGs
//  via Icon Composer or Xcode's asset catalog.
//
//  To export: wrap in a 1024×1024 frame and use ImageRenderer.
//

import SwiftUI

// MARK: - AppIconView

/// The BloomHer app icon rendered in SwiftUI.
///
/// This view is designed at 1024×1024 to match Apple's app icon spec.
/// It features the dove icon on a warm rose gradient
/// background, representing hope, wellness, and feminine strength.
struct AppIconView: View {

    let size: CGFloat

    var body: some View {
        ZStack {
            // Background — warm rose-to-cream radial gradient
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FFD6CC"),
                            BloomColors.primaryRose,
                            Color(hex: "#C8395A")
                        ],
                        center: .init(x: 0.38, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.72
                    )
                )

            // Soft inner glow to lift the dove
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: size * 0.60, height: size * 0.60)
                .blur(radius: size * 0.06)

            // Dove icon with shadow for depth
            Image(BloomIcons.doveHero)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.56, height: size * 0.56)
                .shadow(
                    color: .black.opacity(0.10),
                    radius: size * 0.025,
                    x: size * 0.02,
                    y: size * 0.03
                )
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

// MARK: - Previews

#Preview("App Icon — 1024") {
    AppIconView(size: 1024)
        .previewLayout(.sizeThatFits)
}

#Preview("App Icon — 120") {
    AppIconView(size: 120)
        .previewLayout(.sizeThatFits)
}

#Preview("App Icon — 60") {
    AppIconView(size: 60)
        .previewLayout(.sizeThatFits)
}
