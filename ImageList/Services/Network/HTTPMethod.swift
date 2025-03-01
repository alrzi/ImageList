//
//  HTTPMethod.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2023.
//

import Foundation

public struct HTTPMethod: RawRepresentable, Hashable, ExpressibleByStringLiteral, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

public extension HTTPMethod {
    static let get: HTTPMethod = "GET"
    static let post: HTTPMethod = "POST"
    static let put: HTTPMethod = "PUT"
    static let delete: HTTPMethod = "DELETE"
}
