//
//  AuthAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import SwiftUI
import Foundation

final class AuthAssembly {
    private let oAuth2Service: OAuth2ServiceProtocol
    
    init(oAuth2Service: OAuth2ServiceProtocol) {
        self.oAuth2Service = oAuth2Service
    }
    
    @MainActor
    func assemble(_ context: ViewContext<AuthViewInput, AuthViewOutput>) -> UIViewController {
        let viewModel = AuthViewModel(
            oAuth2Service: oAuth2Service,
            code: context.input.code,
            next: context.output
        )
        
        let view = AuthView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
