//
//  AuthAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import SwiftUI
import Foundation
import ImageListDomain
import NetworkServiceDomain

final class AuthAssembly {
    private let userSession: UserSessionProtocol
    private let oAuth2Service: OAuth2ServiceProtocol
    
    init(
        userSession: UserSessionProtocol,
        oAuth2Service: OAuth2ServiceProtocol
    ) {
        self.userSession = userSession
        self.oAuth2Service = oAuth2Service
    }
    
    @MainActor
    func assemble(_ context: ViewContext<AuthViewInput, AuthViewOutput>) -> UIViewController {
        let viewModel = AuthViewModel(
            userSession: userSession,
            oAuth2Service: oAuth2Service,
            code: context.input.code,
            next: context.output
        )
        
        let view = AuthView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
