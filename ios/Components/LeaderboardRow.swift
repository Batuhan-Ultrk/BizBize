import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntryDTO
    let displayName: String

    var body: some View {
        HStack(spacing: 12) {
            rankView

            avatar

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName.isEmpty ? "Kullanıcı" : displayName)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)

                if !entry.badges.isEmpty {
                    Text(entry.badges.prefix(2).joined(separator: ", "))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.bizBizeMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(entry.score) puan")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.bizBizeInk)
        }
        .padding(.vertical, 9)
    }

    private var rankView: some View {
        ZStack {
            if entry.rank <= 3 {
                Image(systemName: "trophy.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(rankColor)
            } else {
                Text("\(entry.rank)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)
            }
        }
        .frame(width: 30)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.bizBizeSecondary.opacity(0.95), Color.bizBizeButtonStart.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 38, height: 38)

            Text(displayName.prefix(1).uppercased())
                .font(.headline.bold())
                .foregroundStyle(.white)
        }
    }

    private var rankColor: Color {
        switch entry.rank {
        case 1:
            return Color(red: 1.0, green: 0.67, blue: 0.12)
        case 2:
            return Color(red: 0.58, green: 0.60, blue: 0.68)
        default:
            return Color(red: 0.78, green: 0.38, blue: 0.16)
        }
    }
}
