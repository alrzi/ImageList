//
//  PhotosListCache.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 28.03.2026.
//

import Foundation
import HybridCache

final class PhotosListCache: PhotosListCacheProtocol {
    private let twoLevelCache: HybridCache
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(storage: FileStorageProtocol) {
        let cacheDirectory = FileManager.cacheDirectory(name: "PhotosListCache")
        let disk = DiskCacheComponentWithSizeLimit(
            storage: storage,
            cacheDirectory: cacheDirectory,
            sizeLimit: 200 * 1024 * 1024 // 200 MB для дискового кэша
        )
        let memory = LRUStrategy(costLimit: 1024 * 1024 * 1024)
        self.twoLevelCache = HybridCache(memoryStrategy: memory, disk: disk)
    }

    func getPhotos(page: Int) async throws -> [API.PhotoResult.PhotoResult]? {
        let key = "photos_page_\(page)"

        // Получаем сырые данные
        guard let data = await twoLevelCache.fetch(key: key) else {
            return nil
        }

        // Декодируем на слое выше
        do {
            return try decoder.decode([API.PhotoResult.PhotoResult].self, from: data)
        }
        catch {
            // API изменился, кэш устарел — очищаем
            debugPrint("Кэш фотографий устарел (API изменился), очищаем")
            await twoLevelCache.remove(key: key)
            return nil
        }
    }

    func setPhotos(_ photos: [API.PhotoResult.PhotoResult], page: Int) async throws {
        let key = "photos_page_\(page)"

        // Кодируем на слое выше
        let data = try encoder.encode(photos)

        // Сохраняем сырые данные
        await twoLevelCache.save(data, key: key)
    }

    func clearCache() async throws {
        await twoLevelCache.clear()
    }
}
