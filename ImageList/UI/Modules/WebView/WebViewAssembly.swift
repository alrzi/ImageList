//
//  WebViewAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation
import UIKit

final class WebViewAssembly {
    private let authConfigurationProvider: UnsplashAuthConfigurationProvider

    init(authConfigurationProvider: UnsplashAuthConfigurationProvider) {
        self.authConfigurationProvider = authConfigurationProvider
    }

    @MainActor
    func assemble(_ context: ViewContext<Void, WebViewOutput>) -> UIViewController {
        let viewModel = WebViewModel(
            authConfigurationProvider: authConfigurationProvider,
            onComplete: context.output
        )

        return WebViewController(viewModel: viewModel)
    }
}
