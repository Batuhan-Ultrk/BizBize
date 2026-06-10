import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "birth_date")
    var birthDate: Date

    @Field(key: "phone_number")
    var phoneNumber: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @OptionalField(key: "department")
    var department: String?

    @OptionalField(key: "start_date")
    var startDate: Date?

    @OptionalField(key: "profile_photo")
    var profilePhoto: String?

    @Field(key: "password_reset_required")
    var passwordResetRequired: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        firstName: String,
        lastName: String,
        birthDate: Date,
        phoneNumber: String,
        email: String,
        passwordHash: String,
        department: String? = nil,
        startDate: Date? = nil,
        profilePhoto: String? = nil,
        passwordResetRequired: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.phoneNumber = phoneNumber
        self.email = email
        self.passwordHash = passwordHash
        self.department = department
        self.startDate = startDate
        self.profilePhoto = profilePhoto
        self.passwordResetRequired = passwordResetRequired
    }

    func toPublicDTO() throws -> PublicUserDTO {
        PublicUserDTO(
            id: try requireID(),
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            phoneNumber: phoneNumber,
            email: email,
            department: department,
            startDate: startDate,
            profilePhoto: profilePhoto,
            createdAt: createdAt
        )
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, FieldProperty<User, String>> {
        \User.$email
    }

    static var passwordHashKey: KeyPath<User, FieldProperty<User, String>> {
        \User.$passwordHash
    }

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }
}
