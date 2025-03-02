//
//  Photos.swift
//  ImageList
//
//  Created by Александр Зиновьев on 18.02.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date
    let urls: Urls
    var isLiked: Bool
    
    var imageURL: URL {
        get throws {
            guard let url = URL(string: urls.small) else {
                throw Errors.badURL
            }
            
            return url
        }
    }
}

extension Photo {
    struct Urls: Decodable {
        let full: String
        let thumb: String
        let regular: String
        let small: String
    }
}

private enum Errors: Error {
    case badURL
}
