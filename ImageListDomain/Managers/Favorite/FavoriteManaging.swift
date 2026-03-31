//
//  FavoriteManaging.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import AsyncExtensions

public protocol FavoriteManaging: Sendable {
    var totalLikesCount: CurrentValueAsyncSequenceReadOnly<Int?> { get }
    
    func changeLike(photoId: String, isLiked: Bool) async throws -> Bool
}
