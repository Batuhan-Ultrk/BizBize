import SwiftUI

struct AnnouncementDetailView: View {
    @StateObject private var viewModel: AnnouncementDetailViewModel

    init(viewModel: AnnouncementDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            content
        }
        .navigationTitle("Duyuru Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchDetail()
        }
        .alert("Hata", isPresented: $viewModel.showAlert) {
            Button("Tamam", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .tint(Color.bizBizeButtonStart)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.announcement == nil {
            ProgressView()
                .tint(Color.bizBizeButtonStart)
        } else if let announcement = viewModel.announcement {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        HomeIconView(kind: announcement.typeIcon, size: 46)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(announcement.typeTitle)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.bizBizePrimary)

                            Text(announcement.formattedCreatedAt)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.bizBizeMuted)
                        }
                    }

                    Text(announcement.title)
                        .font(.title2.bold())
                        .foregroundStyle(Color.bizBizeInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(announcement.body)
                        .font(.body)
                        .foregroundStyle(Color.bizBizeInk.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    if let eventDate = announcement.formattedEventDate {
                        Label(eventDate, systemImage: "calendar")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.bizBizeMuted)
                    }

                    if announcement.hasRsvp {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Katılım")
                                .font(.headline.bold())
                                .foregroundStyle(Color.bizBizeInk)

                            AnnouncementRsvpButtons(
                                selectedStatus: announcement.myRsvpStatus,
                                onAttending: {
                                    Task {
                                        await viewModel.sendRsvp(status: .attending)
                                    }
                                },
                                onNotAttending: {
                                    Task {
                                        await viewModel.sendRsvp(status: .notAttending)
                                    }
                                }
                            )
                        }
                    }

                    // TODO: Yorum servisi eklendiğinde yorum alanı burada gösterilecek.
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 18, x: 0, y: 9)
                .padding(18)
            }
        } else {
            Text("Duyuru bulunamadı.")
                .font(.headline)
                .foregroundStyle(Color.bizBizeMuted)
        }
    }
}

private struct AnnouncementRsvpButtons: View {
    let selectedStatus: String?
    let onAttending: () -> Void
    let onNotAttending: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            button("Katılacağım", status: .attending, action: onAttending)
            button("Katılmayacağım", status: .notAttending, action: onNotAttending)
        }
    }

    private func button(_ title: String, status: RsvpStatus, action: @escaping () -> Void) -> some View {
        let isSelected = selectedStatus == status.rawValue

        return Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isSelected ? .white : Color.bizBizePrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.bizBizeButtonStart : Color.bizBizeFieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
