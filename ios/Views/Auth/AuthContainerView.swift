import SwiftUI
import UIKit

struct AuthContainerView: View {
    enum AuthMode {
        case login
        case register
        case forgotPassword
    }

    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var mode: AuthMode = .login

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bizBizeScreenBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        header

                        switch mode {
                        case .login:
                            LoginView(
                                onRegisterTap: {
                                    viewModel.resetRegisterForm()
                                    switchMode(.register)
                                },
                                onForgotPasswordTap: { switchMode(.forgotPassword) }
                            )
                        case .register:
                            RegisterView(onLoginTap: {
                                viewModel.resetRegisterForm()
                                switchMode(.login)
                            })
                        case .forgotPassword:
                            ForgotPasswordView(onBackToLoginTap: { switchMode(.login) })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 26)
                    .padding(.bottom, 28)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        Group {
            if mode == .login {
                loginHeroHeader
            } else {
                brandHeader
            }
        }
    }

    private var loginHeroHeader: some View {
        Group {
            if let image = loginHeroImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } else {
                brandHeader
            }
        }
    }

    private var loginHeroImage: UIImage? {
        guard let path = Bundle.main.path(forResource: "LoginHero", ofType: "png") else {
            return nil
        }

        return UIImage(contentsOfFile: path)
    }

    private var brandHeader: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.bizBizeButtonStart)
                            .frame(width: 58, height: 58)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        BubbleTail()
                            .fill(Color.bizBizeButtonStart)
                            .frame(width: 16, height: 14)
                            .offset(x: -18, y: 23)
                    }

                    Text(L10n.text("app.name"))
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.bizBizeButtonStart)
                }

                Text(L10n.text("auth.tagline"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.bizBizePrimary)
            }

            TeamIllustration()
        }
        .padding(.top, 8)
    }

    private func switchMode(_ newMode: AuthMode) {
        withAnimation(.easeInOut(duration: 0.25)) {
            mode = newMode
        }
    }
}

private struct TeamIllustration: View {
    private let people: [(Color, Color)] = [
        (Color.bizBizePrimary, Color(red: 0.08, green: 0.12, blue: 0.28)),
        (Color(red: 1.00, green: 0.38, blue: 0.20), Color(red: 0.08, green: 0.12, blue: 0.28)),
        (Color.bizBizeButtonStart, Color(red: 0.08, green: 0.12, blue: 0.28)),
        (Color(red: 1.00, green: 0.72, blue: 0.10), Color(red: 0.08, green: 0.12, blue: 0.28))
    ]

    var body: some View {
        ZStack {
            HStack(spacing: 22) {
                SpeechBubble(lines: 2)
                    .offset(y: -32)
                SpeechBubble(lines: 3)
                    .scaleEffect(0.72)
                    .offset(y: -18)
                SpeechBubble(lines: 2)
                    .offset(y: -34)
            }
            .foregroundStyle(Color.bizBizeSecondary.opacity(0.35))

            HStack(alignment: .bottom, spacing: 14) {
                ForEach(people.indices, id: \.self) { index in
                    PersonFigure(shirtColor: people[index].0, hairColor: people[index].1)
                        .frame(width: 70, height: 126)
                        .offset(y: index == 1 ? 8 : 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 176)
    }
}

private struct PersonFigure: View {
    let shirtColor: Color
    let hairColor: Color

    var body: some View {
        VStack(spacing: -2) {
            ZStack(alignment: .top) {
                Circle()
                    .fill(Color(red: 1.00, green: 0.70, blue: 0.52))
                    .frame(width: 38, height: 38)

                Capsule()
                    .fill(hairColor)
                    .frame(width: 42, height: 22)
                    .offset(y: -8)

                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 5, height: 5)
                    .offset(x: -8, y: 16)

                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 5, height: 5)
                    .offset(x: 8, y: 16)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(shirtColor)
                    .frame(width: 62, height: 78)

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(red: 0.08, green: 0.13, blue: 0.34))
                    .frame(width: 18, height: 30)
                    .rotationEffect(.degrees(-8))
                    .offset(x: 13, y: -6)
            }
        }
    }
}

private struct SpeechBubble: View {
    let lines: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .frame(width: 58, height: 42)

            VStack(spacing: 4) {
                ForEach(0..<lines, id: \.self) { _ in
                    Capsule()
                        .fill(Color.bizBizePrimary.opacity(0.55))
                        .frame(width: 26, height: 3)
                }
            }

            BubbleTail()
                .frame(width: 12, height: 10)
                .offset(x: -16, y: 22)
        }
    }
}

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
