//
//  ServicesAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.03.2025.
//

import Foundation
import HybridCache
import ImageListData
import ImageListDomain
import NetworkServiceDomain
import Swinject

public final class ServicesAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(UnsplashAuthConfigurationProvider.self) { _ in
            UnsplashAuthConfigurationProvider()
        }
        .inObjectScope(.container)

        container.register(AuthConfigurationProviding.self) { r in
            r.resolve(UnsplashAuthConfigurationProvider.self)!
        }
        .inObjectScope(.container)

        container.register(WebViewCookieDataCleanerProtocol.self) { _ in
            WebViewCookieDataCleaner()
        }
        .inObjectScope(.container)
    }
}
