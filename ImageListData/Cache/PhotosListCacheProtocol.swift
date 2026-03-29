//
//  PhotosListCacheProtocol.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 28.03.2026.
//

import Foundation

protocol PhotosListCacheProtocol: Sendable {
    func getPhotos(page: Int) async throws -> [API.PhotoResult.PhotoResult]?
    func setPhotos(_ photos: [API.PhotoResult.PhotoResult], page: Int) async throws
    func clearCache() async throws
}
