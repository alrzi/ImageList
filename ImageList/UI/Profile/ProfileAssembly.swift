//
//  ProfileAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import SwiftUI
import Foundation

final class ProfileAssembly {
    private let profileImageURLService: ProfileImageURLServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private let webViewCleaner: WebViewCookieDataCleanerProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    init(
        profileImageURLService: ProfileImageURLServiceProtocol,
        profileService: ProfileServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        webViewCleaner: WebViewCookieDataCleanerProtocol,
        profileImageService: ProfileImageServiceProtocol
    ) {
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.webViewCleaner = webViewCleaner
        self.profileImageService = profileImageService
    }
    
    @MainActor
    func assemble(_ context: ViewContext<(), ()>) -> UIViewController {
        let viewModel = ProfileViewModel(
            profileImageURLService: profileImageURLService,
            profileService: profileService,
            oAuth2TokenStorage: oAuth2TokenStorage,
            webViewCleaner: webViewCleaner,
            profileImageService: profileImageService
        )
        
        let viewController = ProfileViewController(viewModel: viewModel)
        return viewController
    }
}
