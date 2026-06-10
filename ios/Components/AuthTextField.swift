import SwiftUI

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var systemImage: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .sentences
    var showsLeadingIcon = true
    var errorMessage: String?

    @State private var isPasswordVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                if showsLeadingIcon {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.bizBizePrimary)
                        .frame(width: 22)
                }

                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .foregroundStyle(Color.bizBizeInk)
                .font(.body.weight(.semibold))

                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.bizBizeMuted)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isPasswordVisible ? L10n.text("auth.password.hide") : L10n.text("auth.password.show"))
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(errorMessage == nil ? Color.bizBizeBorder : .red.opacity(0.75), lineWidth: 1.2)
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
