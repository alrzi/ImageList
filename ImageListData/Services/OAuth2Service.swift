//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation
import ImageListDomain
internal import NetworkServiceDomain

struct OAuth2Service: OAuth2ServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding
    
    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = API.OAuth2TokenRequest(
            code: code,
            authConfiguration: authConfigurationProvider.config
        )
                
        let response = try await networkService.perform(request)
        
        return response.accessToken
    }
}
