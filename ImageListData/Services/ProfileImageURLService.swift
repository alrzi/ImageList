//
//  ProfileImageURLService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//

import Foundation
internal import NetworkService
import ImageListDomain

struct ProfileImageURLService: ProfileImageURLServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    
    private let authConfiguration: UnsplashAuthConfiguration
    
    init(
        networkService: NetworkServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        authConfiguration: UnsplashAuthConfiguration
    ) {
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.authConfiguration = authConfiguration
    }
    
    func fetchProfileImageUrl(username: String) async throws -> URL {
        let token = try await oAuth2TokenStorage.token
                
        let request = API.ProfileImageURLRequest(
            token: token,
            username: username,
            authConfiguration: authConfiguration
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
