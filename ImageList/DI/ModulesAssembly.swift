//
//  ModulesAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.03.2025.
//

import Foundation
import ImageListDomain
import NetworkServiceDomain
import Swinject

final class ModulesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(WebViewAssembly.self) { r in
            WebViewAssembly(
                authConfigurationProvider: r.resolve(UnsplashAuthConfigurationProvider.self)!
            )
        }

        container.register(AuthAssembly.self) { r in
            AuthAssembly(
                userSession: r.resolve(UserSessionProtocol.self)!,
                oAuth2Service: r.resolve(OAuth2ServiceProtocol.self)!
            )
        }

        container.register(ProfileAssembly.self) { r in
            ProfileAssembly(
                profileImageURLService: r.resolve(ProfileImageURLServiceProtocol.self)!,
                profileService: r.resolve(ProfileServiceProtocol.self)!,
                userSession: r.resolve(UserSessionProtocol.self)!,
                webViewCleaner: r.resolve(WebViewCookieDataCleanerProtocol.self)!,
                favoriteManager: r.resolve(FavoriteManaging.self)!,
                imageListViewModelFactory: r.resolve(ImageListViewModelFactoryProtocol.self)!,
                imageLoader: r.resolve(CachedImageLoaderProtocol.self)!
            )
        }

        container.register(ImageListAssembly.self) { r in
            ImageListAssembly(
                imageListViewModelFactory: r.resolve(ImageListViewModelFactoryProtocol.self)!
            )
        }

        container.register(DetailImageAssembly.self) { r in
            DetailImageAssembly(
                imageLoader: r.resolve(CachedImageLoaderProtocol.self)!
            )
        }
    }
}
