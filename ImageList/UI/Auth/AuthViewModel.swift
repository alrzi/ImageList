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
    private let oAuth2TokenStorage: any OAuth2TokenStorageProtocol
    private let oAuth2Service: OAuth2ServiceProtocol
    private let code: String?
    
    private let next: (AuthViewOutput) -> Void
    
    @Published private(set) var state: AuthViewState = .idle
        
    init(
        oAuth2TokenStorage: some OAuth2TokenStorageProtocol,
        oAuth2Service: some  OAuth2ServiceProtocol,
        code: String?,
        next: @escaping (AuthViewOutput) -> Void
    ) {
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.oAuth2Service = oAuth2Service
        self.code = code
        self.next = next
    }
    
    func onAppear() {
        fetchTokenIfNeeded()
    }
    
    func onNext() {
        next(.authenticate)
    }
}

// MARK: - Private

private extension AuthViewModel {
    func fetchTokenIfNeeded() {
        guard let code else {
            return
        }
                
        Task { [oAuth2Service] in
            do {
                state = .loading
                
                let token = try await oAuth2Service.fetchOAuthToken(withCode: code)
                
                oAuth2TokenStorage.setToken(token)
                
                next(.authenticated(token: token))
            }
            catch {
                state = .idle
            }
        }
    }
}
