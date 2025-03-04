//
//  URLRequest+asURLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation

extension URLRequest: RequestProtocol {
    public var method: HTTPMethod { .get }
    
    public func response(from data: Data) throws -> Data {
        data
    }
        
    public func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
        self
    }
}
