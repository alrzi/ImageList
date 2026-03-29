//
//  FavoriteManager.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import AsyncExtensions

public final class FavoriteManager: FavoriteManaging {
    private let likeService: LikeServiceProtocol
    private let profileService: ProfileServiceProtocol
    
    private let _totalLikesCount: CurrentValueAsyncSequence<Int?>
    public var totalLikesCount: CurrentValueAsyncSequenceReadOnly<Int?> { _totalLikesCount.readOnly() }
    
    public init(
        likeService: LikeServiceProtocol,
        profileService: ProfileServiceProtocol
    ) {
        self.likeService = likeService
        self.profileService = profileService
        self._totalLikesCount = CurrentValueAsyncSequence(nil)

        Task {
            try await loadLikesCount()
        }
    }
    
    public func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        let result = try await likeService.changeLike(photoId: photoId, isLiked: isLiked)
        
        if !result {
            let currentCount = await _totalLikesCount.value ?? 0
            await _totalLikesCount.setValue(currentCount + (isLiked ? 1 : -1))
        }
        
        return result
    }
    
    private func loadLikesCount() async throws -> Int {
        let profile = try await profileService.fetchProfile()
        await _totalLikesCount.setValue(profile.totalLikes)
        return profile.totalLikes
    }
}
