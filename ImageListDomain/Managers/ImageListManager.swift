//
//  ImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import UIKit

public protocol ImageListManaging: Sendable {
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo]
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}

struct ImageListManager: ImageListManaging {
    let photosListService: PhotosListServiceProtocol
    let likeService: LikeServiceProtocol

    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        try await photosListService.fetchPhotosNextPage(page)
    }

    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        try await likeService.changeLike(photoId: photoId, isLiked: isLiked)
    }
}
