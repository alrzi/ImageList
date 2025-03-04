//
//  ProfileAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import SwiftUI
import Foundation

final class ProfileAssembly {
    private let favoriteImageListManager: ImageListManaging
    private let profileImageURLService: ProfileImageURLServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private let webViewCleaner: WebViewCookieDataCleanerProtocol
    private let imageService: ImageServiceProtocol
    
    init(
        favoriteImageListManager: ImageListManaging,
        profileImageURLService: ProfileImageURLServiceProtocol,
        profileService: ProfileServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        webViewCleaner: WebViewCookieDataCleanerProtocol,
        imageService: ImageServiceProtocol
    ) {
        self.favoriteImageListManager = favoriteImageListManager
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.webViewCleaner = webViewCleaner
        self.imageService = imageService
    }
    
    @MainActor
    func assemble(_ context: ViewContext<(), ProfileOutput>) -> UIViewController {
        let viewModel = ProfileViewModel(
            profileImageURLService: profileImageURLService,
            profileService: profileService,
            oAuth2TokenStorage: oAuth2TokenStorage,
            webViewCleaner: webViewCleaner,
            imageService: imageService,
            favoriteImageListManager: favoriteImageListManager,
            eventsHandler: { context.output($0) }
        )
        
        let view = ProfileView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
