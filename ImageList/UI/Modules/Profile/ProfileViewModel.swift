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

    var imageListViewModel: ImageListModel? { get }
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
    private let imageService: any ImageServiceProtocol

    private let eventsHandler: (ProfileOutput) -> Void

    @Published private(set) var state: ViewModelState<ProfileModel> = .idle
    @Published private(set) var logOutConfirmationError: ErrorInfo?
    @Published private(set) var accountAccuracyError: ErrorInfo?

    @Published var isLogOutConfirmationErrorPresented = false
    @Published var isAccountAccuracyErrorPresented = false

    private(set) var imageListViewModel: ImageListViewModel?
    let imageLoader: CachedImageLoaderProtocol

    init(
        profileImageURLService: some ProfileImageURLServiceProtocol,
        profileService: some ProfileServiceProtocol,
        userSession: some UserSessionProtocol,
        webViewCleaner: some WebViewCookieDataCleanerProtocol,
        imageService: some ImageServiceProtocol,
        favoriteImageListManager: ImageListManaging,
        factory: ImageListCellViewModelFactory,
        imageLoader: CachedImageLoaderProtocol,
        eventsHandler: @escaping (ProfileOutput) -> Void
    ) {
        self.profileImageURLService = profileImageURLService
        self.profileService = profileService
        self.userSession = userSession
        self.webViewCleaner = webViewCleaner
        self.imageService = imageService
        self.imageLoader = imageLoader
        self.eventsHandler = eventsHandler

        $logOutConfirmationError
            .map { $0 != nil }
            .assign(to: &$isLogOutConfirmationErrorPresented)

        $accountAccuracyError
            .map { $0 != nil }
            .assign(to: &$isAccountAccuracyErrorPresented)

        imageListViewModel = ImageListViewModel(
            imageListManager: favoriteImageListManager,
            imageListType: .onlyFavorite,
            factory: factory,
            eventsHandler: { [weak self] in self?.handle(output: $0) }
        )

        Task {
            await updateProfile()
        }
    }

    func onAppear() {
        Task {
            await updateLikesCount()
        }
    }

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

    func updateLikesCount() async {
        guard case let .loaded(model) = state else {
            return
        }

        do {
            let profile = try await profileService.fetchProfile()

            if profile.totalLikes != model.totalLikes {
                state = .loaded(model.with(likesCount: profile.totalLikes))
            }
        }
        catch {
            accountAccuracyError = .accountAccuracyError
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

    func handle(output: ImageListOutput) {
        switch output {
        case let .onImageTap(uRL):
            eventsHandler(.onImageTap(uRL))

        case .onLikeRemoved:
            guard case let .loaded(info) = state else {
                return
            }

            let newState = info.withLikesCountDecreasedAtOne()

            state = .loaded(newState)
        }
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
