//
//  FileManager+CacheDirectory.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 28.03.2026.
//

import Foundation

extension FileManager {
    static func cacheDirectory(name: String) -> String {
        let cachesDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        return cachesDirectory
            .appendingPathComponent(name, isDirectory: true)
            .path
    }
}
