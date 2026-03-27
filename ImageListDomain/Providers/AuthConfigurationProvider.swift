//
//  AuthConfigurationProvider.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 06.03.2025.
//

import Foundation

public protocol AuthConfigurationProviding: Sendable {
    var config: UnsplashAuthConfiguration { get }
}
