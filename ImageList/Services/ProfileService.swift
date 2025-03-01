//
//  ProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

import Foundation

protocol ProfileServiceProtocol {
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
        let token = try oAuth2TokenStorage.token
        
        let request = API.ProfileRequest(token: token)
        
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode(ProfileResult.self, from: data)
        
        return result.toProfile()
    }
}

private struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    func toProfile() -> Profile {
        Profile(
            username: username,
            firstName: firstName,
            lastName: lastName,
            loginName: "@" + username,
            bio: bio ?? ""
        )
    }
}
