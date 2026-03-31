//
//  ImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import UIKit

public protocol ImageListManaging: Sendable {
    func fetchPhotosNextPage(_ page: Int, type: PhotoType) async throws -> [Photo]
}

public struct ImageListManager: ImageListManaging {
    let photosListService: PhotosListServiceProtocol

    public init(photosListService: PhotosListServiceProtocol) {
        self.photosListService = photosListService        
    }

    public func fetchPhotosNextPage(_ page: Int, type: PhotoType) async throws -> [Photo] {
        try await photosListService.fetchPhotosNextPage(page, type: type)
    }
}
