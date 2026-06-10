import Foundation

protocol AuthServiceProtocol {
    func login(request: LoginRequestDTO) async throws -> AuthResponseDTO
    func register(request: RegisterRequestDTO) async throws -> AuthResponseDTO
    func requestPasswordReset(request: PasswordResetRequestDTO) async throws -> PasswordResetResponseDTO
}

enum AuthServiceError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return L10n.text("network.invalidResponse")
        }
    }
}

struct DefaultAuthService: AuthServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func login(request: LoginRequestDTO) async throws -> AuthResponseDTO {
        try await networkManager.request(
            AuthEndpoint.login(request),
            responseType: AuthResponseDTO.self
        )
    }

    func register(request: RegisterRequestDTO) async throws -> AuthResponseDTO {
        try await networkManager.request(
            AuthEndpoint.register(request),
            responseType: AuthResponseDTO.self
        )
    }

    func requestPasswordReset(request: PasswordResetRequestDTO) async throws -> PasswordResetResponseDTO {
        try await networkManager.request(
            AuthEndpoint.requestPasswordReset(request),
            responseType: PasswordResetResponseDTO.self
        )
    }
}
