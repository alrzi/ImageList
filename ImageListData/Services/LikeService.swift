//
//  LikeService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct LikeService: LikeServiceProtocol {
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
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.ChangeLikeRequest(
            photoId: photoId,
            token: token,
            method: isLiked ? .post : .delete,
            authConfiguration: authConfigurationProvider.config
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.photo.likedByUser
    }
}
