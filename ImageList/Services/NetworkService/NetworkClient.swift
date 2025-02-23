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

public protocol NetworkClientProtocol {
    func fetchData(for requestConvertible: RequestConvertible) async throws(NetworkClientError) -> Data
}

struct NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetchData(for requestConvertible: RequestConvertible) async throws(NetworkClientError) -> Data {
        do {
            let request = try requestConvertible.asURLRequest()
            
            let (data, response) = try await session.data(for: request)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkClientError.invalidStatusCode(statusCode: -1)
            }
            
            guard (200...299).contains(statusCode) else {
                throw NetworkClientError.invalidStatusCode(statusCode: statusCode)
            }
            
            return data
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
