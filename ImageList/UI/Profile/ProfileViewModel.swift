//
//  ProfileViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import Foundation

@MainActor
protocol ProfileViewModelProtocol: ObservableObject {
    var state: ViewModelState<ProfileModel> { get }
    var logOutConfirmationError: ErrorInfo? { get }
    var isLogOutConfirmationErrorPresented: Bool { get set }
       
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
        
    @Published private(set) var state: ViewModelState<ProfileModel> = .idle
    @Published private(set) var logOutConfirmationError: ErrorInfo?
    @Published var isLogOutConfirmationErrorPresented = false
    
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
        
        Task {
            await updateProfile()
        }
    }
    
    func onRetry() {
        Task {
            await updateProfile()
        }
    }
    
    func onLogOut() {
        logOutConfirmationError = .profileLogOutConfirmationError { [weak self] in self?.onConfirmLogOut() }
        isLogOutConfirmationErrorPresented = true
    }
    
    func onConfirmLogOut() {
        Task.detached(priority: .background) { [weak self] in
            await self?.cleanCookie()
        }
    }
}

// MARK: - Private

private extension ProfileViewModel {
    func updateProfile() async {
        guard !state.isLoading else {
            return
        }
        
        state = .loading
        
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
            debugPrint(error)
        }
    }
    
    func cleanCookie() async {
        await webViewCleaner.clean(for: "unsplash.com")
        await oAuth2TokenStorage.cleanToken()
        
        eventsHandler(.onLogOut)
    }
}

private extension ErrorInfo {
    static func profileLogOutConfirmationError(onConfirm: @escaping () -> Void) -> Self {
        .init(
            message: "Уверены что хотите выйти?",
            cancelButtonText: "Нет",
            confirmationButtonText: "Да",
            onConfirm: onConfirm
        )
    }
}
