import SwiftUI

struct PollListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var pollServiceContainer: PollServiceContainer
    @StateObject private var viewModel: PollListViewModel
    @State private var showsCreateView = false

    private let filters: [(String, String?)] = [
        ("Tümü", nil),
        ("Manuel", "manual"),
        ("Yemek", "dailyLunch")
    ]

    init(viewModel: PollListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                filterBar
                content
            }

            Button {
                showsCreateView = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(
                        LinearGradient(
                            colors: [Color.bizBizeButtonStart, Color.bizBizeButtonEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.bizBizePrimary.opacity(0.30), radius: 14, x: 0, y: 8)
            }
            .padding(.trailing, 22)
            .padding(.bottom, 22)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchPolls()
        }
        .refreshable {
            await viewModel.fetchPolls()
        }
        .alert("Hata", isPresented: $viewModel.showAlert) {
            Button("Tamam", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .tint(Color.bizBizeButtonStart)
        .sheet(isPresented: $showsCreateView) {
            NavigationStack {
                CreatePollView(
                    viewModel: CreatePollViewModel(pollService: pollServiceContainer.service),
                    onCreated: {
                        showsCreateView = false
                        Task {
                            await viewModel.fetchPolls()
                        }
                    }
                )
            }
        }
        .navigationDestination(for: PollDTO.self) { poll in
            PollDetailView(
                viewModel: PollDetailViewModel(
                    pollId: poll.id,
                    pollService: pollServiceContainer.service
                )
            )
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Anketler")
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeInk)

            Spacer()

            Button {
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeInk)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.0) { filter in
                    Button {
                        Task {
                            await viewModel.selectType(filter.1)
                        }
                    } label: {
                        Text(filter.0)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(viewModel.selectedType == filter.1 ? .white : Color.bizBizeInk)
                            .padding(.horizontal, 18)
                            .frame(height: 36)
                            .background(viewModel.selectedType == filter.1 ? Color.bizBizeButtonStart : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.bizBizeBorder.opacity(0.8), lineWidth: viewModel.selectedType == filter.1 ? 0 : 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.polls.isEmpty {
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Color.bizBizeButtonStart)

                Text("Anketler yükleniyor...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.polls.isEmpty {
            VStack(spacing: 14) {
                HomeIconView(kind: .surveys, size: 54)

                Text("Henüz anket yok.")
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Text("Yeni anket oluşturmak için + butonunu kullan.")
                    .font(.subheadline)
                    .foregroundStyle(Color.bizBizeMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.polls) { poll in
                        NavigationLink(value: poll) {
                            PollCard(poll: poll)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 96)
            }
        }
    }
}
