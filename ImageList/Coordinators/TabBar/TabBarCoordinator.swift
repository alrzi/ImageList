//
//  TabBarCoordinator.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import UIKit

struct TabBarCoordinator: Coordinator {
    private let profileAssembly: ProfileAssembly
    private let imageListAssembly: ImageListAssembly
    private let detailImageAssembly: DetailImageAssembly
    
    private let window: UIWindow
    private let imageListNavigationController: UINavigationController
    private let profileNavigationController: UINavigationController
    
    private let onComplete: () -> Void
    
    init(
        profileAssembly: ProfileAssembly,
        imageListAssembly: ImageListAssembly,
        detailImageAssembly: DetailImageAssembly,
        window: UIWindow,
        imageListNavigationController: UINavigationController,
        profileNavigationController: UINavigationController,
        onComplete: @escaping () -> Void
    ) {
        self.profileAssembly = profileAssembly
        self.imageListAssembly = imageListAssembly
        self.detailImageAssembly = detailImageAssembly
        self.window = window
        self.imageListNavigationController = imageListNavigationController
        self.profileNavigationController = profileNavigationController
        self.onComplete = onComplete
    }
    
    func start() {
        let imagesListViewController = imageListAssembly.assemble(.init { handle(output: $0) })
        let profileViewController = profileAssembly.assemble(.init { handle(output: $0) })
        
        imageListNavigationController.setViewControllers([imagesListViewController], animated: false)
        profileNavigationController.setViewControllers([profileViewController], animated: false)
        
        let tabBarController = TabBarController(
            imagesListNavigationController: imageListNavigationController,
            profileViewController: profileNavigationController
        )
        
        window.rootViewController = tabBarController
    }
}

// MARK: - Private

private extension TabBarCoordinator {
    func showDetailImage(for url: URL, presentationController: UINavigationController) {
        let detailImageViewController = detailImageAssembly.assemble(.init(input: .init(url: url)))
        detailImageViewController.modalPresentationStyle = .overFullScreen
        detailImageViewController.modalTransitionStyle = .crossDissolve
        
        presentationController.present(detailImageViewController, animated: true)
    }
}

// MARK: - Handlers

private extension TabBarCoordinator {
    func handle(output: ImageListOutput) {
        switch output {
        case .onImageTap(let url): showDetailImage(for: url, presentationController: imageListNavigationController)
        case .onLikeRemoved: break
        }
    }
    
    func handle(output: ProfileOutput) {
        switch output {
        case .onLogOut: onComplete()
        case .onImageTap(let url): showDetailImage(for: url, presentationController: profileNavigationController)
        }
    }
}
