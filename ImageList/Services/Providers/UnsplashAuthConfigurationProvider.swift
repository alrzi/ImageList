//
//  UnsplashAuthConfigurationProvider.swift
//  ImageList
//
//  Created by Александр Зиновьев on 06.03.2025.
//

import Foundation
import ImageListDomain

struct UnsplashAuthConfigurationProvider: AuthConfigurationProviding {
    let config: UnsplashAuthConfiguration = .standard
}

// MARK: - Configuration Keys

private enum ConfigKey: String {
    case accessKey = "UNSPLASH_ACCESS_KEY"
    case secretKey = "UNSPLASH_SECRET_KEY"
    case redirectURI = "UNSPLASH_REDIRECT_URI"
    case accessScopes = "UNSPLASH_ACCESS_SCOPES"
}

// MARK: - Private Extension

private extension UnsplashAuthConfiguration {
    static var standard: UnsplashAuthConfiguration {
        let config = UnsplashAuthConfiguration(
            accessKey: stringValue(for: .accessKey),
            secretKey: stringValue(for: .secretKey),
            redirectURI: stringValue(for: .redirectURI),
            accessScope: accessScopes,
            defaultBaseHost: "https://api.unsplash.com",
            oAuthHost: "https://unsplash.com"
        )
        
        #if DEBUG
        precondition(
            config.isValid,
            "❌ UnsplashAuthConfiguration: не заполнены поля: \(config.missingFields.joined(separator: ", "))"
        )
        #endif
        
        return config
    }

    private static var accessScopes: [UnsplashAuthConfiguration.AccessScope] {
        UnsplashAuthConfiguration.AccessScope.parse(from: stringValue(for: .accessScopes))
    }

    private static func stringValue(for key: ConfigKey) -> String {
        Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String ?? ""
    }
}
