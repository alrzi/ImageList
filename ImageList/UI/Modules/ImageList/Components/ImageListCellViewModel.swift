//
//  ImageListCellViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2023.
//

import Foundation
import ImageListDomain
import SwiftUI

struct ImageListCellViewModel: Identifiable {
    let id = UUID()
    let imageId: String
    var isLiked: Bool
    let date: Date
    let imageSize: CGSize
    let detailImageURLString: String
    let imageURL: URL
    let imageLoader: CachedImageLoaderProtocol

    var detailImageURL: URL {
        get throws {
            guard let url = URL(string: detailImageURLString) else {
                throw Errors.badURL
            }

            return url
        }
    }

    init?(
        imageId: String,
        isLiked: Bool,
        date: Date,
        imageSize: CGSize,
        detailImageURLString: String,
        imageURL: URL,
        imageLoader: CachedImageLoaderProtocol
    ) {
        self.imageId = imageId
        self.isLiked = isLiked
        self.date = date
        self.imageSize = imageSize
        self.detailImageURLString = detailImageURLString
        self.imageURL = imageURL
        self.imageLoader = imageLoader
    }

    func imageSize(for screenWidth: CGFloat, paddingHorizontal: CGFloat) -> CGSize {
        let insets = EdgeInsets(top: 6, left: paddingHorizontal, right: paddingHorizontal, bottom: 6)
        let imageViewWidth = screenWidth - insets.left - insets.right
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scale = imageViewWidth / imageWidth
        let height = (imageHeight * scale) + insets.top + insets.bottom

        return .init(width: imageViewWidth, height: height)
    }
}

extension ImageListCellViewModel {
    func withIsLiked(_ isLiked: Bool) -> ImageListCellViewModel {
        var result = self
        result.isLiked = isLiked
        return result
    }
}

private enum Errors: Error {
    case badURL
}
