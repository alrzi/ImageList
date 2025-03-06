//
//  ProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct ProfileService: ProfileServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    
    private let authConfigurationProvider: AuthConfigurationProviding
    
    init(
        networkService: NetworkServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        authConfigurationProvider: AuthConfigurationProviding
    ) {
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.authConfigurationProvider = authConfigurationProvider
    }
    
    func fetchProfile() async throws -> Profile {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.ProfileRequest(
            token: token,
            authConfiguration: authConfigurationProvider.config
        )
        
        let response = try await networkService.fetchData(for: request)
        
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
