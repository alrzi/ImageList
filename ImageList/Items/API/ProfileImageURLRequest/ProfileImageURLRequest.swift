//
//  ProfileImageURLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

extension API {
    struct ProfileImageURLRequest: CommonRequestProtocol {
        typealias Response = UserResult
                        
        let token: String
        let username: String
        let method: HTTPMethod = .get
        let decoder: JSONDecoder = .sharedDecoder
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration = .standard
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
                throw .malformedURLString
            }
            
            components.path = "/users/\(username)"
            
            guard let url = components.url else {
                throw .componentToURLFailure
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.timeoutInterval = timeoutInterval
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
    
    struct UserResult: Decodable {
        let profileImage: ProfileImage
    }
    
    struct ProfileImage: Decodable {
        let small: String
        let medium: String
        let large: String
    }
}
