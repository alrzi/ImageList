//
//  AuthViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation
import ImageListDomain
import NetworkServiceDomain

@MainActor
protocol AuthViewModelProtocol: ObservableObject {
    var state: ViewModelState<()> { get }
    
    func onAppear()
    func onNext()
    func onRetry()
}

final class AuthViewModel: AuthViewModelProtocol {
    private let userSession: any UserSessionProtocol
    private let oAuth2Service: OAuth2ServiceProtocol
    private let code: String?
    
    private let next: (AuthViewOutput) -> Void
    
    @Published private(set) var state: ViewModelState<()> = .loaded(())
        
    init(
        userSession: some UserSessionProtocol,
        oAuth2Service: some  OAuth2ServiceProtocol,
        code: String?,
        next: @escaping (AuthViewOutput) -> Void
    ) {
        self.userSession = userSession
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
            
            await userSession.setSession(token: AuthToken(accessToken: token, refreshToken: nil, expirationTimestamp: nil))
            
            state = .loaded(())
            
            next(.onAuthenticated(token: token))
        }
        catch {
            state = .error
            debugPrint(error)
        }
    }
}
