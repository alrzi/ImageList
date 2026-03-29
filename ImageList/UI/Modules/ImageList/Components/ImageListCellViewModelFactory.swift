//
//  ImageListCellViewModelFactory.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import ImageListDomain

struct ImageListCellViewModelFactory {
    private let imageLoader: CachedImageLoaderProtocol

    init(imageLoader: CachedImageLoaderProtocol) {
        self.imageLoader = imageLoader
    }

    func makeViewModel(from photo: Photo) -> ImageListCellViewModel? {
        guard let imageURL = try? photo.imageURL else {
            return nil
        }

        return ImageListCellViewModel(
            imageId: photo.id,
            isLiked: photo.isLiked,
            date: photo.createdAt,
            imageSize: photo.size,
            detailImageURLString: photo.urls.full,
            imageURL: imageURL,
            imageLoader: imageLoader
        )
    }
}
