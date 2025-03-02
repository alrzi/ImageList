//
//  AuthRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

extension API {
    struct AuthRequest: RequestConvertible {
        let method: HTTPMethod = .get
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.oAuthHost) else {
                throw .malformedURLString
            }
            
            let queryItems = [
                URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
                URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "scope", value: authConfiguration.accessScope)
            ]
                        
            components.path = "/oauth/authorize"
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
}
