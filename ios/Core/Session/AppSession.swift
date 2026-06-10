import Foundation

@MainActor
final class AppSession: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var currentUser: PublicUserDTO?

    private let tokenStorage: TokenStorageProtocol
    private let userDefaults: UserDefaults
    private let currentUserKey: String
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        tokenStorage: TokenStorageProtocol,
        userDefaults: UserDefaults = .standard,
        currentUserKey: String = "bizbize.session.currentUser"
    ) {
        self.tokenStorage = tokenStorage
        self.userDefaults = userDefaults
        self.currentUserKey = currentUserKey

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        self.currentUser = Self.restoreUser(
            from: userDefaults,
            key: currentUserKey,
            decoder: decoder
        )
        self.isAuthenticated = tokenStorage.getToken() != nil
    }

    func restoreSession() {
        currentUser = Self.restoreUser(
            from: userDefaults,
            key: currentUserKey,
            decoder: decoder
        )
        isAuthenticated = tokenStorage.getToken() != nil
    }

    func setSession(authResponse: AuthResponseDTO) {
        tokenStorage.save(token: authResponse.token)
        currentUser = authResponse.user
        isAuthenticated = true

        if let data = try? encoder.encode(authResponse.user) {
            userDefaults.set(data, forKey: currentUserKey)
        }
    }

    func clearSession() {
        tokenStorage.deleteToken()
        userDefaults.removeObject(forKey: currentUserKey)
        currentUser = nil
        isAuthenticated = false
    }

    func updateCurrentUser(_ user: PublicUserDTO) {
        currentUser = user

        if let data = try? encoder.encode(user) {
            userDefaults.set(data, forKey: currentUserKey)
        }
    }

    private static func restoreUser(
        from userDefaults: UserDefaults,
        key: String,
        decoder: JSONDecoder
    ) -> PublicUserDTO? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        return try? decoder.decode(PublicUserDTO.self, from: data)
    }
}
