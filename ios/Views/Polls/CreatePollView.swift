import SwiftUI

struct CreatePollView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreatePollViewModel

    let onCreated: () -> Void

    init(viewModel: CreatePollViewModel, onCreated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreated = onCreated
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                field("Soru") {
                    TextField("Anket sorusunu girin", text: $viewModel.question)
                        .textInputAutocapitalization(.sentences)
                        .padding(14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(fieldBorder(hasError: viewModel.questionError != nil))
                } error: {
                    viewModel.questionError
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Seçenekler")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.bizBizeInk)

                        Spacer()

                        Button {
                            viewModel.addOption()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.bizBizeButtonStart)
                        }
                        .disabled(viewModel.options.count >= 5)
                    }

                    ForEach(viewModel.options.indices, id: \.self) { index in
                        HStack(spacing: 10) {
                            TextField("Seçenek \(index + 1)", text: $viewModel.options[index])
                                .padding(14)
                                .frame(height: 50)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(fieldBorder(hasError: viewModel.optionsError != nil))

                            if viewModel.options.count > 2 {
                                Button {
                                    viewModel.removeOption(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }

                    if let optionsError = viewModel.optionsError {
                        Text(optionsError)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red)
                    }
                }

                DatePicker("Bitiş tarihi", selection: $viewModel.expiresAt, displayedComponents: [.date, .hourAndMinute])
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeInk)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                PrimaryButton(title: "Yayınla", systemImage: "paperplane.fill", isLoading: viewModel.isLoading) {
                    Task {
                        let didCreate = await viewModel.createPoll()
                        if didCreate {
                            onCreated()
                            dismiss()
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(18)
        }
        .background(Color.bizBizeScreenBackground.ignoresSafeArea())
        .navigationTitle("Yeni Anket")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Kapat") {
                    dismiss()
                }
            }
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

    private func field<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content,
        error: () -> String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color.bizBizeInk)

            content()

            if let errorMessage = error() {
                Text(errorMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
            }
        }
    }

    private func fieldBorder(hasError: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(hasError ? Color.red.opacity(0.75) : Color.bizBizeBorder, lineWidth: 1)
    }
}
