//
//  KawaiiIllustration.swift
//  BloomHer
//
//  Illustration catalog enum + factory view.
//  Every kawaii illustration in the app is vended through this single entry
//  point so that call-sites never depend on concrete illustration types.
//

import SwiftUI

// MARK: - KawaiiIllustration Enum

/// Catalog of every kawaii illustration available in BloomHer.
///
/// Illustrations are grouped by category:
/// - **Flowers**: growth stages from seed through bloom
/// - **Fruits**: pregnancy size comparisons (weeks 4-40)
/// - **Objects**: lifestyle and wellness props
/// - **Mood**: expressive face characters
enum KawaiiIllustration: String, CaseIterable, Identifiable {

    // MARK: Flower growth stages
    case seedling
    case sprout
    case bud
    case bloom
    case fullFlower
    case closingFlower

    // MARK: Pregnancy fruit sizes
    case poppySeed
    case raspberry
    case lime
    case avocado
    case banana
    case corn
    case eggplant
    case coconut
    case melon
    case watermelon

    // MARK: Object / wellness props
    case waterDrop
    case teaCup
    case heart
    case star
    case cloud
    case yogaMat
    case journal
    case lock

    // MARK: Mood faces
    case happyFace
    case calmFace
    case anxiousFace
    case sadFace
    case energeticFace

    var id: String { rawValue }

    // MARK: - Display metadata

    /// Human-readable label for accessibility and debug displays.
    var displayName: String {
        switch self {
        case .seedling:      return "Seedling"
        case .sprout:        return "Sprout"
        case .bud:           return "Bud"
        case .bloom:         return "Bloom"
        case .fullFlower:    return "Full Flower"
        case .closingFlower: return "Closing Flower"
        case .poppySeed:     return "Poppy Seed"
        case .raspberry:     return "Raspberry"
        case .lime:          return "Lime"
        case .avocado:       return "Avocado"
        case .banana:        return "Banana"
        case .corn:          return "Corn"
        case .eggplant:      return "Eggplant"
        case .coconut:       return "Coconut"
        case .melon:         return "Melon"
        case .watermelon:    return "Watermelon"
        case .waterDrop:     return "Water Drop"
        case .teaCup:        return "Tea Cup"
        case .heart:         return "Heart"
        case .star:          return "Star"
        case .cloud:         return "Cloud"
        case .yogaMat:       return "Yoga Mat"
        case .journal:       return "Journal"
        case .lock:          return "Lock"
        case .happyFace:     return "Happy"
        case .calmFace:      return "Calm"
        case .anxiousFace:   return "Anxious"
        case .sadFace:       return "Sad"
        case .energeticFace: return "Energetic"
        }
    }
}

// MARK: - KawaiiIllustrationView

/// Factory view that resolves a `KawaiiIllustration` to its concrete SwiftUI
/// illustration. All illustrations are vector-based SwiftUI shapes — no image
/// assets required.
///
/// ```swift
/// KawaiiIllustrationView(illustration: .fullFlower, size: 120)
/// ```
struct KawaiiIllustrationView: View {

    let illustration: KawaiiIllustration
    /// Bounding box side length in points. Illustrations are square.
    let size: CGFloat

    var body: some View {
        Group {
            switch illustration {
            // MARK: Flowers — rendered with FlowerShape + stem
            case .seedling:
                SeedlingIllustration(size: size)
            case .sprout:
                SproutIllustration(size: size)
            case .bud:
                BudIllustration(size: size)
            case .bloom:
                BloomIllustration(size: size)
            case .fullFlower:
                FullFlowerIllustration(size: size)
            case .closingFlower:
                ClosingFlowerIllustration(size: size)

            // MARK: Fruits — rendered with FruitShapes
            case .poppySeed:
                PoppySeedShape(size: size)
            case .raspberry:
                RaspberryShape(size: size)
            case .lime:
                LimeShape(size: size)
            case .avocado:
                AvocadoShape(size: size)
            case .banana:
                BananaShape(size: size)
            case .corn:
                CornShape(size: size)
            case .eggplant:
                EggplantShape(size: size)
            case .coconut:
                CoconutShape(size: size)
            case .melon:
                MelonShape(size: size)
            case .watermelon:
                WatermelonShape(size: size)

            // MARK: Objects
            case .waterDrop:
                WaterDropObjectView(size: size)
            case .teaCup:
                TeaCupView(size: size)
            case .heart:
                HeartObjectView(size: size)
            case .star:
                StarObjectView(size: size)
            case .cloud:
                CloudObjectView(size: size)
            case .yogaMat:
                YogaMatView(size: size)
            case .journal:
                JournalView(size: size)
            case .lock:
                LockView(size: size)

            // MARK: Mood faces
            case .happyFace:
                MoodFaceView(expression: .happy, size: size)
            case .calmFace:
                MoodFaceView(expression: .neutral, size: size)
            case .anxiousFace:
                MoodFaceView(expression: .surprised, size: size)
            case .sadFace:
                MoodFaceView(expression: .sad, size: size)
            case .energeticFace:
                MoodFaceView(expression: .excited, size: size)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(illustration.displayName)
    }
}

// MARK: - Inline flower-stage illustration helpers
// These compose FlowerShape + stem elements from FlowerShapes.swift

private struct SeedlingIllustration: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Soil mound
            Ellipse()
                .fill(Color(hex: "#8B6914").opacity(0.55))
                .frame(width: size * 0.7, height: size * 0.22)
                .offset(y: size * 0.34)
            // Tiny seed bump
            Circle()
                .fill(Color(hex: "#6B4F12"))
                .frame(width: size * 0.13, height: size * 0.13)
                .offset(y: size * 0.28)
            KawaiiFace(expression: .sleepy, size: size * 0.28)
                .offset(y: size * 0.08)
        }
        .frame(width: size, height: size)
    }
}

private struct SproutIllustration: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "#8B6914").opacity(0.55))
                .frame(width: size * 0.7, height: size * 0.22)
                .offset(y: size * 0.34)
            // Stem
            Rectangle()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.045, height: size * 0.38)
                .offset(y: size * 0.1)
            // Left leaf
            Ellipse()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.22, height: size * 0.11)
                .rotationEffect(.degrees(-40))
                .offset(x: -size * 0.12, y: size * 0.12)
            // Right leaf
            Ellipse()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.22, height: size * 0.11)
                .rotationEffect(.degrees(40))
                .offset(x: size * 0.12, y: size * 0.16)
            KawaiiFace(expression: .neutral, size: size * 0.28)
                .offset(y: -size * 0.14)
        }
        .frame(width: size, height: size)
    }
}

private struct BudIllustration: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "#8B6914").opacity(0.45))
                .frame(width: size * 0.65, height: size * 0.18)
                .offset(y: size * 0.38)
            Rectangle()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.04, height: size * 0.5)
                .offset(y: size * 0.1)
            Ellipse()
                .fill(Color(hex: "#5DBB63"))
                .frame(width: size * 0.2, height: size * 0.1)
                .rotationEffect(.degrees(-35))
                .offset(x: -size * 0.14, y: size * 0.14)
            // Bud
            Ellipse()
                .fill(BloomColors.primaryRose.opacity(0.9))
                .frame(width: size * 0.28, height: size * 0.36)
                .offset(y: -size * 0.14)
            KawaiiFace(expression: .happy, size: size * 0.22)
                .offset(y: -size * 0.14)
        }
        .frame(width: size, height: size)
    }
}

private struct BloomIllustration: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            FlowerShape(petalCount: 5, size: size * 0.85,
                        petalColor: BloomColors.primaryRose,
                        centerColor: BloomColors.accentPeach)
            KawaiiFace(expression: .happy, size: size * 0.28)
        }
        .frame(width: size, height: size)
    }
}

private struct FullFlowerIllustration: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            FlowerShape(petalCount: 6, size: size,
                        petalColor: BloomColors.primaryRose,
                        centerColor: BloomColors.accentPeach)
            KawaiiFace(expression: .excited, size: size * 0.3)
        }
        .frame(width: size, height: size)
    }
}

private struct ClosingFlowerIllustration: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            FlowerShape(petalCount: 6, size: size * 0.88,
                        petalColor: BloomColors.accentLavender,
                        centerColor: BloomColors.primaryRose.opacity(0.8))
            KawaiiFace(expression: .sleepy, size: size * 0.28)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Object illustration stubs
// Simple kawaii-style object views built from primitives

private struct WaterDropObjectView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            WaterDropBodyShape()
                .fill(LinearGradient(
                    colors: [BloomColors.waterBlueTint, BloomColors.waterBlue],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.65, height: size * 0.82)
            KawaiiFace(expression: .happy, size: size * 0.32)
                .offset(y: size * 0.06)
        }
        .frame(width: size, height: size)
    }
}

private struct TeaCupView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Cup body
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(Color(hex: "#FFF0E6"))
                .frame(width: size * 0.6, height: size * 0.45)
                .offset(y: size * 0.1)
            // Handle
            Circle()
                .stroke(Color(hex: "#E88B9C"), lineWidth: size * 0.055)
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(x: size * 0.35, y: size * 0.1)
            // Saucer
            Ellipse()
                .fill(Color(hex: "#F4C9B8"))
                .frame(width: size * 0.72, height: size * 0.14)
                .offset(y: size * 0.32)
            // Steam lines
            ForEach([-1, 0, 1], id: \.self) { i in
                Capsule()
                    .fill(Color(hex: "#C7B8EA").opacity(0.55))
                    .frame(width: size * 0.04, height: size * 0.18)
                    .offset(x: CGFloat(i) * size * 0.1, y: -size * 0.15)
            }
            KawaiiFace(expression: .blush, size: size * 0.28)
                .offset(y: size * 0.08)
        }
        .frame(width: size, height: size)
    }
}

private struct HeartObjectView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            HeartKawaiiShape()
                .fill(LinearGradient(
                    colors: [BloomColors.primaryRose, Color(hex: "#E88B9C")],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.8, height: size * 0.75)
            KawaiiFace(expression: .happy, size: size * 0.3)
                .offset(y: size * 0.04)
        }
        .frame(width: size, height: size)
    }
}

private struct StarObjectView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            StarKawaiiShape(points: 5)
                .fill(LinearGradient(
                    colors: [BloomColors.accentPeach, Color(hex: "#F4A0B5")],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.82, height: size * 0.82)
            KawaiiFace(expression: .excited, size: size * 0.28)
        }
        .frame(width: size, height: size)
    }
}

private struct CloudObjectView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Cloud body — layered circles
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.48, height: size * 0.48)
                .offset(x: -size * 0.12, y: size * 0.06)
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.36, height: size * 0.36)
                .offset(x: size * 0.14, y: size * 0.12)
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.28, height: size * 0.28)
                .offset(x: -size * 0.28, y: size * 0.16)
            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.62, height: size * 0.28)
                .offset(y: size * 0.18)
            KawaiiFace(expression: .sleepy, size: size * 0.3)
                .offset(y: size * 0.06)
        }
        .frame(width: size, height: size)
    }
}

private struct YogaMatView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(LinearGradient(
                    colors: [BloomColors.sageGreen.opacity(0.85), BloomColors.sageGreen],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.88, height: size * 0.42)
                .rotationEffect(.degrees(-8))
            // Mat lines
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: size * 0.75, height: size * 0.025)
                    .offset(y: CGFloat(i - 1) * size * 0.1)
                    .rotationEffect(.degrees(-8))
            }
            KawaiiFace(expression: .neutral, size: size * 0.3)
        }
        .frame(width: size, height: size)
    }
}

private struct JournalView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(BloomColors.accentLavender.opacity(0.85))
                .frame(width: size * 0.6, height: size * 0.78)
            // Spine
            Rectangle()
                .fill(BloomColors.accentLavender)
                .frame(width: size * 0.09, height: size * 0.78)
                .offset(x: -size * 0.25)
            // Lines
            ForEach(0..<4) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: size * 0.38, height: size * 0.025)
                    .offset(x: size * 0.05, y: CGFloat(i - 1) * size * 0.12 + size * 0.06)
            }
            // Heart doodle
            HeartKawaiiShape()
                .fill(BloomColors.primaryRose.opacity(0.8))
                .frame(width: size * 0.18, height: size * 0.16)
                .offset(x: size * 0.05, y: -size * 0.24)
        }
        .frame(width: size, height: size)
    }
}

private struct LockView: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            // Shackle
            Circle()
                .stroke(BloomColors.accentLavender, lineWidth: size * 0.07)
                .frame(width: size * 0.38, height: size * 0.38)
                .offset(y: -size * 0.2)
                .clipped()
            // Lock body
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(LinearGradient(
                    colors: [BloomColors.accentLavender, BloomColors.accentLavender.opacity(0.8)],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.52, height: size * 0.42)
                .offset(y: size * 0.1)
            // Keyhole
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.13, height: size * 0.13)
                .offset(y: size * 0.06)
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.055, height: size * 0.12)
                .offset(y: size * 0.18)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Mood face wrapper

private struct MoodFaceView: View {
    let expression: KawaiiFace.Expression
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(BloomColors.accentPeach.opacity(0.6))
                .frame(width: size, height: size)
            KawaiiFace(expression: expression, size: size * 0.7)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Shared primitive shapes used across object views

/// A simple heart path for kawaii object illustrations.
struct HeartKawaiiShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        // Top-left bump
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.25))
        path.addCurve(to: CGPoint(x: 0, y: h * 0.35),
                      control1: CGPoint(x: w * 0.35, y: 0),
                      control2: CGPoint(x: 0, y: h * 0.12))
        // Bottom point
        path.addCurve(to: CGPoint(x: w * 0.5, y: h),
                      control1: CGPoint(x: 0, y: h * 0.65),
                      control2: CGPoint(x: w * 0.3, y: h * 0.85))
        // Top-right bump
        path.addCurve(to: CGPoint(x: w, y: h * 0.35),
                      control1: CGPoint(x: w * 0.7, y: h * 0.85),
                      control2: CGPoint(x: w, y: h * 0.65))
        path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.25),
                      control1: CGPoint(x: w, y: h * 0.12),
                      control2: CGPoint(x: w * 0.65, y: 0))
        path.closeSubpath()
        return path
    }
}

/// A five- or n-pointed star for kawaii object illustrations.
struct StarKawaiiShape: Shape {
    var points: Int = 5
    var innerRatio: CGFloat = 0.42

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio
        let step = CGFloat.pi * 2 / CGFloat(points)
        let startAngle = -CGFloat.pi / 2

        var path = Path()
        for i in 0..<points {
            let outerAngle = startAngle + step * CGFloat(i)
            let innerAngle = outerAngle + step / 2
            let outer = CGPoint(
                x: center.x + cos(outerAngle) * outerRadius,
                y: center.y + sin(outerAngle) * outerRadius)
            let inner = CGPoint(
                x: center.x + cos(innerAngle) * innerRadius,
                y: center.y + sin(innerAngle) * innerRadius)
            if i == 0 {
                path.move(to: outer)
            } else {
                path.addLine(to: outer)
            }
            path.addLine(to: inner)
        }
        path.closeSubpath()
        return path
    }
}

/// Water drop teardrop shape reused in WaterDropObjectView.
struct WaterDropBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2
        // Tip at top
        path.move(to: CGPoint(x: cx, y: 0))
        path.addCurve(to: CGPoint(x: w, y: h * 0.62),
                      control1: CGPoint(x: w * 0.9, y: h * 0.1),
                      control2: CGPoint(x: w, y: h * 0.38))
        path.addArc(center: CGPoint(x: cx, y: h * 0.62),
                    radius: w / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: true)
        path.addCurve(to: CGPoint(x: cx, y: 0),
                      control1: CGPoint(x: 0, y: h * 0.38),
                      control2: CGPoint(x: w * 0.1, y: h * 0.1))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("All Illustrations") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            ForEach(KawaiiIllustration.allCases) { illustration in
                VStack(spacing: 4) {
                    KawaiiIllustrationView(illustration: illustration, size: 72)
                    Text(illustration.displayName)
                        .font(.system(size: 8, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
    }
    .background(Color(hex: "#FFF8F5"))
}
