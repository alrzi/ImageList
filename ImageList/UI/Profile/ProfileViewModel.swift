//
//  ProfileViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import Foundation

@MainActor
protocol ProfileViewModelProtocol {
    func onViewDidLoad()
    func onLogOut()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileImageURLService: ProfileImageURLServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private let webViewCleaner: WebViewCookieDataCleanerProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    @Published private(set) var profileModel: ProfileModel?
    
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
        
        Task {
            do {
                let profile = try await profileService.fetchProfile()
                let imageURL = try await profileImageURLService.fetchProfileImageUrl(username: profile.username)
                let imageData = try await profileImageService.fetchProfileImage(url: imageURL)
                
                profileModel = .init(
                    portraitImageData: imageData,
                    name: profile.name,
                    email: profile.loginName,
                    greeting: profile.bio
                )
            }
            catch {
                
            }
        }
    }
    
    func onViewDidLoad() { }
    
    func onLogOut() {
        webViewCleaner.clean()
        oAuth2TokenStorage.setToken(nil)
    }
}
