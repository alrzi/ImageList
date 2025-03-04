//
//  PhotosListServiceProtocol.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

import Foundation

protocol PhotosListServiceProtocol: Sendable {
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [Photo]
}
