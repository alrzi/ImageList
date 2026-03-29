//
//  ImageListDataAssembly.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 05.03.2025.
//

internal import NetworkService
internal import NetworkServiceDomain
import Foundation
import HybridCache
import ImageListDomain
import Swinject

public final class ImageListDataAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        // MARK: - Session

        container.register(UserSession.self) { _ in
            UserSession(
                storage: TokenStorage(
                    service: "\(Bundle(for: Self.self).bundleIdentifier ?? "com.imagelist").oauth",
                    accessGroup: nil
                )
            )
        }
        .implements(UserSessionProtocol.self)
        .implements(SessionCredentialsProvider.self)
        .inObjectScope(.container)

        // MARK: - Network

        container.register(NetworkClientProtocol.self) { r in
            NetworkServiceContainer.makeWithToken(
                sessionProvider: r.resolve(UserSession.self)!
            )
        }
        .inObjectScope(.container)

        container.register(CachedImageLoaderProtocol.self) { r in
            CachedImageLoader(
                storage: r.resolve(FileStorageProtocol.self)!,
                networkService: r.resolve(NetworkClientProtocol.self)!
            )
        }
        .inObjectScope(.container)

        // MARK: - Services

        container.register(FileStorageProtocol.self) { _ in
            FileManagerStorage()
        }
        .inObjectScope(.container)

        container.register(PhotosListCacheProtocol.self) { r in
            PhotosListCache(storage: r.resolve(FileStorageProtocol.self)!)
        }
        .inObjectScope(.container)

        container.register(ImageServiceProtocol.self) { r in
            ImageService(
                networkService: r.resolve(NetworkClientProtocol.self)!
            )
        }

        container.register(OAuth2ServiceProtocol.self) { r in
            OAuth2Service(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!
            )
        }

        container.register(LikeServiceProtocol.self) { r in
            LikeService(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!
            )
        }

        container.register(ProfileImageURLServiceProtocol.self) { r in
            ProfileImageURLService(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!
            )
        }

        container.register(ProfileServiceProtocol.self) { r in
            ProfileService(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!
            )
        }

        container.register(PhotosListServiceProtocol.self, name: "all") { r in
            PhotosListService(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!,
                photosListCache: r.resolve(PhotosListCacheProtocol.self)!
            )
        }

        container.register(PhotosListServiceProtocol.self, name: "favorite") { r in
            FavoritePhotosListService(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                profileService: r.resolve(ProfileServiceProtocol.self)!,
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!
            )
        }
    }
}
