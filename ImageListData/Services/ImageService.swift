//
//  ImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct ImageService: ImageServiceProtocol {
    private let networkService: NetworkServiceProtocol
      
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchImage(url: URL) async throws -> Data {
        let request = URLRequestWrapper(request: URLRequest(url: url), method: .get)
        
        return try await networkService.fetchData(for: request)
    }
}
