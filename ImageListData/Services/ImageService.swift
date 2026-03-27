//
//  ImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation
import ImageListDomain
internal import NetworkServiceDomain

struct ImageService: ImageServiceProtocol {
    let networkService: NetworkClientProtocol
    let imageDataCache: any CacheProtocol<String, Data>
    
    func fetchImage(url: URL) async throws -> Data {
        if let data = await imageDataCache.getValue(for: url.path()) {
            return data
        }
        
        let request = URLRequestWrapper(request: URLRequest(url: url), method: .get)
        let data = try await networkService.perform(request)
        
        await imageDataCache.setValue(data, for: url.path())
        
        return data
    }
}
