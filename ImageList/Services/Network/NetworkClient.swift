//
//  NetworkClient.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation

public enum NetworkClientError: Error {
    case invalidStatusCode(statusCode: Int)
    case requestFailed(innerError: URLError)
    case otherError(innerError: Error)
    case creationFailureURLRequest(innerError: Error)
}

public protocol NetworkClientProtocol: Sendable {
    func fetchData<Request: RequestProtocol>(for request: Request) async throws(NetworkClientError) -> Request.Response
}

public struct NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    public func fetchData<Request: RequestProtocol>(for request: Request) async throws(NetworkClientError) -> Request.Response {
        do {
            let (data, response) = try await session.data(for: try request.asURLRequest())
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkClientError.invalidStatusCode(statusCode: -1)
            }
            
            guard (200...299).contains(statusCode) else {
                throw NetworkClientError.invalidStatusCode(statusCode: statusCode)
            }
            
            return try request.response(from: data)
        }
        catch let error as URLError {
            throw .requestFailed(innerError: error)
        }
        catch let error as NetworkClientError {
            throw error
        }
        catch let error as RequestConvertibleError {
            throw .creationFailureURLRequest(innerError: error)
        }
        catch {
            throw .otherError(innerError: error)
        }
    }
}
