//
//  FavoriteUserImagesRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation

extension API.PhotoResult {
    struct FavoriteUserImagesRequest: CommonRequestProtocol {
        typealias Response = [PhotoResult]
        
        let userName: String
        let params: FetchingRequestParams
        let token: String
        let decoder: JSONDecoder = .sharedDecoder
        let method: HTTPMethod = .get
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration = .standard
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
                throw .malformedURLString
            }
            
            let queryItems = [
                URLQueryItem(name: "username", value: userName),
                URLQueryItem(name: "page", value: String(params.page)),
                URLQueryItem(name: "per_page", value: String(params.maxPerPage)),
                URLQueryItem(name: "order_by", value: "latest")
            ]
            
            components.path = "/users/\(userName)/likes"
            components.queryItems = queryItems
            
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
