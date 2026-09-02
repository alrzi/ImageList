//
//  DebugServicesAssembly.swift
//  ImageList
//

#if DEBUG
    import ImageListDomain
    import Swinject

    final class DebugServicesAssembly: Assembly {
        func assemble(container: Container) {
            container.register(DebugPhotoStore.self) { _ in
                DebugPhotoStore()
            }
            .inObjectScope(.container)

            container.register(ImageListManaging.self) { r in
                DebugImageListManager(
                    photoStore: r.resolve(DebugPhotoStore.self)!
                )
            }
            .inObjectScope(.container)

            container.register(LikeServiceProtocol.self) { r in
                DebugLikeService(
                    photoStore: r.resolve(DebugPhotoStore.self)!
                )
            }
            .inObjectScope(.container)

            container.register(ProfileServiceProtocol.self) { r in
                DebugProfileService(
                    photoStore: r.resolve(DebugPhotoStore.self)!
                )
            }
            .inObjectScope(.container)

            container.register(ProfileImageURLServiceProtocol.self) { r in
                DebugProfileService(
                    photoStore: r.resolve(DebugPhotoStore.self)!
                )
            }
            .inObjectScope(.container)

            container.register(CachedImageLoaderProtocol.self) { _ in
                DebugCachedImageLoader()
            }
            .inObjectScope(.container)

            container.register(FavoriteManaging.self) { r in
                FavoriteManager(
                    likeService: r.resolve(LikeServiceProtocol.self)!,
                    profileService: r.resolve(ProfileServiceProtocol.self)!
                )
            }
            .inObjectScope(.container)
        }
    }
#endif
