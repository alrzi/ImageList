//
//  ImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation
internal import NetworkService
import ImageListDomain

struct ImageService: ImageServiceProtocol {
    private let networkService: NetworkServiceProtocol
      
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchProfileImage(url: URL) async throws -> Data {
        let request = URLRequestWrapper(request: URLRequest(url: url), method: .get)
        
        return try await networkService.fetchData(for: request)
    }
}
