//
//  DebugLikeService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

#if DEBUG
    import ImageListDomain

    struct DebugLikeService: LikeServiceProtocol {
        // MARK: - Private properties

        private let photoStore: DebugPhotoStore

        // MARK: - Lifecycle

        init(photoStore: DebugPhotoStore) {
            self.photoStore = photoStore
        }

        // MARK: - Public methods

        func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
            await photoStore.changeLike(
                photoId: photoId,
                isLiked: isLiked
            )
        }
    }
#endif
