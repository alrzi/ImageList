//
//  PhotosNextPageRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import ImageListDomain
internal import NetworkServiceDomain

extension API.PhotoResult {
    struct PhotosNextPageRequest: CommonRequestProtocol {
        typealias Response = [PhotoResult]
                        
        let page: Int
        let maxPerPage = 10
        let method: HTTPMethod = .get
        let decoder: JSONDecoder = .snakeCaseIsoDateDecoder
        let timeoutInterval: TimeInterval = 30
        let authConfiguration: UnsplashAuthConfiguration
        let requiresAuth: Bool = true
        
        func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
            guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
                throw .malformedURLString
            }
            
            let queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(maxPerPage)),
                URLQueryItem(name: "order_by", value: "latest")
            ]
            
            components.path = "/photos"
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
