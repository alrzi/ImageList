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
    
    public static var oAuth2TokenStorage: OAuth2TokenStorageProtocol { OAuth2TokenStorage(keychain: secureStorage) }
    public static var imageService: ImageServiceProtocol { ImageService(networkService: networkService) }
    
    public static func oAuth2Service(authConfiguration: UnsplashAuthConfiguration) -> OAuth2ServiceProtocol {
        OAuth2Service(networkService: networkService, authConfiguration: authConfiguration)
    }
    
    public static func likeService(authConfiguration: UnsplashAuthConfiguration) -> LikeServiceProtocol {
        LikeService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfiguration: authConfiguration)
    }
    
    public static func profileImageURLService(authConfiguration: UnsplashAuthConfiguration) -> ProfileImageURLServiceProtocol {
        ProfileImageURLService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfiguration: authConfiguration)
    }
    
    public static func profileService(authConfiguration: UnsplashAuthConfiguration) -> ProfileServiceProtocol {
        ProfileService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfiguration: authConfiguration)
    }
    
    public static func photosListService(authConfiguration: UnsplashAuthConfiguration) -> PhotosListServiceProtocol {
        PhotosListService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage, authConfiguration: authConfiguration)
    }
    
    public static func favoritePhotosListService(authConfiguration: UnsplashAuthConfiguration) -> PhotosListServiceProtocol {
        FavoritePhotosListService(
            networkService: networkService,
            profileService: profileService(authConfiguration: authConfiguration),
            oAuth2TokenStorage: oAuth2TokenStorage,
            authConfiguration: authConfiguration
        )
    }
}
