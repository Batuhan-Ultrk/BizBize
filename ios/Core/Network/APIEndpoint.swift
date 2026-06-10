import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var requiresAuthentication: Bool { get }
}

extension APIEndpoint {
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Encodable? { nil }
    var requiresAuthentication: Bool { false }
}
