//
//  DebugImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

#if DEBUG
    import ImageListDomain

    final class DebugImageListManager: ImageListManaging {
        // MARK: - Private properties

        private let photoStore: DebugPhotoStore

        // MARK: - Lifecycle

        init(photoStore: DebugPhotoStore) {
            self.photoStore = photoStore
        }

        // MARK: - Public methods

        func fetchPhotosNextPage(_ page: Int, type: PhotoType) async throws -> [Photo] {
            guard page == 1 else {
                return []
            }

            return await photoStore.photos(for: type)
        }
    }
#endif
