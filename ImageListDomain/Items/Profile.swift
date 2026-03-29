//
//  Profile.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

public struct Profile: Sendable {
    public let username: String
    public let firstName: String
    public let lastName: String
    public let loginName: String
    public let totalLikes: Int
    public let bio: String

    public var fullName: String {
        "\(firstName) \(lastName)"
    }

    public init(
        username: String,
        firstName: String,
        lastName: String,
        loginName: String,
        totalLikes: Int,
        bio: String
    ) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.loginName = loginName
        self.totalLikes = totalLikes
        self.bio = bio
    }
}
