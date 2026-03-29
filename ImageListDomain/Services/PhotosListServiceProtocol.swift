//
//  PhotosListServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol PhotosListServiceProtocol: Sendable {
    func fetchPhotosNextPage(_ page: Int, type: PhotoType) async throws -> [Photo]
}
