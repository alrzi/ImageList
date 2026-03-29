//
//  ProfileModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import Foundation

struct ProfileModel: Equatable {
    let name: String
    let email: String
    let greeting: String
    let totalLikes: Int
    let avatarURL: URL?

    init(
        name: String,
        email: String,
        greeting: String,
        totalLikes: Int,
        avatarURL: URL? = nil
    ) {
        self.name = name
        self.email = email
        self.greeting = greeting
        self.totalLikes = totalLikes
        self.avatarURL = avatarURL
    }
}
