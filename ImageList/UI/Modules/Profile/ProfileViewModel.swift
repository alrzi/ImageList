//
//  ProfileViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import Foundation
import ImageListDomain
import NetworkServiceDomain

@MainActor
protocol ProfileViewModelProtocol: ObservableObject {
    associatedtype ImageListModel: ImageListViewModelProtocol

    var state: ViewModelState<ProfileModel> { get }
    var logOutConfirmationError: ErrorInfo? { get }
    var accountAccuracyError: ErrorInfo? { get }

    var isLogOutConfirmationErrorPresented: Bool { get set }
    var isAccountAccuracyErrorPresented: Bool { get set }

    var imageListViewModel: ImageListModel { get }
    var imageLoader: CachedImageLoaderProtocol { get }

    func onAppear()
    func onRetry()
    func onLogOut()
    func onConfirmLogOut()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileImageURLService: any ProfileImageURLServiceProtocol
    private let profileService: any ProfileServiceProtocol
    private let userSession: any UserSessionProtocol
    private let webViewCleaner: any WebViewCookieDataCleanerProtocol
    private let favoriteManager: any FavoriteManaging

    private let eventsHandler: (ProfileOutput) -> Void

    @Published private(set) var state: ViewModelState<ProfileModel> = .idle
    @Published private(set) var logOutConfirmationError: ErrorInfo?
    @Published private(set) var accountAccuracyError: ErrorInfo?

    @Published var isLogOutConfirmationErrorPresented = false
    @Published var isAccountAccuracyErrorPresented = false

    let imageListViewModel: ImageListViewModel
    let imageLoader: CachedImageLoaderProtocol
    
    private var likesCountObservationTask: Task<Void, Never>?

    init(
        profileImageURLService: some ProfileImageURLServiceProtocol,
        profileService: some ProfileServiceProtocol,
        userSession: some UserSessionProtocol,
        webViewCleaner: some WebViewCookieDataCleanerProtocol,
        favoriteManager: some FavoriteManaging,
        imageListViewModelFactory: ImageListViewModelFactoryProtocol,
        imageLoader: CachedImageLoaderProtocol,
        eventsHandler: @escaping (ProfileOutput) -> Void
    ) {
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.userSession = userSession
        self.webViewCleaner = webViewCleaner
        self.favoriteManager = favoriteManager
        self.imageLoader = imageLoader
        self.eventsHandler = eventsHandler

        imageListViewModel = imageListViewModelFactory.makeImageListViewModel(
            imageListType: .onlyFavorite,
            eventsHandler: { output in
                switch output {
                case let .onImageTap(url): eventsHandler(.onImageTap(url))
                }
            }
        )

        $logOutConfirmationError
            .map { $0 != nil }
            .assign(to: &$isLogOutConfirmationErrorPresented)

        $accountAccuracyError
            .map { $0 != nil }
            .assign(to: &$isAccountAccuracyErrorPresented)

        Task {
            await updateProfile()
        }

        likesCountObservationTask = Task { [weak self, favoriteManager] in
            guard let self else {
                return
            }

            for await likesCount in favoriteManager.totalLikesCount {
                await self.updateLikesCountInState(likesCount)
            }
        }
    }

    func onAppear() { }

    func onRetry() {
        Task {
            await updateProfile()
        }
    }

    func onLogOut() {
        logOutConfirmationError = .profileLogOutConfirmationError { [weak self] in self?.onConfirmLogOut() }
    }

    func onConfirmLogOut() {
        Task.detached(priority: .background) { [weak self] in
            await self?.cleanCookie()
        }
    }

    deinit {
        likesCountObservationTask?.cancel()
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

            state = .loaded(profile.toProfileModel())

            await updateImage(for: profile)
        }
        catch {
            state = .error
            debugPrint(error)
        }
    }

    func cleanCookie() async {
        await webViewCleaner.clean(for: "unsplash.com")
        await userSession.logout()

        eventsHandler(.onLogOut)
    }

    func updateImage(for profile: Profile) async {
        do {
            let imageURL = try await profileImageURLService.fetchProfileImageUrl(username: profile.username)

            state = .loaded(profile.toProfileModel(with: imageURL))
        }
        catch {
            debugPrint(error)
        }
    }

    func updateLikesCountInState(_ count: Int?) async {
        guard case let .loaded(model) = state, let count else {
            return
        }

        state = .loaded(model.with(likesCount: count))
    }
}

private extension ErrorInfo {
    static var accountAccuracyError: Self {
        .init(
            message: "Мы проверим что случилось, отдохните чуть-чуть и попробуйте еще раз",
            cancelButtonText: "",
            confirmationButtonText: "Ок",
            onConfirm: {}
        )
    }

    static func profileLogOutConfirmationError(onConfirm: @escaping () -> Void) -> Self {
        .init(
            message: "Уверены что хотите выйти?",
            cancelButtonText: "Нет",
            confirmationButtonText: "Да",
            onConfirm: onConfirm
        )
    }
}

private extension Profile {
    func toProfileModel() -> ProfileModel {
        .init(
            name: fullName,
            email: loginName,
            greeting: bio,
            totalLikes: totalLikes
        )
    }

    func toProfileModel(with avatarURL: URL) -> ProfileModel {
        .init(
            name: fullName,
            email: loginName,
            greeting: bio,
            totalLikes: totalLikes,
            avatarURL: avatarURL
        )
    }
}

private extension ProfileModel {
    func withLikesCountDecreasedAtOne() -> ProfileModel {
        .init(
            name: name,
            email: email,
            greeting: greeting,
            totalLikes: totalLikes - 1,
            avatarURL: avatarURL
        )
    }

    func with(likesCount: Int) -> ProfileModel {
        .init(
            name: name,
            email: email,
            greeting: greeting,
            totalLikes: likesCount,
            avatarURL: avatarURL
        )
    }
}
