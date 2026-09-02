//
//  DebugProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import ImageListDomain

#if DEBUG
    struct DebugProfileService: ProfileImageURLServiceProtocol, ProfileServiceProtocol {
        // MARK: - Private properties

        private let photoStore: DebugPhotoStore

        // MARK: - Lifecycle

        init(photoStore: DebugPhotoStore) {
            self.photoStore = photoStore
        }

        // MARK: - Public methods

        func fetchProfile() async throws -> Profile {
            Profile(
                username: "debug.user",
                firstName: "Debug",
                lastName: "User",
                loginName: "@debug.user",
                totalLikes: await photoStore.totalLikes(),
                bio: "Локальный профиль для тестирования без сети"
            )
        }

        func fetchProfileImageUrl(username: String) async throws -> URL {
            URL(string: "debug://images/1")!
        }
    }
#endif
