//
//  ImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import UIKit

protocol ImageListManaging: Sendable {
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [(Photo, imageData: Data)]
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}

struct ImageListManager: ImageListManaging {
    typealias ReturnType = (Photo, imageData: Data)
    
    private let imageListService: ImageListServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    init(
        imageListService: ImageListServiceProtocol,
        profileImageService: ProfileImageServiceProtocol
    ) {
        self.imageListService = imageListService
        self.profileImageService = profileImageService
    }
    
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [ReturnType] {
        let fetchedPhotos = try await imageListService.fetchPhotosNextPage(params)
        
        return try await withThrowingTaskGroup(
            of: ReturnType.self,
            returning: [ReturnType].self
        ) { [profileImageService] taskGroup in
            for photo in fetchedPhotos {
                taskGroup.addTask { [profileImageService] in
                    let url = try photo.imageURL
                    
                    let imageData = try await profileImageService.fetchProfileImage(url: url)
                    
                    return (photo, imageData: imageData)
                }
            }
            
            return try await taskGroup.reduce(into: []) { partialResult, question in
                partialResult.append(question)
            }
        }
    }
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        try await imageListService.changeLike(photoId: photoId, isLiked: isLiked)
    }
}
