//
//  ImageListType.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import ImageListDomain

enum ImageListType {
    case all
    case onlyFavorite
    
    var photoType: PhotoType {
        switch self {
        case .all: .all
        case .onlyFavorite: .favorite
        }
    }
}
