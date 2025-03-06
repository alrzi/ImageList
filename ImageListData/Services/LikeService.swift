//
//  LikeService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

import Foundation
internal import NetworkService
import ImageListDomain

struct LikeService: LikeServiceProtocol {
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
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.ChangeLikeRequest(
            photoId: photoId,
            token: token,
            method: isLiked ? .post : .delete,
            authConfiguration: authConfiguration
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.photo.likedByUser
    }
}
