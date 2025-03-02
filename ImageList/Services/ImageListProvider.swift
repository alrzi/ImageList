//
//  ImageListProvider.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

protocol ImageListProviding: Sendable {
    func fetchPhotosNextPage(_ page: Int) async throws -> [(Photo, imageData: Data)]
}

struct ImageListProvider: ImageListProviding {
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
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [ReturnType] {
        let fetchedPhotos = try await imageListService.fetchPhotosNextPage(page)
        
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
}
