//
//  LikeServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol LikeServiceProtocol: Sendable {
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}
