//
//  CachedImageLoaderProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 28.03.2026.
//

import Foundation

public protocol CachedImageLoaderProtocol: Sendable {
    func loadImage(from url: URL) async throws -> Data
    func cancelLoad(for url: URL) async
    func clearCache() async
}
