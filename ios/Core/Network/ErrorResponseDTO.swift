import Foundation

struct ErrorResponseDTO: Decodable {
    let reason: String?
    let message: String?
    let error: Bool?
    let statusCode: Int?
    let code: String?

    var displayMessage: String? {
        reason ?? message
    }
}
