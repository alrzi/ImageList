//
//  ImageListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation

struct ImageListService: ImageListServiceProtocol {
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        decoder: JSONDecoder,
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.decoder = decoder
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.PhotoResult.PhotosNextPageRequest(
            params: params,
            token: token
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.map { $0.toPhoto() }
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
