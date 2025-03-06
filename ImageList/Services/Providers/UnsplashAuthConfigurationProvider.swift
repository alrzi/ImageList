//
//  UnsplashAuthConfigurationProvider.swift
//  ImageList
//
//  Created by Александр Зиновьев on 06.03.2025.
//

import Foundation
import ImageListDomain

struct UnsplashAuthConfigurationProvider: AuthConfigurationProviding {
    let config: ImageListDomain.UnsplashAuthConfiguration = .standard
}

private extension UnsplashAuthConfiguration {
    static var standard: UnsplashAuthConfiguration {
        UnsplashAuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScopes,
            defaultBaseHost: DefaultBaseHost,
            oAuthHost: OAuthHost
        )
    }
}

// swiftlint:disable identifier_name
private let AccessKey = "SS4lXp7vzIwOgPt0F2sOiUW-jsD6--h2Red2jA82kbQ"
private let SecretKey = "0xgcQI41BRbflXzVQ8oIAmKQd--Dk-cYJ-TV44d5d3k"
private let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
private let AccessScopes: [UnsplashAuthConfiguration.AccessScope] = [.public, .readUser, .writeLikes]
private let DefaultBaseHost = "https://api.unsplash.com"
private let OAuthHost = "https://unsplash.com"
// swiftlint:enable identifier_name
