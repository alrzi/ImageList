//
//  API.PhotoResult.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

import Foundation

extension API {
    enum PhotoResult {
        struct PhotoResult: Decodable {
            let id: String
            let createdAt: Date
            let width, height: Int
            let likedByUser: Bool
            let urls: UrlsResult
            
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

        struct UrlsResult: Decodable {
            let full: String
            let thumb: String
            let regular: String
            let small: String
            
            func toURL() -> Photo.Urls {
                Photo.Urls(
                    full: full,
                    thumb: thumb,
                    regular: regular,
                    small: small
                )
            }
        }
    }
}
