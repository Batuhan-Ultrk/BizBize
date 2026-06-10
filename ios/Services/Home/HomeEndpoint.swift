import Foundation

enum HomeEndpoint: APIEndpoint {
    case anasayfaBilgiGetir

    var path: String {
        switch self {
        case .anasayfaBilgiGetir:
            return "/home/dashboard"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var requiresAuthentication: Bool {
        true
    }
}
