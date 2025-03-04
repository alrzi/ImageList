//
//  ProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

import Foundation

protocol ProfileServiceProtocol: Sendable {
    func fetchProfile() async throws -> Profile
}

struct ProfileService: ProfileServiceProtocol {
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        decoder: JSONDecoder,
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.decoder = decoder
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func fetchProfile() async throws -> Profile {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.ProfileRequest(token: token)
        
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
