//
//  LoginCoordinator.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import UIKit

final class LoginCoordinator: Coordinator {
    private let oAuth2TokenStorage: any OAuth2TokenStorageProtocol
    
    private let webViewAssembly: WebViewAssembly
    private let authAssembly: AuthAssembly
    
    private var tabBarCoordinator: TabBarCoordinator?
    
    private let window: UIWindow
    private let navigationController: UINavigationController

    init(
        oAuth2TokenStorage: any OAuth2TokenStorageProtocol,
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
        self.window = window
        self.navigationController = navigationController
        
        tabBarCoordinator = TabBarCoordinator(
            profileAssembly: profileAssembly,
            imageListAssembly: imageListAssembly,
            detailImageAssembly: detailImageAssembly,
            window: window,
            imageListNavigationController: .createController(isNavBarHidden: true),
            profileNavigationController: .createController(isNavBarHidden: true),
            onComplete: { [weak self] in self?.start() }
        )
    }
    
    func start() {
        Task {
            do {
                _ = try await oAuth2TokenStorage.token
                
                showHome()
            }
            catch {
                
                showAuthView()
            }
        }
    }
}

// MARK: - Private

private extension LoginCoordinator {
    func showAuthView(code: String? = nil) {
        let viewController = authAssembly.assemble(.init(input: .init(code: code)) { [weak self] in self?.handle(output: $0) })
                
        navigationController.setViewControllers([viewController], animated: true)
        
        window.rootViewController = navigationController
    }
    
    func showWebView() {
        let viewController = webViewAssembly.assemble(.init { [weak self] in self?.handle(output: $0) })
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHome() {
        tabBarCoordinator?.start()
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
}
