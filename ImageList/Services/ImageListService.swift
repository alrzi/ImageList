//
//  ImageListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation

protocol ImageListServiceProtocol: Sendable {
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo]
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}

struct ImageListService: ImageListServiceProtocol {
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        decoder: JSONDecoder,
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.decoder = decoder
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func fetchPhotosNextPage(_ page: Int) async throws -> [Photo] {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.PhotosNextPageRequest(
            page: page,
            token: token
        )
        
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode([PhotoResult].self, from: data)
        
        return result.map { $0.toPhoto() }
    }
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        let token = try await oAuth2TokenStorage.token
        
        let request = API.ChangeLikeRequest(
            photoId: photoId,
            token: token,
            method: isLiked ? .post : .delete
        )
        
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode(LikeResult.self, from: data)
        
        return result.photo.likedByUser
    }
}

private struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date
    let width, height: Int
    let likedByUser: Bool
    let urls: UrlsResult
}

private struct UrlsResult: Decodable {
    let full: String
    let thumb: String
    let regular: String
    let small: String
}

private struct LikeResult: Decodable {
    let photo: Photos
}

private struct Photos: Decodable {
    let likedByUser: Bool
}

private extension PhotoResult {
    func toPhoto() -> Photo {
        Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: createdAt,
            urls: urls.toURL(),
            isLiked: likedByUser
        )
    }
}

private extension UrlsResult {
    func toURL() -> Photo.Urls {
        Photo.Urls(
            full: full,
            thumb: thumb,
            regular: regular,
            small: small
        )
    }
}
