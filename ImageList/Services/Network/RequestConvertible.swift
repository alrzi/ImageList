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

public typealias CommonRequestProtocol = RequestProtocol & DecoderProviding

public protocol RequestConvertible {
    func asURLRequest() throws(RequestConvertibleError) -> URLRequest
}

public protocol RequestProtocol: RequestConvertible {
    associatedtype Response
    
    var method: HTTPMethod { get }
    
    func response(from data: Data) throws -> Response
}

public protocol DecoderProviding {
    associatedtype Decoder
    
    var decoder: Decoder { get }
}

public extension RequestProtocol where Response: Decodable, Self: DecoderProviding, Decoder == JSONDecoder {
    func response(from data: Data) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}

public extension RequestProtocol where Response == Void {
    func response(from data: Data) throws -> Response {
        ()
    }
}
