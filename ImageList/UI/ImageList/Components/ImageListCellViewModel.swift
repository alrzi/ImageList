//
//  ImageListCellViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2023.
//

import Foundation

struct ImageListCellViewModel: Identifiable {
    let id: String
    var isLiked: Bool
    let date: Date
    let imageSize: CGSize
    let image: Data
    
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
