import Foundation

enum L10n {
    static func text(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: "tr", ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }

        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
