//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation
internal import NetworkService
import ImageListDomain

struct OAuth2Service: OAuth2ServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    private let authConfiguration: UnsplashAuthConfiguration
        
    init(
        networkService: NetworkServiceProtocol,
        authConfiguration: UnsplashAuthConfiguration
    ) {
        self.networkService = networkService
        self.authConfiguration = authConfiguration
    }
    
    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = API.OAuth2TokenRequest(
            code: code,
            authConfiguration: authConfiguration
        )
                
        let response = try await networkService.fetchData(for: request)
        
        return response.accessToken
    }
}
