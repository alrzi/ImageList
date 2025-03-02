//
//  ProfileImageURLService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//

import Foundation

protocol ProfileImageURLServiceProtocol: Sendable {
    func fetchProfileImageUrl(username: String) async throws -> URL
}

struct ProfileImageURLService: ProfileImageURLServiceProtocol {
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
    
    func fetchProfileImageUrl(username: String) async throws -> URL {
        let token = try await oAuth2TokenStorage.token
                
        let request = API.ProfileImageURLRequest(
            token: token,
            username: username,
            authConfiguration: .standard
        )
                
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode(UserResult.self, from: data)
        
        guard let url = URL(string: result.profileImage.large) else {
            throw Errors.urlCreationFailed
        }
        
        return url
    }
}

private extension ProfileImageURLService {
    struct UserResult: Decodable {
        let profileImage: ProfileImage
    }
    
    struct ProfileImage: Decodable {
        let small: String
        let medium: String
        let large: String
    }
}

private enum Errors: Error {
    case urlCreationFailed
}
