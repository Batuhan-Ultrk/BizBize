import SwiftUI

struct HomeStatCard: View {
    let icon: HomeIconKind
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 9) {
            HStack(spacing: 7) {
                HomeIconView(kind: icon, size: 25)

                Text(value)
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.bizBizeInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(minHeight: 34)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 116)
        .padding(.horizontal, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 15, x: 0, y: 8)
    }
}
