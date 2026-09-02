//
//  DebugPhotoStore.swift
//  ImageList
//

#if DEBUG
    import Foundation
    import ImageListDomain

    actor DebugPhotoStore {
        // MARK: - Private properties

        private var photos: [Photo]

        // MARK: - Lifecycle

        init() {
            photos = (1...8).map { index in
                Photo(
                    id: "debug-photo-\(index)",
                    size: .init(width: 200, height: 300),
                    createdAt: .now,
                    urls: .init(
                        full: "debug://images/\(index)",
                        thumb: "debug://images/\(index)",
                        regular: "debug://images/\(index)",
                        small: "debug://images/\(index)"
                    ),
                    isLiked: [1, 3, 5].contains(index)
                )
            }
        }

        // MARK: - Public methods

        func photos(for type: PhotoType) -> [Photo] {
            switch type {
            case .all:
                photos

            case .favorite:
                photos.filter(\.isLiked)
            }
        }

        func changeLike(photoId: String, isLiked: Bool) -> Bool {
            guard let index = photos.firstIndex(where: { $0.id == photoId }) else {
                return false
            }

            photos[index].isLiked = isLiked
            return photos[index].isLiked
        }

        func totalLikes() -> Int {
            photos.filter(\.isLiked).count
        }
    }
#endif
