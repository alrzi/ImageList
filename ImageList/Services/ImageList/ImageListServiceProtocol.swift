//
//  ImageListServiceProtocol.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation

protocol ImageListServiceProtocol: Sendable {
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [Photo]
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}
