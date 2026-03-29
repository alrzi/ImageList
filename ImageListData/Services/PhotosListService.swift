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
    let requestFactory: PhotosRequestFactory

    func fetchPhotosNextPage(_ page: Int, type: PhotoType) async throws -> [Photo] {
        let request = try await requestFactory.makeRequest(page: page, type: type)
        let response = try await networkService.perform(request)
        return response.map { $0.toPhoto() }
    }
}
