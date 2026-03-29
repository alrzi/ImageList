//
//  ProfileAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation
import ImageListDomain
import NetworkServiceDomain
import SwiftUI

final class ProfileAssembly {
    private let favoriteImageListManager: ImageListManaging
    private let profileImageURLService: ProfileImageURLServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let userSession: UserSessionProtocol
    private let webViewCleaner: WebViewCookieDataCleanerProtocol
    private let imageService: ImageServiceProtocol
    private let factory: ImageListCellViewModelFactory
    private let imageLoader: CachedImageLoaderProtocol

    init(
        favoriteImageListManager: ImageListManaging,
        profileImageURLService: ProfileImageURLServiceProtocol,
        profileService: ProfileServiceProtocol,
        userSession: UserSessionProtocol,
        webViewCleaner: WebViewCookieDataCleanerProtocol,
        imageService: ImageServiceProtocol,
        factory: ImageListCellViewModelFactory,
        imageLoader: CachedImageLoaderProtocol
    ) {
        self.favoriteImageListManager = favoriteImageListManager
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.userSession = userSession
        self.webViewCleaner = webViewCleaner
        self.imageService = imageService
        self.factory = factory
        self.imageLoader = imageLoader
    }

    @MainActor
    func assemble(_ context: ViewContext<Void, ProfileOutput>) -> UIViewController {
        let viewModel = ProfileViewModel(
            profileImageURLService: profileImageURLService,
            profileService: profileService,
            userSession: userSession,
            webViewCleaner: webViewCleaner,
            imageService: imageService,
            favoriteImageListManager: favoriteImageListManager,
            factory: factory,
            imageLoader: imageLoader,
            eventsHandler: { context.output($0) }
        )

        let view = ProfileView(viewModel: viewModel)

        return UIHostingController(rootView: view)
    }
}
