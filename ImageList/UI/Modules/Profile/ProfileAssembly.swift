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
    private let profileImageURLService: ProfileImageURLServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let userSession: UserSessionProtocol
    private let webViewCleaner: WebViewCookieDataCleanerProtocol
    private let favoriteManager: FavoriteManaging
    private let imageListViewModelFactory: ImageListViewModelFactoryProtocol
    private let imageLoader: CachedImageLoaderProtocol

    init(
        profileImageURLService: ProfileImageURLServiceProtocol,
        profileService: ProfileServiceProtocol,
        userSession: UserSessionProtocol,
        webViewCleaner: WebViewCookieDataCleanerProtocol,
        favoriteManager: FavoriteManaging,
        imageListViewModelFactory: ImageListViewModelFactoryProtocol,
        imageLoader: CachedImageLoaderProtocol
    ) {
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.userSession = userSession
        self.webViewCleaner = webViewCleaner
        self.favoriteManager = favoriteManager
        self.imageListViewModelFactory = imageListViewModelFactory
        self.imageLoader = imageLoader
    }

    @MainActor
    func assemble(_ context: ViewContext<Void, ProfileOutput>) -> UIViewController {
        let viewModel = ProfileViewModel(
            profileImageURLService: profileImageURLService,
            profileService: profileService,
            userSession: userSession,
            webViewCleaner: webViewCleaner,
            favoriteManager: favoriteManager,
            imageListViewModelFactory: imageListViewModelFactory,
            imageLoader: imageLoader,
            eventsHandler: { context.output($0) }
        )

        let view = ProfileView(viewModel: viewModel)

        return UIHostingController(rootView: view)
    }
}
