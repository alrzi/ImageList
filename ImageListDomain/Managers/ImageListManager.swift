//
//  ImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import UIKit

public protocol ImageListManaging: Sendable {
    func fetchPhotosNextPage(_ page: Int) async throws -> [(Photo, imageData: Data)]
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}

struct ImageListManager: ImageListManaging {
    typealias ReturnType = (Photo, imageData: Data)
    
    let photosListService: PhotosListServiceProtocol
    let imageService: ImageServiceProtocol
    let likeService: LikeServiceProtocol
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [ReturnType] {
        let fetchedPhotos = try await photosListService.fetchPhotosNextPage(page)
        
        return try await withThrowingTaskGroup(
            of: ReturnType.self,
            returning: [ReturnType].self
        ) { [imageService] taskGroup in
            for photo in fetchedPhotos {
                taskGroup.addTask { [imageService] in
                    let url = try photo.imageURL
                    
                    let imageData = try await imageService.fetchImage(url: url)
                    
                    return (photo, imageData: imageData)
                }
            }
            
            return try await taskGroup.reduce(into: []) { partialResult, question in
                partialResult.append(question)
            }
        }
    }
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        try await likeService.changeLike(photoId: photoId, isLiked: isLiked)
    }
}
