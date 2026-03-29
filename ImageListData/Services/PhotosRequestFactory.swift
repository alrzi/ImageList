//
//  PhotosRequestFactory.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 30.03.2026.
//

internal import NetworkServiceDomain
import Foundation
import ImageListDomain

protocol PhotosRequestFactory: Sendable {
    func makeRequest(page: Int, type: PhotoType) async throws -> any PhotoResultRequest
}

struct PhotosRequestFactoryImpl: PhotosRequestFactory {
    private let profileService: ProfileServiceProtocol
    private let authConfiguration: UnsplashAuthConfiguration
    
    init(profileService: ProfileServiceProtocol, authConfiguration: UnsplashAuthConfiguration) {
        self.profileService = profileService
        self.authConfiguration = authConfiguration
    }
    
    func makeRequest(page: Int, type: PhotoType) async throws -> any PhotoResultRequest {
        switch type {
        case .all:
            API.PhotoResult.PhotosNextPageRequest(
                page: page,
                authConfiguration: authConfiguration
            )

        case .favorite:
            API.PhotoResult.FavoriteUserImagesRequest(
                userName: try await profileService.fetchProfile().username,
                page: page,
                authConfiguration: authConfiguration
            )
        }
    }
}

protocol PhotoResultRequest: RequestProtocol, DecoderProviding
where Response == [API.PhotoResult.PhotoResult] { }

extension API.PhotoResult.PhotosNextPageRequest: PhotoResultRequest {}
extension API.PhotoResult.FavoriteUserImagesRequest: PhotoResultRequest {}
