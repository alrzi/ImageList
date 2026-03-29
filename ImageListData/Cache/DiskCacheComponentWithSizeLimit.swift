//
//  DiskCacheComponentWithSizeLimit.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 28.03.2026.
//

import CommonCrypto
import Foundation
import HybridCache

/// Реализация дискового кэша с ограничением размера
public final class DiskCacheComponentWithSizeLimit: DiskCacheComponent {
    private let storage: FileStorageProtocol
    private let cacheDirectory: String
    private let sizeLimit: Int
    private let fileManager = FileManager.default

    public init(
        storage: FileStorageProtocol,
        cacheDirectory: String,
        sizeLimit: Int = 500 * 1024 * 1024 // 500 MB по умолчанию
    ) {
        self.storage = storage
        self.cacheDirectory = cacheDirectory
        self.sizeLimit = sizeLimit
    }

    public func load(key: String) -> Data? {
        try? createDirectoryIfNeeded()
        let path = filePath(for: key)
        return storage.data(atPath: path)
    }

    public func save(_ data: Data, key: String) {
        try? createDirectoryIfNeeded()
        let path = filePath(for: key)
        try? storage.write(data, to: path)

        // Проверяем и очищаем при превышении лимита
        try? cleanCacheIfNeeded()
    }

    public func remove(key: String) {
        let path = filePath(for: key)
        try? storage.removeItem(at: path)
    }

    public func clear() {
        guard let files = try? storage.contentsOfDirectory(at: cacheDirectory) else { return }
        for file in files {
            try? storage.removeItem(at: file.path)
        }
    }

    // MARK: - Private

    private func filePath(for key: String) -> String {
        let hashedKey = key.sha256Hash
        return (cacheDirectory as NSString).appendingPathComponent(hashedKey)
    }

    private func createDirectoryIfNeeded() throws {
        guard !storage.fileExists(atPath: cacheDirectory) else { return }
        try storage.createDirectory(at: cacheDirectory)
    }

    private func cleanCacheIfNeeded() throws {
        let currentSize = try calculateCacheSize()
        guard currentSize > sizeLimit else { return }

        // Получаем файлы с датами модификации
        let files = try getFilesWithDates()

        // Удаляем самые старые файлы пока не освободим место
        var freedSize = 0
        let targetFreeSize = currentSize - sizeLimit + (sizeLimit / 10) // Освобождаем 10% дополнительно

        for file in files.sorted(by: { $0.date < $1.date }) {
            guard freedSize < targetFreeSize else { break }

            let fileSize = try fileManager.attributesOfItem(atPath: file.path)[.size] as? Int ?? 0
            try? storage.removeItem(at: file.path)
            freedSize += fileSize
        }
    }

    private func calculateCacheSize() throws -> Int {
        let files = try storage.contentsOfDirectory(at: cacheDirectory)
        var totalSize = 0

        for file in files {
            let attributes = try fileManager.attributesOfItem(atPath: file.path)
            if let fileSize = attributes[.size] as? Int {
                totalSize += fileSize
            }
        }

        return totalSize
    }

    private func getFilesWithDates() throws -> [(path: String, date: Date)] {
        let files = try storage.contentsOfDirectory(at: cacheDirectory)
        var result: [(path: String, date: Date)] = []

        for file in files {
            let attributes = try? fileManager.attributesOfItem(atPath: file.path)
            if let modDate = attributes?[.modificationDate] as? Date {
                result.append((path: file.path, date: modDate))
            }
        }

        return result
    }
}

// MARK: - String Extension

private extension String {
    var sha256Hash: String {
        guard let data = self.data(using: .utf8) else { return self }

        var hash = [UInt8](repeating: 0, count: 32)
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
