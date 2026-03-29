//
//  DebugImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

#if DEBUG
    import Foundation
    import ImageListDomain
    import UIKit
    import AsyncExtensions

    struct DebugImageListManager: ImageListManaging {
        private let _photosStream: CurrentValueAsyncSequence<[Photo]?> = .init(nil)
        var photosStream: CurrentValueAsyncSequenceReadOnly<[Photo]?> { _photosStream.readOnly() }

        func fetchPhotosNextPage(_ page: Int, type: PhotoType) async throws -> [Photo] {
            var mockItems: [Photo] = []

            let itemsPerPage = 8

            let startIndex = (page - 1) * itemsPerPage + 1
            let endIndex = startIndex + itemsPerPage - 1

            for index in startIndex...endIndex {
                guard let uiImage = UIImage(named: "\(index)") else {
                    continue
                }

                let photo = Photo(
                    id: UUID().uuidString,
                    size: uiImage.size,
                    createdAt: .now,
                    urls: .init(
                        full: "",
                        thumb: "",
                        regular: "",
                        small: "https://picsum.photos/200/300?random=\(index)"
                    ),
                    isLiked: Bool.random()
                )

                mockItems.append(photo)
            }

            if page >= 2 {
                throw Errors.failed
            }
            else {
                do {
                    try await Task.sleep(nanoseconds: 4_000_000_000)
                }
                catch {
                    debugPrint(error)
                }

                return mockItems.shuffled()
            }
        }

        func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            throw Errors.failed
        }
    }

    private enum Errors: Error {
        case failed
    }
#endif
