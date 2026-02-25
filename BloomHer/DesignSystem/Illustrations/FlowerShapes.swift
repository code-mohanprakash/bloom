//
//  FlowerShapes.swift
//  BloomHer
//
//  Custom SwiftUI Shape-based flower components.
//  All paths are built with quadratic/cubic Bézier curves — no image assets.
//
//  Components:
//    PetalShape  — teardrop petal
//    LeafShape   — pointed oval leaf
//    StemPath    — curved stem stroke
//    FlowerShape — assembled flower with N petals, stem, and leaf
//

import SwiftUI

// MARK: - PetalShape

/// A teardrop-shaped petal.
///
/// The narrow end sits at the origin (center of the flower) and the wide,
/// rounded end points outward. Rotate to lay petals radially.
struct PetalShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Narrow tip at top-center of the rect (flower center end)
        path.move(to: CGPoint(x: w * 0.5, y: 0))

        // Right curve — goes out wide and rounds the bottom
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 1.0, y: h * 0.15),
            control2: CGPoint(x: w * 0.9, y: h * 0.9))

        // Left curve — mirrors back to the tip
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.1, y: h * 0.9),
            control2: CGPoint(x: 0, y: h * 0.15))

        path.closeSubpath()
        return path
    }
}

// MARK: - LeafShape

/// A pointed oval leaf with a slight curve to one side.
struct LeafShape: Shape {

    /// Lateral offset of the leaf tip (0 = symmetric, positive = tips right).
    var curveBias: CGFloat = 0.15

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Base (attached to stem)
        path.move(to: CGPoint(x: w * 0.5, y: h))

        // Right side up to tip
        path.addCurve(
            to: CGPoint(x: w * (0.5 + curveBias), y: 0),
            control1: CGPoint(x: w * 0.95, y: h * 0.7),
            control2: CGPoint(x: w * 0.85, y: h * 0.2))

        // Left side back down
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 0.15, y: h * 0.2),
            control2: CGPoint(x: w * 0.05, y: h * 0.7))

        path.closeSubpath()
        return path
    }
}

// MARK: - StemPath

/// A gently curved stem stroke. Draw as a stroked path.
///
/// The stem runs from the bottom of the bounding rect (soil end) up to the
/// top-center (flower head end), with a slight S-curve for organic feel.
struct StemPath: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Bottom center
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        // Gentle S-curve to top
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.midX + rect.width * 0.18, y: rect.maxY * 0.7),
            control2: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.maxY * 0.3))
        return path
    }
}

// MARK: - FlowerShape

/// A complete assembled flower: N petals arranged radially, a circular center,
/// a curved stem, and a leaf.
///
/// ```swift
/// FlowerShape(petalCount: 6, size: 120,
///             petalColor: BloomColors.primaryRose,
///             centerColor: BloomColors.accentPeach)
/// ```
struct FlowerShape: View {

    let petalCount: Int
    let size: CGFloat
    let petalColor: Color
    let centerColor: Color

    /// Optional: second petal color for alternate-petal tinting.
    var alternatePetalColor: Color? = nil
    /// Stem color defaults to sage green.
    var stemColor: Color = Color(hex: "#5DBB63")
    /// Whether to show the stem and leaf.
    var showStem: Bool = true

    // MARK: Derived sizes
    private var centerRadius: CGFloat { size * 0.18 }
    private var petalLength: CGFloat  { size * 0.38 }
    private var petalWidth: CGFloat   { size * 0.2 }
    private var stemWidth: CGFloat    { size * 0.04 }
    private var leafSize: CGFloat     { size * 0.22 }

    var body: some View {
        ZStack {
            if showStem {
                stemAndLeaf
            }
            petals
            // Center disc
            Circle()
                .fill(
                    RadialGradient(
                        colors: [centerColor.opacity(0.95), centerColor.opacity(0.7)],
                        center: .center,
                        startRadius: 0,
                        endRadius: centerRadius))
                .frame(width: centerRadius * 2, height: centerRadius * 2)
            // Center highlight dot
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: centerRadius * 0.45, height: centerRadius * 0.45)
                .offset(x: -centerRadius * 0.15, y: -centerRadius * 0.15)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Petal ring

    private var petals: some View {
        ZStack {
            ForEach(0..<petalCount, id: \.self) { index in
                let angle = Double(index) / Double(petalCount) * 360.0
                let color = (alternatePetalColor != nil && index.isMultiple(of: 2))
                    ? alternatePetalColor!
                    : petalColor

                PetalShape()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.95), color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom))
                    .frame(width: petalWidth, height: petalLength)
                    // Offset so the narrow tip sits at the center
                    .offset(y: -petalLength / 2 - centerRadius * 0.4)
                    .rotationEffect(.degrees(angle))
            }
        }
    }

    // MARK: - Stem + leaf

    private var stemAndLeaf: some View {
        ZStack {
            // Stem stroke
            StemPath()
                .stroke(
                    stemColor,
                    style: StrokeStyle(lineWidth: stemWidth, lineCap: .round))
                .frame(width: size * 0.15, height: size * 0.48)
                .offset(y: size * 0.3)

            // Leaf — positioned partway up the stem, angled outward
            LeafShape(curveBias: 0.12)
                .fill(stemColor.opacity(0.85))
                .frame(width: leafSize * 0.7, height: leafSize)
                .rotationEffect(.degrees(-50))
                .offset(x: -size * 0.1, y: size * 0.34)
        }
    }
}

// MARK: - Convenience flower variants

extension FlowerShape {
    /// Rose-tinted primary flower (6 petals).
    static func primary(size: CGFloat) -> FlowerShape {
        FlowerShape(petalCount: 6, size: size,
                    petalColor: BloomColors.primaryRose,
                    centerColor: BloomColors.accentPeach)
    }

    /// Sage-tinted follicular flower (5 petals).
    static func follicular(size: CGFloat) -> FlowerShape {
        FlowerShape(petalCount: 5, size: size,
                    petalColor: BloomColors.sageGreen,
                    centerColor: Color(hex: "#FDEFD0"))
    }

    /// Peach-golden ovulation flower (6 petals, alternate tint).
    static func ovulation(size: CGFloat) -> FlowerShape {
        FlowerShape(petalCount: 6, size: size,
                    petalColor: BloomColors.accentPeach,
                    centerColor: Color(hex: "#F9D5A7"),
                    alternatePetalColor: BloomColors.primaryRose.opacity(0.7))
    }

    /// Lavender luteal flower (5 petals).
    static func luteal(size: CGFloat) -> FlowerShape {
        FlowerShape(petalCount: 5, size: size,
                    petalColor: BloomColors.accentLavender,
                    centerColor: BloomColors.primaryRose.opacity(0.7))
    }
}

// MARK: - Preview

#Preview("Flower Shapes") {
    VStack(spacing: 24) {
        Text("FlowerShapes")
            .font(.headline.rounded())

        HStack(spacing: 20) {
            VStack(spacing: 6) {
                FlowerShape.primary(size: 100)
                Text("Primary").font(.caption2.rounded())
            }
            VStack(spacing: 6) {
                FlowerShape.follicular(size: 100)
                Text("Follicular").font(.caption2.rounded())
            }
        }
        HStack(spacing: 20) {
            VStack(spacing: 6) {
                FlowerShape.ovulation(size: 100)
                Text("Ovulation").font(.caption2.rounded())
            }
            VStack(spacing: 6) {
                FlowerShape.luteal(size: 100)
                Text("Luteal").font(.caption2.rounded())
            }
        }

        // Individual shape previews
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                PetalShape()
                    .fill(BloomColors.primaryRose)
                    .frame(width: 36, height: 64)
                Text("Petal").font(.caption2)
            }
            VStack(spacing: 4) {
                LeafShape()
                    .fill(Color(hex: "#5DBB63"))
                    .frame(width: 30, height: 56)
                Text("Leaf").font(.caption2)
            }
            VStack(spacing: 4) {
                StemPath()
                    .stroke(Color(hex: "#5DBB63"),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 24, height: 80)
                Text("Stem").font(.caption2)
            }
        }
    }
    .padding(24)
    .background(Color(hex: "#FFF8F5"))
}
