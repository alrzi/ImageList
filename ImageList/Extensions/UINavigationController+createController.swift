//
//  UINavigationController+createController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation
import UIKit

extension UINavigationController {
    static func createController(isNavBarHidden: Bool) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(isNavBarHidden, animated: false)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance

        return navigationController
    }
}
