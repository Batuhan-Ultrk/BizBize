import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case encodingFailed(Error)
    case decodingFailed(Error)
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int, response: ErrorResponseDTO?)
    case missingToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.text("network.invalidURL")
        case .encodingFailed:
            return L10n.text("network.encodingFailed")
        case .decodingFailed:
            return L10n.text("network.decodingFailed")
        case .invalidResponse:
            return L10n.text("network.invalidResponse")
        case .unauthorized:
            return L10n.text("network.unauthorized")
        case let .serverError(_, response):
            return response?.displayMessage ?? L10n.text("network.serverError")
        case .missingToken:
            return L10n.text("network.missingToken")
        }
    }
}
