//
//  ImageListDomainAssembly.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import Swinject

public final class ImageListDomainAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(ImageListManaging.self, name: "all") { r in
            ImageListManager(
                photosListService: r.resolve(PhotosListServiceProtocol.self, name: "all")!,
                likeService: r.resolve(LikeServiceProtocol.self)!
            )
        }

        container.register(ImageListManaging.self, name: "favorite") { r in
            ImageListManager(
                photosListService: r.resolve(PhotosListServiceProtocol.self, name: "favorite")!,
                likeService: r.resolve(LikeServiceProtocol.self)!
            )
        }
    }
}
