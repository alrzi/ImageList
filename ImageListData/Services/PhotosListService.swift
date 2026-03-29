//
//  PhotosListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

internal import NetworkServiceDomain
import Foundation
import ImageListDomain

struct PhotosListService: PhotosListServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding
    let photosListCache: PhotosListCacheProtocol

    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let request = API.PhotoResult.PhotosNextPageRequest(
            page: page,
            authConfiguration: authConfigurationProvider.config
        )

        do {
            let response = try await networkService.perform(request)

            // Сохраняем API ответ в кэш (ошибка кэша не прерывает загрузку)
            try? await photosListCache.setPhotos(response, page: page)

            return response.map { $0.toPhoto() }
        }
        catch {
            // Сеть недоступна — пробуем кэш (ошибка кэша не прерывает загрузку)
            if let cachedResults = try? await photosListCache.getPhotos(page: page) {
                return cachedResults.map { $0.toPhoto() }
            }
            throw error
        }
    }
}
