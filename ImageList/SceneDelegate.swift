//
//  SceneDelegate.swift
//  ImageList
//
//  Created by Александр Зиновьев on 25.12.2022.
//

import ImageListData
import ImageListDomain
import NetworkServiceDomain
import Swinject
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: Coordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        // DI container
        let assembler = Assembler()
        #if DEBUG
            assembler.apply(
                assemblies: [
                    ImageListDataAssembly(),
                    ImageListDomainAssembly(),
                    ServicesAssembly(),
                    FactoriesAssembly(),
                    ModulesAssembly(),
                    DebugServicesAssembly(),
                ]
            )
        #else
            assembler.apply(
                assemblies: [
                    ImageListDataAssembly(),
                    ImageListDomainAssembly(),
                    ServicesAssembly(),
                    FactoriesAssembly(),
                    ModulesAssembly(),
                ]
            )
        #endif

        let resolver = assembler.resolver

        // coordinator
        let window = UIWindow(windowScene: windowScene)

        #if DEBUG
            coordinator = TabBarCoordinator(
                profileAssembly: resolver.resolve(ProfileAssembly.self)!,
                imageListAssembly: resolver.resolve(ImageListAssembly.self)!,
                detailImageAssembly: resolver.resolve(DetailImageAssembly.self)!,
                window: window,
                imageListNavigationController: .createController(isNavBarHidden: true),
                profileNavigationController: .createController(isNavBarHidden: true),
                onComplete: {}
            )
        #else
            coordinator = LoginCoordinator(
                userSession: resolver.resolve(UserSessionProtocol.self)!,
                webViewAssembly: resolver.resolve(WebViewAssembly.self)!,
                authAssembly: resolver.resolve(AuthAssembly.self)!,
                profileAssembly: resolver.resolve(ProfileAssembly.self)!,
                imageListAssembly: resolver.resolve(ImageListAssembly.self)!,
                detailImageAssembly: resolver.resolve(DetailImageAssembly.self)!,
                window: window,
                navigationController: .createController(isNavBarHidden: false)
            )
        #endif

        coordinator?.start()

        window.rootViewController = window.rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see
        // `application:didDiscardSceneSessions` instead).
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
