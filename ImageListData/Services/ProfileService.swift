//
//  ProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

internal import NetworkServiceDomain
import Foundation
import ImageListDomain

struct ProfileService: ProfileServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding

    func fetchProfile() async throws -> Profile {
        let request = API.ProfileRequest(
            authConfiguration: authConfigurationProvider.config
        )

        let response = try await networkService.perform(request)

        return response.toProfile()
    }
}

private extension API.ProfileResult {
    func toProfile() -> Profile {
        Profile(
            username: username,
            firstName: firstName,
            lastName: lastName,
            loginName: "@" + username,
            totalLikes: totalLikes,
            bio: bio ?? ""
        )
    }
}
