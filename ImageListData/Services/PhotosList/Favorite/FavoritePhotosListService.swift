//
//  FavoritePhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct FavoritePhotosListService: PhotosListServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    
    private let authConfigurationProvider: AuthConfigurationProviding
    
    init(
        networkService: NetworkServiceProtocol,
        profileService: ProfileServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        authConfigurationProvider: AuthConfigurationProviding
    ) {
        self.networkService = networkService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.authConfigurationProvider = authConfigurationProvider
    }
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let username = try await profileService.fetchProfile().username
        
        let request = API.PhotoResult.FavoriteUserImagesRequest(
            userName: username,
            page: page,
            token: token,
            authConfiguration: authConfigurationProvider.config
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.map { $0.toPhoto() }
    }
}
