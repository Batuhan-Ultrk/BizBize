import Foundation

enum EmployeeDirectoryEndpoint: APIEndpoint {
    case list(search: String?, department: String?)

    var path: String {
        "/home/employees"
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .list(search, department):
            var items: [URLQueryItem] = []

            if let search,
               !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }

            if let department,
               !department.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(URLQueryItem(name: "department", value: department))
            }

            return items.isEmpty ? nil : items
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
