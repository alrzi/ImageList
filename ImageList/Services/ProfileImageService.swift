//
//  ProfileImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation

protocol ProfileImageServiceProtocol: Sendable {
    func fetchProfileImage(url: URL) async throws -> Data
}

struct ProfileImageService: ProfileImageServiceProtocol {
    private let networkService: NetworkClientProtocol
      
    init(networkService: NetworkClientProtocol) {
        self.networkService = networkService
    }
    
    func fetchProfileImage(url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        
        let data = try await networkService.fetchData(for: request)
                
        return data
    }
}
