//
//  FavoriteManager.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import AsyncExtensions

public final class FavoriteManager: FavoriteManaging {
    // MARK: - Private properties

    private let likeService: LikeServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let _totalLikesCount: CurrentValueAsyncSequence<Int?>
    private let initialLikesCountLoadTask: Task<Void, Never>

    // MARK: - Public properties

    public var totalLikesCount: CurrentValueAsyncSequenceReadOnly<Int?> { _totalLikesCount.readOnly() }

    // MARK: - Lifecycle

    public init(
        likeService: LikeServiceProtocol,
        profileService: ProfileServiceProtocol
    ) {
        self.likeService = likeService
        self.profileService = profileService
        self._totalLikesCount = CurrentValueAsyncSequence(nil)

        initialLikesCountLoadTask = Task { [profileService, _totalLikesCount] in
            do {
                let profile = try await profileService.fetchProfile()
                await _totalLikesCount.setValue(profile.totalLikes)
            } catch {
                debugPrint(error)
            }
        }
    }

    deinit {
        initialLikesCountLoadTask.cancel()
    }

    // MARK: - Public methods

    public func changeLike(photoId: String, isLiked: Bool) async throws -> Bool {
        await initialLikesCountLoadTask.value

        let result = try await likeService.changeLike(photoId: photoId, isLiked: isLiked)

        if result == isLiked {
            let currentCount = await _totalLikesCount.value ?? 0
            await _totalLikesCount.setValue(currentCount + (isLiked ? 1 : -1))
        }

        return result
    }
}
