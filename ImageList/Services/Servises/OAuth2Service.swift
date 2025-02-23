//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation

protocol OAuth2ServiceProtocol {
    func fetchOAuthToken(withCode code: String) async throws -> String
}

struct OAuth2Service: OAuth2ServiceProtocol {
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
        
    init(
        networkService: NetworkClientProtocol,
        decoder: JSONDecoder = .convertFromSnakeCase
    ) {
        self.networkService = networkService
        self.decoder = decoder
    }
    
    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = OAuth2TokenRequest(
            code: code,
            authConfiguration: OAuthConfigurationProvider.config
        )
                
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

private struct OAuth2TokenRequest: RequestConvertible {
    let code: String
    let method: HTTPMethod = .post
    let timeoutInterval: TimeInterval = 30
    let authConfiguration: UnsplashAuthConfiguration
    
    func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
        guard var components = URLComponents(string: authConfiguration.tokenURLString) else {
            throw .malformedURLString
        }
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
            URLQueryItem(name: "client_secret", value: authConfiguration.secretKey),
            URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw .componentToURLFailure
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        
        return request
    }
}
