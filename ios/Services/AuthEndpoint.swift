import Foundation

enum AuthEndpoint: APIEndpoint {
    case register(RegisterRequestDTO)
    case login(LoginRequestDTO)
    case requestPasswordReset(PasswordResetRequestDTO)

    var path: String {
        switch self {
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .requestPasswordReset:
            return "/auth/password-reset"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Encodable? {
        switch self {
        case let .register(request):
            return request
        case let .login(request):
            return request
        case let .requestPasswordReset(request):
            return request
        }
    }

    var requiresAuthentication: Bool {
        false
    }
}
