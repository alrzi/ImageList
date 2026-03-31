//
//  ImageListViewModel+debug.swift
//  ImageList
//
//  Created by Александр Зиновьев on 3/31/26.
//

import Foundation
import ImageListDomain

#if DEBUG
@MainActor
func makeImageListViewModelDebug() -> ImageListViewModel {
    ImageListViewModel(
        imageListManager: DebugImageListManager(),
        imageListType: .all,
        factory: ImageListCellViewModelFactory(
            imageLoader: DebugCachedImageLoader()
        ),
        favoriteManager: FavoriteManager(
            likeService: DebugLikeService(),
            profileService: DebugProfileService()
        )
    ) { _ in }
}
#endif
