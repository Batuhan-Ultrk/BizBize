import SwiftUI

struct HomeQuickActionCard: View {
    let icon: HomeIconKind
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            HomeIconView(kind: icon, size: 38)

            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.bizBizeInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 108)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.bizBizeBorder.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: Color.bizBizePrimary.opacity(0.06), radius: 13, x: 0, y: 7)
    }
}

enum HomeIconKind: Hashable {
    case birthday
    case gift
    case event
    case operational
    case surveys
    case mysteryEmployee
    case announcements
    case directory
    case wave
    case burger
    case salad
    case soup
    case drink
}

struct HomeIconView: View {
    let kind: HomeIconKind
    let size: CGFloat

    var body: some View {
        ZStack {
            switch kind {
            case .birthday:
                Image(systemName: "birthday.cake.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .orange)
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: .red.opacity(0.18), radius: 4, x: 0, y: 3)
            case .gift:
                Image(systemName: "gift.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.bizBizeButtonStart, Color.bizBizeSecondary)
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: Color.bizBizeButtonStart.opacity(0.15), radius: 4, x: 0, y: 3)
            case .event:
                Image(systemName: "party.popper.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(red: 1.0, green: 0.56, blue: 0.18), Color.bizBizeButtonStart)
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: Color.bizBizeButtonStart.opacity(0.14), radius: 4, x: 0, y: 3)
            case .operational:
                Image(systemName: "briefcase.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.bizBizeInk, Color.bizBizeMuted)
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 3)
            case .surveys:
                SurveyBarsIcon(size: size)
            case .mysteryEmployee:
                Image(systemName: "person.fill.questionmark")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.yellow, Color.bizBizeInk)
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 3)
            case .announcements:
                Image(systemName: "megaphone.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, Color(red: 1.0, green: 0.61, blue: 0.56))
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: .red.opacity(0.16), radius: 5, x: 0, y: 4)
            case .directory:
                Image(systemName: "person.2.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.bizBizeInk, Color.bizBizeMuted)
                    .font(.system(size: size, weight: .bold))
                    .shadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 3)
            case .wave:
                Image(systemName: "hand.wave.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.orange, .yellow)
                    .font(.system(size: size, weight: .bold))
                    .rotationEffect(.degrees(-8))
                    .shadow(color: .orange.opacity(0.18), radius: 4, x: 0, y: 3)
            case .burger:
                FoodIconBase(size: size, background: Color(red: 1.0, green: 0.93, blue: 0.78)) {
                    BurgerIcon(size: size * 0.72)
                }
            case .salad:
                FoodIconBase(size: size, background: Color(red: 0.90, green: 0.98, blue: 0.88)) {
                    SaladIcon(size: size * 0.72)
                }
            case .soup:
                FoodIconBase(size: size, background: Color(red: 0.94, green: 0.96, blue: 0.92)) {
                    SoupIcon(size: size * 0.72)
                }
            case .drink:
                FoodIconBase(size: size, background: Color(red: 0.91, green: 0.90, blue: 0.98)) {
                    DrinkIcon(size: size * 0.72)
                }
            }
        }
        .frame(width: size + 8, height: size + 8)
    }
}

private struct SurveyBarsIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.90, green: 0.94, blue: 1.0),
                            Color(red: 0.95, green: 0.91, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size + 8, height: size + 8)

            HStack(alignment: .bottom, spacing: size * 0.09) {
                SurveyBar(
                    height: size * 0.48,
                    width: size * 0.17,
                    colors: [Color(red: 0.43, green: 0.69, blue: 1.0), Color(red: 0.31, green: 0.50, blue: 0.94)]
                )

                SurveyBar(
                    height: size * 0.68,
                    width: size * 0.17,
                    colors: [Color(red: 0.48, green: 0.42, blue: 1.0), Color.bizBizeButtonStart]
                )

                SurveyBar(
                    height: size * 0.88,
                    width: size * 0.17,
                    colors: [Color(red: 0.37, green: 0.21, blue: 0.95), Color.bizBizeButtonEnd]
                )
            }
            .padding(.bottom, size * 0.12)
        }
        .shadow(color: Color.bizBizeButtonStart.opacity(0.14), radius: 5, x: 0, y: 4)
    }
}

private struct SurveyBar: View {
    let height: CGFloat
    let width: CGFloat
    let colors: [Color]

    var body: some View {
        RoundedRectangle(cornerRadius: width * 0.45, style: .continuous)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: height)
    }
}

private struct BurgerIcon: View {
    let size: CGFloat

    var body: some View {
        VStack(spacing: size * 0.04) {
            UnevenRoundedRectangle(
                topLeadingRadius: size * 0.38,
                bottomLeadingRadius: size * 0.08,
                bottomTrailingRadius: size * 0.08,
                topTrailingRadius: size * 0.38,
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.76, blue: 0.27), Color(red: 0.94, green: 0.45, blue: 0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size * 0.98, height: size * 0.30)
            .overlay(alignment: .top) {
                HStack(spacing: size * 0.12) {
                    Circle().fill(.white.opacity(0.85)).frame(width: size * 0.06)
                    Circle().fill(.white.opacity(0.85)).frame(width: size * 0.05)
                    Circle().fill(.white.opacity(0.85)).frame(width: size * 0.06)
                }
                .offset(y: size * 0.08)
            }

            Capsule()
                .fill(Color(red: 0.18, green: 0.50, blue: 0.18))
                .frame(width: size, height: size * 0.10)

            Capsule()
                .fill(Color(red: 0.38, green: 0.17, blue: 0.08))
                .frame(width: size * 0.92, height: size * 0.16)

            Capsule()
                .fill(Color(red: 0.96, green: 0.63, blue: 0.17))
                .frame(width: size * 0.96, height: size * 0.16)
        }
        .frame(width: size, height: size)
    }
}

private struct SaladIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            UnevenRoundedRectangle(
                topLeadingRadius: size * 0.10,
                bottomLeadingRadius: size * 0.30,
                bottomTrailingRadius: size * 0.30,
                topTrailingRadius: size * 0.10,
                style: .continuous
            )
            .fill(Color(red: 0.86, green: 0.49, blue: 0.15))
            .frame(width: size * 0.90, height: size * 0.44)
            .offset(y: size * 0.18)

            HStack(spacing: -size * 0.08) {
                Circle().fill(Color(red: 0.29, green: 0.68, blue: 0.25))
                Circle().fill(Color(red: 0.47, green: 0.80, blue: 0.27))
                Circle().fill(Color(red: 0.20, green: 0.58, blue: 0.25))
            }
            .frame(width: size * 0.90, height: size * 0.46)
            .offset(y: -size * 0.05)

            Circle()
                .fill(Color(red: 1.0, green: 0.47, blue: 0.28))
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: size * 0.21, y: size * 0.02)
        }
        .frame(width: size, height: size)
    }
}

private struct SoupIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.55, green: 0.60, blue: 0.54))
                .frame(width: size * 0.92, height: size * 0.30)
                .offset(y: -size * 0.06)

            UnevenRoundedRectangle(
                topLeadingRadius: size * 0.10,
                bottomLeadingRadius: size * 0.28,
                bottomTrailingRadius: size * 0.28,
                topTrailingRadius: size * 0.10,
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.83, green: 0.86, blue: 0.79), Color(red: 0.54, green: 0.62, blue: 0.56)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size * 0.88, height: size * 0.42)
            .offset(y: size * 0.14)

            HStack(spacing: size * 0.04) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(Color.bizBizeMuted.opacity(0.75))
                        .frame(width: size * 0.035, height: size * 0.22)
                        .offset(y: index == 1 ? -size * 0.05 : 0)
                }
            }
            .offset(y: -size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

private struct DrinkIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 0.33, green: 0.29, blue: 0.60), lineWidth: size * 0.10)
                .frame(width: size * 0.78, height: size * 0.78)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.92, green: 0.91, blue: 1.0), Color(red: 0.64, green: 0.60, blue: 0.90)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.54, height: size * 0.54)

            Circle()
                .fill(.white.opacity(0.75))
                .frame(width: size * 0.14, height: size * 0.14)
                .offset(x: -size * 0.10, y: -size * 0.12)
        }
        .frame(width: size, height: size)
    }
}

private struct FoodIconBase<Content: View>: View {
    let size: CGFloat
    let background: Color
    let content: Content

    init(size: CGFloat, background: Color, @ViewBuilder content: () -> Content) {
        self.size = size
        self.background = background
        self.content = content()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(background)
                .frame(width: size + 4, height: size + 4)

            content
        }
        .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 4, x: 0, y: 3)
    }
}
