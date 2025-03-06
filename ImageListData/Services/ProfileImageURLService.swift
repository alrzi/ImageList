//
//  ProfileImageURLService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct ProfileImageURLService: ProfileImageURLServiceProtocol {
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
    
    func fetchProfileImageUrl(username: String) async throws -> URL {
        let token = try await oAuth2TokenStorage.token
                
        let request = API.ProfileImageURLRequest(
            token: token,
            username: username,
            authConfiguration: authConfigurationProvider.config
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
