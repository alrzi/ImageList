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
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // servises
        
        let session = URLSession.shared
        let networkService = NetworkClient(session: session)
        let authHelper = AuthHelper(requestBuilder: RequestBuilder())
        let oAuth2Service = OAuth2Service(networkService: networkService)
        let oAuth2TokenStorage = OAuth2TokenStorage()
        let profileImageURLService = ProfileImageURLService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage)
        let profileService = ProfileService(networkService: networkService, oAuth2TokenStorage: oAuth2TokenStorage)
        let webViewCleaner = WebViewCookieDataCleaner()
        let profileImageService = ProfileImageService(networkService: networkService)
        
        // assemblies
        
        let webViewAssembly = WebViewAssembly(authHelper: authHelper)
        let authAssembly = AuthAssembly(oAuth2Service: oAuth2Service)
        
        let profileAssembly = ProfileAssembly(
            profileImageURLService: profileImageURLService,
            profileService: profileService,
            oAuth2TokenStorage: oAuth2TokenStorage,
            webViewCleaner: webViewCleaner,
            profileImageService: profileImageService
        )
        
        let navigationController = UINavigationController()
        
        let coordinator = LoginCoordinator(
            webViewAssembly: webViewAssembly,
            authAssembly: authAssembly,
            profileAssembly: profileAssembly,
            navigationController: navigationController
        )
        
        coordinator.start()
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
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
    private let webViewAssembly: WebViewAssembly
    private let authAssembly: AuthAssembly
    private let profileAssembly: ProfileAssembly
    
    private let navigationController: UINavigationController

    init(
        webViewAssembly: WebViewAssembly,
        authAssembly: AuthAssembly,
        profileAssembly: ProfileAssembly,
        navigationController: UINavigationController
    ) {
        self.webViewAssembly = webViewAssembly
        self.authAssembly = authAssembly
        self.profileAssembly = profileAssembly
        self.navigationController = navigationController
    }
   
    func start() {
        showAuthView()
    }
}

private extension LoginCoordinator {
    func showAuthView(code: String? = nil) {
        let viewController = authAssembly
            .assemble(
                .init(input: .init(code: code)) { output in
                    Task { @MainActor in
                        switch output {
                        case .authenticated:
                            showHome()
                        
                        case .authenticate:
                            showWebView()
                        }
                    }
                }
            )
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showWebView() {
        let viewController = webViewAssembly
            .assemble(
                .init { output in
                    Task { @MainActor in
                        showAuthView(code: output.code)
                    }
                }
            )
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHome() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Wrong Configuration")
        }
        
        let viewController = TabBarController(
            profileViewController: profileAssembly.assemble(.init())
        )
        
        window.rootViewController = viewController
    }
}
