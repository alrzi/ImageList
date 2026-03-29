//
//  ImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

internal import NetworkServiceDomain
import Foundation
import ImageListDomain

struct ImageService: ImageServiceProtocol {
    let networkService: NetworkClientProtocol

    func fetchImage(url: URL) async throws -> Data {
        let request = URLRequestWrapper(request: URLRequest(url: url), method: .get)
        return try await networkService.perform(request)
    }
}
