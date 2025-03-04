//
//  FavoriteImageListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation

struct FavoriteImageListService: ImageListServiceProtocol {
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
    private let profileService: ProfileService
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        decoder: JSONDecoder,
        networkService: NetworkClientProtocol,
        profileService: ProfileService,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.decoder = decoder
        self.networkService = networkService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let username = try await profileService.fetchProfile().username
        
        let request = API.PhotoResult.FavoriteUserImagesRequest(
            userName: username,
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
