//
//  PhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation

struct PhotosListService: PhotosListServiceProtocol {
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
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
}
