//
//  CachedImageLoader.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 28.03.2026.
//

internal import NetworkServiceDomain
import Foundation
import HybridCache
import ImageListDomain

final actor CachedImageLoader: CachedImageLoaderProtocol {
    private let cache: HybridCacheStorage
    private let networkService: NetworkClientProtocol

    private var activeTasks: [URL: Task<Data, Error>] = [:]

    init(storage: FileStorageProtocol, networkService: NetworkClientProtocol) {
        let cacheDirectory = FileManager.cacheDirectory(name: "ImageCache")
        let disk = DiskCacheComponentImpl(storage: storage, cacheDirectory: cacheDirectory)
        let memory = NSCacheStrategy(costLimit: 100 * 1024 * 1024)
        
        self.cache = HybridCacheStorage(memoryStrategy: memory, disk: disk)
        self.networkService = networkService
    }

    func loadImage(from url: URL) async throws -> Data {
        let key = url.absoluteString

        if let cached = cache.fetch(key: key) {
            return cached
        }

        if let existingTask = activeTasks[url] {
            return try await existingTask.value
        }

        let task = Task<Data, Error> {
            defer {
                removeTask(for: url)
            }

            let request = URLRequestWrapper(request: URLRequest(url: url), method: .get)
            let data = try await networkService.perform(request)

            guard !data.isEmpty else {
                throw URLError(.zeroByteResource) 
            }

            cache.save(data, key: key)

            return data
        }

        activeTasks[url] = task
        return try await task.value
    }

    func cancelLoad(for url: URL) {
        activeTasks[url]?.cancel()
        activeTasks[url] = nil
    }

    func clearCache() async {
        cache.clear()
    }

    func removeTask(for url: URL) {
        activeTasks[url] = nil
    }
}
