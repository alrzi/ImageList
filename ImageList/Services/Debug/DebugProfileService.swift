//
//  DebugProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import ImageListDomain

#if DEBUG
    struct DebugProfileService: ProfileServiceProtocol {
        func fetchProfile() async throws -> Profile {
            Profile(
                username: "username",
                firstName: "firstName",
                lastName: "lastName",
                loginName: "@" + "username",
                totalLikes: 40,
                bio: ""
            )
        }
    }
#endif
