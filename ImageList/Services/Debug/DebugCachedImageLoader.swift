//
//  DebugCachedImageLoader.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

#if DEBUG
    import Foundation
    import ImageListDomain
    import UIKit

    struct DebugCachedImageLoader: CachedImageLoaderProtocol {
        func loadImage(from url: URL) async throws -> Data {
            guard let image = UIImage(named: url.lastPathComponent), let data = image.pngData() else {
                throw URLError(.fileDoesNotExist)
            }

            return data
        }

        func cancelLoad(for url: URL) async {}

        func clearCache() async {}
    }
#endif
