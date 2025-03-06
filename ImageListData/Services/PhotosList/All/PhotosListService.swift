//
//  PhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct PhotosListService: PhotosListServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    
    private let authConfigurationProvider: AuthConfigurationProviding
    
    init(networkService: NetworkServiceProtocol, oAuth2TokenStorage: OAuth2TokenStorageProtocol, authConfigurationProvider: AuthConfigurationProviding) {
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.authConfigurationProvider = authConfigurationProvider
    }
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.PhotoResult.PhotosNextPageRequest(
            page: page,
            token: token,
            authConfiguration: authConfigurationProvider.config
        )
        
        let response = try await networkService.fetchData(for: request)
        
        return response.map { $0.toPhoto() }
    }
}
