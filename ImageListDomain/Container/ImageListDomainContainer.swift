//
//  ImageListDomainContainer.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public enum ImageListDomainContainer {
    public static func buildImageListManager(
        photosListService: PhotosListServiceProtocol,
        imageService: ImageServiceProtocol,
        likeService: LikeServiceProtocol
    ) -> ImageListManaging {
        ImageListManager(
            photosListService: photosListService,
            imageService: imageService,
            likeService: likeService
        )
    }
}
