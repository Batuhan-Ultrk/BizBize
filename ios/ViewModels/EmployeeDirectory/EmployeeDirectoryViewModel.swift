import Foundation

@MainActor
final class EmployeeDirectoryViewModel: ObservableObject {
    @Published var employees: [EmployeeDTO] = []
    @Published var searchText = ""
    @Published var selectedDepartment: String?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let employeeDirectoryService: EmployeeDirectoryServiceProtocol

    init(employeeDirectoryService: EmployeeDirectoryServiceProtocol) {
        self.employeeDirectoryService = employeeDirectoryService
    }

    func fetchEmployees() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            employees = try await employeeDirectoryService.getEmployees(
                search: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                department: selectedDepartment
            )
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func clearFilters() async {
        searchText = ""
        selectedDepartment = nil
        await fetchEmployees()
    }

    var departments: [String] {
        Array(Set(employees.compactMap(\.department))).sorted()
    }
}
