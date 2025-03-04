//
//  ImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation

protocol ImageServiceProtocol: Sendable {
    func fetchProfileImage(url: URL) async throws -> Data
}

struct ImageService: ImageServiceProtocol {
    private let networkService: NetworkClientProtocol
      
    init(networkService: NetworkClientProtocol) {
        self.networkService = networkService
    }
    
    func fetchProfileImage(url: URL) async throws -> Data {
        try await networkService.fetchData(for: URLRequest(url: url))
    }
}
