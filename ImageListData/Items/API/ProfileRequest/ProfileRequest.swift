//
//  ProfileRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import ImageListDomain
internal import NetworkService

extension API {
    struct ProfileRequest: CommonRequestProtocol {
        typealias Response = ProfileResult
                        
        let token: String
        let method: HTTPMethod = .get
        let decoder: JSONDecoder = .snakeCaseIsoDateDecoder
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
                throw .malformedURLString
            }
            
            components.path = "/me"
            
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
    
    struct ProfileResult: Decodable {
        let username: String
        let firstName: String
        let lastName: String
        let totalLikes: Int
        let bio: String?
    }
}
