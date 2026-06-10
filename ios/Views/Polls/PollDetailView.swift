import SwiftUI

struct PollDetailView: View {
    @StateObject private var viewModel: PollDetailViewModel

    init(viewModel: PollDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            content
        }
        .navigationTitle("Anket Detayı")
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
        if viewModel.isLoading && viewModel.poll == nil {
            ProgressView()
                .tint(Color.bizBizeButtonStart)
        } else if let poll = viewModel.poll {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        HomeIconView(kind: poll.type == PollType.dailyLunch.rawValue ? .burger : .surveys, size: 46)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(poll.typeTitle)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.bizBizePrimary)

                            Text("\(poll.totalVoteCount) kişi oy verdi")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.bizBizeMuted)
                        }

                        Spacer()

                        Text(poll.isClosed ? "Kapalı" : "Aktif")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(poll.isClosed ? Color.bizBizeMuted : Color.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background((poll.isClosed ? Color.bizBizeBorder : Color.green.opacity(0.14)))
                            .clipShape(Capsule())
                    }

                    Text(poll.question)
                        .font(.title2.bold())
                        .foregroundStyle(Color.bizBizeInk)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 12) {
                        ForEach(poll.options.sorted { $0.displayOrder < $1.displayOrder }) { option in
                            Button {
                                Task {
                                    await viewModel.vote(option: option)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(option.text)
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(Color.bizBizeInk)

                                        Spacer()

                                        if poll.myVoteOptionId == option.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.bizBizeButtonStart)
                                        }

                                        Text("\(option.voteCount)")
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(Color.bizBizeMuted)
                                    }

                                    PollOptionProgressRow(
                                        option: option,
                                        totalVotes: max(poll.totalVoteCount, 1),
                                        isSelected: poll.myVoteOptionId == option.id
                                    )
                                }
                                .padding(14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(poll.myVoteOptionId == option.id ? Color.bizBizeButtonStart : Color.bizBizeBorder, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(poll.isClosed || poll.myVoteOptionId != nil || viewModel.isVoting)
                        }
                    }

                    Label("Bitiş: \(poll.formattedExpiresAt)", systemImage: "clock")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.bizBizeMuted)
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 18, x: 0, y: 9)
                .padding(18)
            }
        } else {
            Text("Anket bulunamadı.")
                .font(.headline)
                .foregroundStyle(Color.bizBizeMuted)
        }
    }
}
