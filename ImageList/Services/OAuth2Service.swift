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
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
        
    init(
        networkService: NetworkClientProtocol,
        decoder: JSONDecoder
    ) {
        self.networkService = networkService
        self.decoder = decoder
    }
    
    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = API.OAuth2TokenRequest(code: code)
                
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode(OAuthTokenResponseBody.self, from: data)
        
        return result.accessToken
    }
}

private extension OAuth2Service {
    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
    }
}
