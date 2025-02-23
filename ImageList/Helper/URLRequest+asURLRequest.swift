//
//  URLRequest+asURLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation

extension URLRequest: RequestConvertible {
    public func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
        self
    }
}
