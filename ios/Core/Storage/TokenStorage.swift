import Foundation
import Security

protocol TokenStorageProtocol {
    func save(token: String)
    func getToken() -> String?
    func deleteToken()
}

final class UserDefaultsTokenStorage: TokenStorageProtocol {
    private let key: String
    private let userDefaults: UserDefaults

    init(
        key: String = "bizbize.auth.token",
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.userDefaults = userDefaults
    }

    func save(token: String) {
        userDefaults.set(token, forKey: key)
    }

    func getToken() -> String? {
        userDefaults.string(forKey: key)
    }

    func deleteToken() {
        userDefaults.removeObject(forKey: key)
    }
}

final class KeychainTokenStorage: TokenStorageProtocol {
    private let service: String
    private let account: String

    init(
        service: String = Bundle.main.bundleIdentifier ?? "com.bizbize.ios",
        account: String = "authToken"
    ) {
        self.service = service
        self.account = account
    }

    func save(token: String) {
        deleteToken()

        guard let data = token.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
