//
//  SceneDelegate.swift
//  ImageList
//
//  Created by Александр Зиновьев on 25.12.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        // servises
               
        let session = URLSession.shared
        let keychain = KeychainService()
        let networkService = NetworkClient(session: session)
        let oAuth2Service = OAuth2Service(networkService: networkService)
        let oAuth2TokenStorage = OAuth2TokenStorage(keychain: keychain)
        let profileImageURLService = ProfileImageURLService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage)
        let profileService = ProfileService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage)
        let webViewCleaner = WebViewCookieDataCleaner()
        let imageService = ImageService(networkService: networkService)
        let likeService = LikeService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage)
        let photosListService = PhotosListService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage)
        let imageListManager = ImageListManager(photosListService: photosListService, imageService: imageService, likeService: likeService)
        let favoritePhotosService = FavoritePhotosListService(networkService: networkService, profileService: profileService, oAuth2TokenStorage: oAuth2TokenStorage)
        let favoriteImageListManager = ImageListManager(photosListService: favoritePhotosService, imageService: imageService, likeService: likeService)
        
        // assemblies
        
        let webViewAssembly = WebViewAssembly()
        let authAssembly = AuthAssembly(oAuth2TokenStorage: oAuth2TokenStorage, oAuth2Service: oAuth2Service)
        
        let profileAssembly = ProfileAssembly(
            favoriteImageListManager: favoriteImageListManager,
            profileImageURLService: profileImageURLService,
            profileService: profileService,
            oAuth2TokenStorage: oAuth2TokenStorage,
            webViewCleaner: webViewCleaner,
            imageService: imageService
        )
        
        let imageListAssembly = ImageListAssembly(imageListManager: imageListManager)
        let detailImageAssembly = DetailImageAssembly()
        
        // coordinator
        
        let window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        navigationController.modalTransitionStyle = .coverVertical
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController.navigationBar.standardAppearance = appearance
        
        let coordinator = LoginCoordinator(
            oAuth2TokenStorage: oAuth2TokenStorage,
            webViewAssembly: webViewAssembly,
            authAssembly: authAssembly,
            profileAssembly: profileAssembly,
            imageListAssembly: imageListAssembly,
            detailImageAssembly: detailImageAssembly,
            window: window,
            navigationController: navigationController
        )
        
        coordinator.start()
                
        window.rootViewController = window.rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

@MainActor
protocol Coordinator {
    func start()
}

struct LoginCoordinator: Coordinator {
    private let oAuth2TokenStorage: any OAuth2TokenStorageProtocol
    
    private let webViewAssembly: WebViewAssembly
    private let authAssembly: AuthAssembly
    private let profileAssembly: ProfileAssembly
    private let imageListAssembly: ImageListAssembly
    private let detailImageAssembly: DetailImageAssembly
    
    private let window: UIWindow
    private let navigationController: UINavigationController

    init(
        oAuth2TokenStorage: some OAuth2TokenStorageProtocol,
        webViewAssembly: WebViewAssembly,
        authAssembly: AuthAssembly,
        profileAssembly: ProfileAssembly,
        imageListAssembly: ImageListAssembly,
        detailImageAssembly: DetailImageAssembly,
        window: UIWindow,
        navigationController: UINavigationController
    ) {
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.webViewAssembly = webViewAssembly
        self.authAssembly = authAssembly
        self.profileAssembly = profileAssembly
        self.imageListAssembly = imageListAssembly
        self.detailImageAssembly = detailImageAssembly
        self.window = window
        self.navigationController = navigationController
    }
   
    func start() {
        Task {
            if (try? await oAuth2TokenStorage.token) != nil {
                showHome()
            }
            else {
                window.rootViewController = navigationController
                
                showAuthView()
            }
        }
    }
}

// MARK: - Private

private extension LoginCoordinator {
    func showAuthView(code: String? = nil) {
        let viewController = authAssembly.assemble(.init(input: .init(code: code)) { handle(output: $0) })
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showWebView() {
        let viewController = webViewAssembly.assemble(.init { handle(output: $0) })
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHome() {
        let imagesListViewController = imageListAssembly.assemble(.init { handle(output: $0) })
        let profileViewController = profileAssembly.assemble(.init { handle(output: $0) })
        navigationController.setViewControllers([imagesListViewController], animated: false)
        
        let viewController = TabBarController(
            imagesListNavigationController: navigationController,
            profileViewController: profileViewController
        )
                
        window.rootViewController = viewController
    }
    
    func showDetailImage(for url: URL) {
        let detailImageViewController = detailImageAssembly.assemble(.init(input: .init(url: url)))
        detailImageViewController.modalPresentationStyle = .overFullScreen
        detailImageViewController.modalTransitionStyle = .crossDissolve
        
        navigationController.present(detailImageViewController, animated: true)
    }
}

// MARK: - Handlers

private extension LoginCoordinator {
    func handle(output: AuthViewOutput) {
        switch output {
        case .onAuthenticated: showHome()
        case .onAuthenticate: showWebView()
        }
    }
    
    func handle(output: WebViewOutput) {
        showAuthView(code: output.code)
    }
    
    func handle(output: ImageListOutput) {
        switch output {
        case .onImageTap(let url): showDetailImage(for: url)
        }
    }
    
    func handle(output: ProfileOutput) {
        switch output {
        case .onLogOut: start()
        }
    }
}
