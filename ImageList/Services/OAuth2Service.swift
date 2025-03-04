//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation

protocol OAuth2ServiceProtocol: Sendable {
    func fetchOAuthToken(withCode code: String) async throws -> String
}

struct OAuth2Service: OAuth2ServiceProtocol {
    private let networkService: NetworkClientProtocol
        
    init(networkService: NetworkClientProtocol) {
        self.networkService = networkService
    }
    
    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = API.OAuth2TokenRequest(code: code)
                
        let response = try await networkService.fetchData(for: request)
        
        return response.accessToken
    }
}
