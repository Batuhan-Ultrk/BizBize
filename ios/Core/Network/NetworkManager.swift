import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

final class DefaultNetworkManager: NetworkManagerProtocol {
    private let baseURL: URL
    private let urlSession: URLSession
    private let tokenStorage: TokenStorageProtocol?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: URL = APIEnvironment.baseURL,
        urlSession: URLSession = .shared,
        tokenStorage: TokenStorageProtocol? = nil
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.tokenStorage = tokenStorage

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let urlRequest = try makeURLRequest(for: endpoint)
        let (data, response) = try await urlSession.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let backendError = try? decoder.decode(ErrorResponseDTO.self, from: data)

            if httpResponse.statusCode == 401, backendError?.displayMessage == nil {
                throw NetworkError.unauthorized
            }

            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                response: backendError
            )
        }

        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! T
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    private func makeURLRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = endpoint.body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw NetworkError.encodingFailed(error)
            }
        }

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if endpoint.requiresAuthentication {
            guard let token = tokenStorage?.getToken(), !token.isEmpty else {
                throw NetworkError.missingToken
            }

            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        self.encodeClosure = encodable.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
