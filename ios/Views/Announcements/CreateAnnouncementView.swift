import SwiftUI

struct CreateAnnouncementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateAnnouncementViewModel

    let onCreated: () -> Void

    init(viewModel: CreateAnnouncementViewModel, onCreated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreated = onCreated
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                field("Başlık") {
                    TextField("Duyuru başlığı girin", text: $viewModel.title)
                        .textInputAutocapitalization(.sentences)
                        .padding(14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(fieldBorder(hasError: viewModel.titleError != nil))
                } error: {
                    viewModel.titleError
                }

                field("İçerik") {
                    TextEditor(text: $viewModel.body)
                        .frame(minHeight: 150)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(fieldBorder(hasError: viewModel.bodyError != nil))
                } error: {
                    viewModel.bodyError
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Duyuru Türü")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.bizBizeInk)

                    AnnouncementTypePicker(selectedType: $viewModel.selectedType)
                }

                Toggle("Etkinlik tarihi ekle", isOn: $viewModel.includesEventDate)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeInk)
                    .tint(Color.bizBizeButtonStart)

                if viewModel.includesEventDate {
                    DatePicker("Tarih", selection: $viewModel.eventDate, displayedComponents: [.date, .hourAndMinute])
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.bizBizeInk)
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Toggle("RSVP aktif", isOn: $viewModel.hasRsvp)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(viewModel.selectedType.supportsRsvp ? Color.bizBizeInk : Color.bizBizeMuted)
                    .tint(Color.bizBizeButtonStart)
                    .disabled(!viewModel.selectedType.supportsRsvp)

                PrimaryButton(title: "Yayınla", systemImage: "paperplane.fill", isLoading: viewModel.isLoading) {
                    Task {
                        let didCreate = await viewModel.createAnnouncement()
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
        .navigationTitle("Yeni Duyuru")
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
