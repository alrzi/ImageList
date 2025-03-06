//
//  PhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation
internal import NetworkService
import ImageListDomain

struct PhotosListService: PhotosListServiceProtocol {
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
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.PhotoResult.PhotosNextPageRequest(
            page: page,
            token: token,
            authConfiguration: authConfiguration
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.map { $0.toPhoto() }
    }
}
