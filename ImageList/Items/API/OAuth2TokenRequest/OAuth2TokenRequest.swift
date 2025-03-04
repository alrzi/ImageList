//
//  OAuth2TokenRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

extension API {
    struct OAuth2TokenRequest: CommonRequestProtocol {
        typealias Response = OAuthTokenResponseBody
                        
        let code: String
        let decoder: JSONDecoder = .sharedDecoder
        let method: HTTPMethod = .post
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration = .standard
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.oAuthHost) else {
                throw .malformedURLString
            }
            
            let queryItems = [
                URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
                URLQueryItem(name: "client_secret", value: authConfiguration.secretKey),
                URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
                        
            components.path = "/oauth/token"
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
    
    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
    }
}
