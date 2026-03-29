//
//  DebugLikeService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

#if DEBUG
    import Foundation
    import ImageListDomain

    struct DebugLikeService: LikeServiceProtocol {
        func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return isLiked
        }
    }
#endif
