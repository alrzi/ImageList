//
//  AuthViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation

@MainActor
protocol AuthViewModelProtocol: ObservableObject {
    var state: AuthViewState { get }
    
    func onAppear()
    func onNext()
}

final class AuthViewModel: AuthViewModelProtocol {
    private let oAuth2Service: OAuth2ServiceProtocol
    private let code: String?
    
    private let next: (AuthViewOutput) -> Void
    
    @Published private(set) var state: AuthViewState = .idle
        
    init(
        oAuth2Service: OAuth2ServiceProtocol,
        code: String?,
        next: @escaping (AuthViewOutput) -> Void
    ) {
        self.oAuth2Service = oAuth2Service
        self.code = code
        self.next = next
        
        guard let code else {
            return
        }
                
        Task {
            do {
                state = .loading
                
                let token = try await oAuth2Service.fetchOAuthToken(withCode: code)
                
                next(.authenticated(token: token))
            }
            catch {
                state = .idle
            }
        }
    }
    
    func onAppear() { }
    
    func onNext() {
        next(.authenticate)
    }
}
