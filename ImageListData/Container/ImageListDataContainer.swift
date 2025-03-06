//
//  ImageListDataContainer.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import ImageListDomain
internal import NetworkService

public enum ImageListDataContainer {
    static var networkService: NetworkServiceProtocol { NetworkService(session: .shared) }
    
    public static let secureStorage: SecureStorageProtocol = KeychainService()
    
    public static var imageService: ImageServiceProtocol { ImageService(networkService: networkService) }
    
    public static func oAuth2Service(
        authConfigurationProvider: AuthConfigurationProviding
    ) -> OAuth2ServiceProtocol {
        OAuth2Service(networkService: networkService, authConfigurationProvider: authConfigurationProvider)
    }
    
    public static func likeService(
        authConfigurationProvider: AuthConfigurationProviding,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) -> LikeServiceProtocol {
        LikeService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfigurationProvider: authConfigurationProvider)
    }
    
    public static func profileImageURLService(
        authConfigurationProvider: AuthConfigurationProviding,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) -> ProfileImageURLServiceProtocol {
        ProfileImageURLService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfigurationProvider: authConfigurationProvider)
    }
    
    public static func profileService(
        authConfigurationProvider: AuthConfigurationProviding,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) -> ProfileServiceProtocol {
        ProfileService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfigurationProvider: authConfigurationProvider)
    }
    
    public static func photosListService(
        authConfigurationProvider: AuthConfigurationProviding,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) -> PhotosListServiceProtocol {
        PhotosListService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfigurationProvider: authConfigurationProvider)
    }
    
    public static func favoritePhotosListService(
        authConfigurationProvider: AuthConfigurationProviding,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) -> PhotosListServiceProtocol {
        FavoritePhotosListService(
            networkService: networkService,
            profileService: profileService(authConfigurationProvider: authConfigurationProvider, oAuth2TokenStorage: oAuth2TokenStorage),
            oAuth2TokenStorage: oAuth2TokenStorage,
            authConfigurationProvider: authConfigurationProvider
        )
    }
}
