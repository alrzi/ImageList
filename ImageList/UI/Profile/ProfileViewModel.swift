//
//  ProfileViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import Foundation

@MainActor
protocol ProfileViewModelProtocol: ObservableObject {
    var state: State<ProfileModel> { get }
    var profileLogOutConfirmationError: ProfileLogOutConfirmationError? { get set }
       
    func onAppear()
    func onRetry()
    func onLogOut()
    func onConfirmLogOut()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileImageURLService: any ProfileImageURLServiceProtocol
    private let profileService: any ProfileServiceProtocol
    private let oAuth2TokenStorage: any OAuth2TokenStorageProtocol
    private let webViewCleaner: any WebViewCookieDataCleanerProtocol
    private let profileImageService: any ProfileImageServiceProtocol
    
    private let eventsHandler: (ProfileOutput) -> Void
        
    @Published private(set) var state: State<ProfileModel> = .loading
    @Published var profileLogOutConfirmationError: ProfileLogOutConfirmationError?
    
    init(
        profileImageURLService: some ProfileImageURLServiceProtocol,
        profileService: some ProfileServiceProtocol,
        oAuth2TokenStorage: some OAuth2TokenStorageProtocol,
        webViewCleaner: some WebViewCookieDataCleanerProtocol,
        profileImageService: some ProfileImageServiceProtocol,
        eventsHandler: @escaping (ProfileOutput) -> Void
    ) {
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.webViewCleaner = webViewCleaner
        self.profileImageService = profileImageService
        self.eventsHandler = eventsHandler
    }
    
    func onAppear() {
        guard !state.isLoaded else {
            return
        }
        
        updateProfile()
    }
    
    func onRetry() {
        updateProfile()
    }
    
    func onLogOut() {
        profileLogOutConfirmationError = .init(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            cancelButtonText: "Нет",
            confirmationButtonText: "Да",
            onConfirm: { [weak self] in self?.onConfirmLogOut() }
        )
    }
    
    func onConfirmLogOut() {
        cleanCookie()
        oAuth2TokenStorage.setToken(nil)
        
        eventsHandler(.onLogOut)
    }
}

// MARK: - Private

private extension ProfileViewModel {
    func updateProfile() {
        Task { [profileService, profileImageURLService, profileImageService] in
            do {
                let profile = try await profileService.fetchProfile()
                
                state = .loaded(
                    .init(
                        name: profile.fullName,
                        email: profile.loginName,
                        greeting: profile.bio
                    )
                )
                
                let imageURL = try await profileImageURLService.fetchProfileImageUrl(username: profile.username)
                let imageData = try await profileImageService.fetchProfileImage(url: imageURL)
                
                state = .loaded(
                    .init(
                        name: profile.fullName,
                        email: profile.loginName,
                        greeting: profile.bio,
                        imageData: imageData
                    )
                )
            }
            catch {
                state = .error
            }
        }
    }
    
    func cleanCookie() {
        Task {
            await webViewCleaner.clean(for: "unsplash.com")
        }
    }
}
