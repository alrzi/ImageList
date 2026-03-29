//
//  ImageListViewModelFactory.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import ImageListDomain

struct ImageListViewModelFactory: ImageListViewModelFactoryProtocol {
    private let factory: ImageListCellViewModelFactory
    private let favoriteManager: FavoriteManaging
    private let favoriteImageListManager: ImageListManaging
    
    init(
        factory: ImageListCellViewModelFactory,
        favoriteManager: FavoriteManaging,
        favoriteImageListManager: ImageListManaging
    ) {
        self.factory = factory
        self.favoriteManager = favoriteManager
        self.favoriteImageListManager = favoriteImageListManager
    }
       
    func makeImageListViewModel(
        imageListType: ImageListType,
        eventsHandler: @escaping (ImageListOutput) -> Void
    ) -> ImageListViewModel {
        ImageListViewModel(
            imageListManager: favoriteImageListManager,
            imageListType: imageListType,
            factory: factory,
            favoriteManager: favoriteManager,
            eventsHandler: eventsHandler
        )
    }
}
