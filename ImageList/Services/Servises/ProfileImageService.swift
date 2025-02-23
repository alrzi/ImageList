//
//  ProfileImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation

protocol ProfileImageServiceProtocol {
    func fetchProfileImage(url: URL) async throws -> Data
}

final class ProfileImageService: ProfileImageServiceProtocol {
    private let networkService: NetworkClientProtocol
    
    private var imageDataCash = NSCache<NSString, NSData>()
    
    init(networkService: NetworkClientProtocol) {
        self.networkService = networkService
    }
    
    func fetchProfileImage(url: URL) async throws -> Data {
        let key = url.absoluteString as NSString
        
        if let data = imageDataCash.object(forKey: key) {
            return data as Data
        }
        
        let request = URLRequest(url: url)
        
        let data = try await networkService.fetchData(for: request)
        
        let value = data as NSData
        
        imageDataCash.setObject(value, forKey: key)
        
        return data
    }
}
