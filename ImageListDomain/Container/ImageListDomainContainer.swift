//
//  ImageListDomainContainer.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public enum ImageListDomainContainer {
    public static func oAuth2TokenStorage(secureStorage: SecureStorageProtocol) -> OAuth2TokenStorageProtocol {
        OAuth2TokenStorage(secureStorage: secureStorage)
    }
    
    public static func imageListManager(
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
