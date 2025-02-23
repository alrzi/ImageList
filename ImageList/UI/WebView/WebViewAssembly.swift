//
//  WebViewAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation
import UIKit

final class WebViewAssembly {
    private let authHelper: any AuthHelperProtocol
    
    init(authHelper: any AuthHelperProtocol) {
        self.authHelper = authHelper
    }
       
    @MainActor
    func assemble(_ context: ViewContext<(), WebViewOutput>) -> UIViewController {
        let viewModel = WebViewModel(
            authHelper: authHelper,
            onComplete: context.output
        )
        
        let viewController = WebViewController(viewModel: viewModel)
        return viewController
    }
}
