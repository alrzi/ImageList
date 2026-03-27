//
//  PhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation
import ImageListDomain
internal import NetworkServiceDomain

struct PhotosListService: PhotosListServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let request = API.PhotoResult.PhotosNextPageRequest(
            page: page,
            authConfiguration: authConfigurationProvider.config
        )
        
        let response = try await networkService.perform(request)
        
        return response.map { $0.toPhoto() }
    }
}
