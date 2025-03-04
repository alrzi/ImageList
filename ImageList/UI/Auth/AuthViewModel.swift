//
//  AuthViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation

@MainActor
protocol AuthViewModelProtocol: ObservableObject {
    var state: ViewModelState<()> { get }
    
    func onAppear()
    func onNext()
    func onRetry()
}

final class AuthViewModel: AuthViewModelProtocol {
    private let oAuth2TokenStorage: any OAuth2TokenStorageProtocol
    private let oAuth2Service: OAuth2ServiceProtocol
    private let code: String?
    
    private let next: (AuthViewOutput) -> Void
    
    @Published private(set) var state: ViewModelState<()> = .loaded(())
        
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
        Task {
            await fetchTokenIfNeeded()
        }
    }
    
    func onNext() {
        next(.onAuthenticate)
    }
    
    func onRetry() {
        Task {
            await fetchTokenIfNeeded()
        }
    }
}

// MARK: - Private

private extension AuthViewModel {
    func fetchTokenIfNeeded() async {
        guard let code else {
            return
        }
        
        guard !state.isLoading else {
            return
        }
        
        state = .loading
       
        do {
            let token = try await oAuth2Service.fetchOAuthToken(withCode: code)
            
            await oAuth2TokenStorage.setToken(token)
            
            state = .loaded(())
            
            next(.onAuthenticated(token: token))
        }
        catch {
            state = .error
            debugPrint(error)
        }
    }
}
