//
//  ImageListDataAssembly.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import Swinject
import ImageListDomain
internal import NetworkService
internal import NetworkServiceDomain

public final class ImageListDataAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Container) {
        // MARK: - Session
        container.register(UserSession.self) { r in
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
        
        // MARK: - Services
        container.register(ImageServiceProtocol.self) { r in
            ImageService(
                networkService: r.resolve(NetworkClientProtocol.self)!,
                imageDataCache: Cache()
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
                authConfigurationProvider: r.resolve(AuthConfigurationProviding.self)!
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
