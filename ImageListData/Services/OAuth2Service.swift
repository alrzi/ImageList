//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation
import ImageListDomain
internal import NetworkService

struct OAuth2Service: OAuth2ServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    private let authConfigurationProvider: AuthConfigurationProviding
        
    init(
        networkService: NetworkServiceProtocol,
        authConfigurationProvider: AuthConfigurationProviding
    ) {
        self.networkService = networkService
        self.authConfigurationProvider = authConfigurationProvider
    }
    
    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = API.OAuth2TokenRequest(
            code: code,
            authConfiguration: authConfigurationProvider.config
        )
                
        let response = try await networkService.fetchData(for: request)
        
        return response.accessToken
    }
}
