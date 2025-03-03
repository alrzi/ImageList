//
//  DebugImageListManager.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

#if DEBUG
import Foundation
import UIKit

struct DebugImageListManager: ImageListManaging {
    typealias ReturnType = (Photo, imageData: Data)
    
    func fetchPhotosNextPage(_ params: FetchingRequestParams) async throws -> [ReturnType] {
        var mockItems: [ReturnType] = []

        let itemsPerPage = 8

        let startIndex = (params.page - 1) * itemsPerPage + 1
        let endIndex = startIndex + itemsPerPage - 1

        for index in startIndex...endIndex {
            guard let uiImage = UIImage(named: "image\(index)") else {
                continue
            }

            guard let imageData = uiImage.pngData() else {
                continue
            }

            let photo = Photo(
                id: UUID().uuidString,
                size: uiImage.size,
                createdAt: .now,
                urls: .init(full: "", thumb: "", regular: "", small: ""),
                isLiked: Bool.random()
            )

            mockItems.append((photo, imageData))
        }

        if params.page >= 2 {
            throw Errors.failed
        }
        else {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            catch {
                debugPrint(error)
            }

            return mockItems.shuffled()
//            return []
        }
    }
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw Errors.failed
//        return isLiked
    }
}

private enum Errors: Error {
    case failed
}
#endif
