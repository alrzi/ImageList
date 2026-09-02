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
    let photoStore = DebugPhotoStore()

    return ImageListViewModel(
        imageListManager: DebugImageListManager(photoStore: photoStore),
        imageListType: .all,
        factory: ImageListCellViewModelFactory(
            imageLoader: DebugCachedImageLoader()
        ),
        favoriteManager: FavoriteManager(
            likeService: DebugLikeService(photoStore: photoStore),
            profileService: DebugProfileService(photoStore: photoStore)
        )
    ) { _ in }
}
#endif
