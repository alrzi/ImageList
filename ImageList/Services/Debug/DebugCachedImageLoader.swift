//
//  DebugCachedImageLoader.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

#if DEBUG
    import Foundation
    import ImageListDomain

    struct DebugCachedImageLoader: CachedImageLoaderProtocol {
        func loadImage(from url: URL) async throws -> Data {
            Data()
        }

        func cancelLoad(for url: URL) async {}

        func clearCache() async {}
    }
#endif
