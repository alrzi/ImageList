//
//  LikeService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

import Foundation

protocol LikeServiceProtocol: Sendable {
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}

struct LikeService: LikeServiceProtocol {
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.ChangeLikeRequest(
            photoId: photoId,
            token: token,
            method: isLiked ? .post : .delete
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.photo.likedByUser
    }
}
