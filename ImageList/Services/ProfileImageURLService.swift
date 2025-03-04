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
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func fetchProfileImageUrl(username: String) async throws -> URL {
        let token = try await oAuth2TokenStorage.token
                
        let request = API.ProfileImageURLRequest(
            token: token,
            username: username
        )
                
        let response = try await networkService.fetchData(for: request)
        
        guard let url = URL(string: response.profileImage.large) else {
            throw Errors.urlCreationFailed
        }
        
        return url
    }
}

private enum Errors: Error {
    case urlCreationFailed
}
