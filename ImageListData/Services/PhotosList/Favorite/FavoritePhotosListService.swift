//
//  FavoritePhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation
import ImageListDomain
internal import NetworkServiceDomain

struct FavoritePhotosListService: PhotosListServiceProtocol {
    let networkService: NetworkClientProtocol
    let profileService: ProfileServiceProtocol
    let authConfigurationProvider: AuthConfigurationProviding
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let username = try await profileService.fetchProfile().username
        
        let request = API.PhotoResult.FavoriteUserImagesRequest(
            userName: username,
            page: page,
            authConfiguration: authConfigurationProvider.config
        )
        
        let response = try await networkService.perform(request)
        
        return response.map { $0.toPhoto() }
    }
}
