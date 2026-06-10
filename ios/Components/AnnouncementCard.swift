import SwiftUI

struct AnnouncementCard: View {
    let announcement: AnnouncementDTO
    var onAttending: () -> Void
    var onNotAttending: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                avatar

                VStack(alignment: .leading, spacing: 3) {
                    Text("BizBize")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.bizBizeInk)

                    Text(announcement.formattedCreatedAt)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.bizBizeMuted)
                }

                Spacer()

                typeBadge
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(announcement.title)
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text(announcement.body)
                    .font(.subheadline)
                    .foregroundStyle(Color.bizBizeInk.opacity(0.88))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let eventDate = announcement.formattedEventDate {
                Label(eventDate, systemImage: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }

            if announcement.hasRsvp {
                HStack(spacing: 10) {
                    rsvpButton(
                        title: "Katılacağım",
                        status: .attending,
                        action: onAttending
                    )

                    rsvpButton(
                        title: "Katılmayacağım",
                        status: .notAttending,
                        action: onNotAttending
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.07), radius: 16, x: 0, y: 8)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.bizBizeFieldBackground)
                .frame(width: 46, height: 46)

            HomeIconView(kind: announcement.typeIcon, size: 28)
        }
    }

    private var typeBadge: some View {
        HStack(spacing: 5) {
            HomeIconView(kind: announcement.typeIcon, size: 16)

            Text(announcement.typeTitle)
                .font(.caption2.weight(.bold))
        }
        .foregroundStyle(Color.bizBizePrimary)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Color.bizBizeFieldBackground)
        .clipShape(Capsule())
    }

    private func rsvpButton(
        title: String,
        status: RsvpStatus,
        action: @escaping () -> Void
    ) -> some View {
        let isSelected = announcement.myRsvpStatus == status.rawValue

        return Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? .white : Color.bizBizePrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? Color.bizBizeButtonStart : Color.bizBizeFieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
