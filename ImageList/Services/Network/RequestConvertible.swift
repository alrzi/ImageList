//
//  RequestConvertible.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2025.
//

import Foundation

public enum RequestConvertibleError: Error {
    case malformedURLString
    case componentToURLFailure
}

public protocol RequestConvertible {
    func asURLRequest() throws(RequestConvertibleError) -> URLRequest
}
