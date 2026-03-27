//
//  Photos.swift
//  ImageList
//
//  Created by Александр Зиновьев on 18.02.2023.
//

import Foundation

public struct Photo: Sendable {
    public let id: String
    public let size: CGSize
    public let createdAt: Date
    public let urls: Urls
    public var isLiked: Bool
    
    public var imageURL: URL {
        get throws {
            guard let url = URL(string: urls.small) else {
                throw Errors.badURL
            }
            
            return url
        }
    }
    
    public init(
        id: String,
        size: CGSize,
        createdAt: Date,
        urls: Urls,
        isLiked: Bool
    ) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.urls = urls
        self.isLiked = isLiked
    }
}

public extension Photo {
    struct Urls: Sendable {
        public let full: String
        public let thumb: String
        public let regular: String
        public let small: String
        
        public init(
            full: String,
            thumb: String,
            regular: String,
            small: String
        ) {
            self.full = full
            self.thumb = thumb
            self.regular = regular
            self.small = small
        }
    }
}

private enum Errors: Error {
    case badURL
}
