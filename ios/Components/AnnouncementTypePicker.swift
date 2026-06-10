import SwiftUI

struct AnnouncementTypePicker: View {
    @Binding var selectedType: AnnouncementType

    var body: some View {
        HStack(spacing: 10) {
            ForEach(AnnouncementType.allCases) { type in
                Button {
                    selectedType = type
                } label: {
                    VStack(spacing: 6) {
                        HomeIconView(kind: type.icon, size: 22)

                        Text(type.title)
                            .font(.caption2.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selectedType == type ? .white : Color.bizBizeInk)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(selectedType == type ? Color.bizBizeButtonStart : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(selectedType == type ? Color.bizBizeButtonStart : Color.bizBizeBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
