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
        container.register(ImageListManaging.self) { r in
            ImageListManager(
                photosListService: r.resolve(PhotosListServiceProtocol.self)!,
            )
        }

        container.register(FavoriteManaging.self) { r in
            FavoriteManager(
                likeService: r.resolve(LikeServiceProtocol.self)!,
                profileService: r.resolve(ProfileServiceProtocol.self)!
            )
        }
    }
}
