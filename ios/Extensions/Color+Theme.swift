import SwiftUI

extension Color {
    static let bizBizePrimary = Color(red: 0.47, green: 0.25, blue: 0.86)
    static let bizBizeButtonStart = Color(red: 0.31, green: 0.10, blue: 1.00)
    static let bizBizeButtonEnd = Color(red: 0.36, green: 0.09, blue: 0.91)
    static let bizBizeSecondary = Color(red: 0.77, green: 0.55, blue: 0.96)
    static let bizBizeAccent = Color(red: 0.98, green: 0.46, blue: 0.72)
    static let bizBizeInk = Color(red: 0.16, green: 0.12, blue: 0.25)
    static let bizBizeMuted = Color(red: 0.47, green: 0.42, blue: 0.56)
    static let bizBizeFieldBackground = Color(red: 0.96, green: 0.94, blue: 0.99)
    static let bizBizeBorder = Color(red: 0.88, green: 0.88, blue: 0.94)
    static let bizBizeScreenBackground = Color(red: 0.99, green: 0.99, blue: 1.00)
}

extension LinearGradient {
    static let bizBizeBackground = LinearGradient(
        colors: [
            Color(red: 0.39, green: 0.19, blue: 0.75),
            Color(red: 0.66, green: 0.43, blue: 0.91),
            Color(red: 0.92, green: 0.76, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
