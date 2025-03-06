//
//  SceneDelegate.swift
//  ImageList
//
//  Created by Александр Зиновьев on 25.12.2022.
//

import UIKit
import ImageListDomain
import ImageListData

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        // servises
        let authConfigProvider: UnsplashAuthConfigurationProvider = .init()
        let webViewCleaner = WebViewCookieDataCleaner()
        let secureStorage = ImageListDataContainer.secureStorage
        let oAuth2TokenStorage = ImageListDomainContainer.oAuth2TokenStorage(secureStorage: secureStorage)
        let imageService = ImageListDataContainer.imageService
        let oAuth2Service = ImageListDataContainer.oAuth2Service(authConfigurationProvider: authConfigProvider)
        let profileImageURLService = ImageListDataContainer.profileImageURLService(authConfigurationProvider: authConfigProvider, oAuth2TokenStorage: oAuth2TokenStorage)
        let profileService = ImageListDataContainer.profileService(authConfigurationProvider: authConfigProvider, oAuth2TokenStorage: oAuth2TokenStorage)
        let likeService = ImageListDataContainer.likeService(authConfigurationProvider: authConfigProvider, oAuth2TokenStorage: oAuth2TokenStorage)
        let photosListService = ImageListDataContainer.photosListService(authConfigurationProvider: authConfigProvider, oAuth2TokenStorage: oAuth2TokenStorage)
        let favoritePhotosService = ImageListDataContainer.favoritePhotosListService(authConfigurationProvider: authConfigProvider, oAuth2TokenStorage: oAuth2TokenStorage)
        
        let imageListManager = ImageListDomainContainer.imageListManager(
            photosListService: photosListService,
            imageService: imageService,
            likeService: likeService
        )
        let favoriteImageListManager = ImageListDomainContainer.imageListManager(
            photosListService: favoritePhotosService,
            imageService: imageService,
            likeService: likeService
        )
        
        // assemblies
        
        let webViewAssembly = WebViewAssembly(authConfigurationProvider: authConfigProvider)
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
        
        coordinator = LoginCoordinator(
            oAuth2TokenStorage: oAuth2TokenStorage,
            webViewAssembly: webViewAssembly,
            authAssembly: authAssembly,
            profileAssembly: profileAssembly,
            imageListAssembly: imageListAssembly,
            detailImageAssembly: detailImageAssembly,
            window: window,
            navigationController: .createController(isNavBarHidden: false)
        )
               
        coordinator?.start()
                
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
