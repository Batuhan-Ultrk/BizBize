import SwiftUI

struct FoodPollCard: View {
    private let options = [
        (HomeIconKind.burger, "12"),
        (HomeIconKind.salad, "8"),
        (HomeIconKind.soup, "15"),
        (HomeIconKind.drink, "4")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Bugün Ne Yiyoruz?")
                            .font(.headline.bold())
                            .foregroundStyle(Color.bizBizeInk)

                        HomeIconView(kind: .burger, size: 22)
                    }

                    Text("39 kişi oy verdi")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.bizBizeMuted)
                }

                Spacer()

                // TODO: yemek anket servisi bağlanacak
                Button {
                } label: {
                    HStack(spacing: 8) {
                        Text("Oy Ver")
                            .font(.caption.weight(.bold))

                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(Color.bizBizePrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.bizBizeFieldBackground)
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 10) {
                ForEach(options, id: \.0) { option in
                    HStack(spacing: 7) {
                        HomeIconView(kind: option.0, size: 24)

                        Text(option.1)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.bizBizeInk)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.bizBizeBorder.opacity(0.65), lineWidth: 1)
                    )
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 18, x: 0, y: 9)
    }
}
