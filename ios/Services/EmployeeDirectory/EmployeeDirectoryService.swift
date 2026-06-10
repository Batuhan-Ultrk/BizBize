import Foundation

protocol EmployeeDirectoryServiceProtocol {
    func getEmployees(search: String?, department: String?) async throws -> [EmployeeDTO]
}

struct DefaultEmployeeDirectoryService: EmployeeDirectoryServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getEmployees(search: String?, department: String?) async throws -> [EmployeeDTO] {
        try await networkManager.request(
            EmployeeDirectoryEndpoint.list(search: search, department: department),
            responseType: [EmployeeDTO].self
        )
    }
}

final class EmployeeDirectoryServiceContainer: ObservableObject {
    let service: EmployeeDirectoryServiceProtocol

    init(service: EmployeeDirectoryServiceProtocol) {
        self.service = service
    }
}
