//
//  LikeService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

internal import NetworkServiceDomain
import Foundation
import ImageListDomain

struct LikeService: LikeServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding

    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        let request = API.ChangeLikeRequest(
            photoId: photoId,
            method: isLiked ? .post : .delete,
            authConfiguration: authConfigurationProvider.config
        )

        let response = try await networkService.perform(request)
        return response.photo.likedByUser
    }
}
