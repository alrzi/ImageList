//
//  AuthAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import SwiftUI
import Foundation

final class AuthAssembly {
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private let oAuth2Service: OAuth2ServiceProtocol
    
    init(
        oAuth2TokenStorage: OAuth2TokenStorageProtocol,
        oAuth2Service: OAuth2ServiceProtocol
    ) {
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.oAuth2Service = oAuth2Service
    }
    
    @MainActor
    func assemble(_ context: ViewContext<AuthViewInput, AuthViewOutput>) -> UIViewController {
        let viewModel = AuthViewModel(
            oAuth2TokenStorage: oAuth2TokenStorage,
            oAuth2Service: oAuth2Service,
            code: context.input.code,
            next: context.output
        )
        
        let view = AuthView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
