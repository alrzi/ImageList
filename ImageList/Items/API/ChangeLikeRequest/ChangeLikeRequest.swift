//
//  ChangeLikeRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

extension API {
    struct ChangeLikeRequest: RequestConvertible {
        let photoId: String
        let token: String
        let method: HTTPMethod
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration = .standard
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
                throw .malformedURLString
            }
            
            components.path = "/photos/\(photoId)/like"
            
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
}
