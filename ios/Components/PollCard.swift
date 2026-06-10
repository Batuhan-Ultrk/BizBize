import SwiftUI

struct PollCard: View {
    let poll: PollDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                HomeIconView(kind: poll.type == PollType.dailyLunch.rawValue ? .burger : .surveys, size: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(poll.question)
                        .font(.headline.bold())
                        .foregroundStyle(Color.bizBizeInk)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(poll.totalVoteCount) kişi oy verdi")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.bizBizeMuted)
                }

                Spacer()

                statusBadge
            }

            VStack(spacing: 10) {
                ForEach(sortedOptions.prefix(3)) { option in
                    PollOptionProgressRow(
                        option: option,
                        totalVotes: max(poll.totalVoteCount, 1),
                        isSelected: poll.myVoteOptionId == option.id
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.07), radius: 16, x: 0, y: 8)
    }

    private var sortedOptions: [PollOptionDTO] {
        poll.options.sorted { $0.displayOrder < $1.displayOrder }
    }

    private var statusBadge: some View {
        Text(poll.isClosed ? "Kapalı" : "Aktif")
            .font(.caption2.weight(.bold))
            .foregroundStyle(poll.isClosed ? Color.bizBizeMuted : Color.green)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background((poll.isClosed ? Color.bizBizeBorder : Color.green.opacity(0.14)))
            .clipShape(Capsule())
    }
}

struct PollOptionProgressRow: View {
    let option: PollOptionDTO
    let totalVotes: Int
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(option.text)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)

                Spacer()

                Text("\(option.voteCount)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? Color.bizBizeButtonStart : Color.bizBizeMuted)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.bizBizeBorder.opacity(0.55))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.bizBizeButtonStart, Color.bizBizeButtonEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 7)
        }
    }

    private var progress: CGFloat {
        guard totalVotes > 0 else { return 0 }
        return CGFloat(option.voteCount) / CGFloat(totalVotes)
    }
}
