//
//  FavoritePhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation
internal import NetworkService
import ImageListDomain

struct FavoritePhotosListService: PhotosListServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    
    private let authConfiguration: UnsplashAuthConfiguration
    
    init(
        networkService: NetworkServiceProtocol,
        profileService: ProfileServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        authConfiguration: UnsplashAuthConfiguration
    ) {
        self.networkService = networkService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.authConfiguration = authConfiguration
    }
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let username = try await profileService.fetchProfile().username
        
        let request = API.PhotoResult.FavoriteUserImagesRequest(
            userName: username,
            page: page,
            token: token,
            authConfiguration: authConfiguration
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.map { $0.toPhoto() }
    }
}
