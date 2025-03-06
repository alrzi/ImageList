//
//  OAuth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation

public enum OAuth2TokenStorageError: Error {
    case tokenNotFound
}

public protocol OAuth2TokenStorageProtocol: Sendable {
    var token: String { get async throws(OAuth2TokenStorageError) }
    
    func setToken(_ token: String) async
    func cleanToken() async
}

struct OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let secureStorage: SecureStorageProtocol
    
    init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage
    }
    
    var token: String {
        get async throws(OAuth2TokenStorageError) {
            guard let token = await secureStorage.getValue(key: Key.oAuth2TokenForUnsplash.rawValue) else {
                throw .tokenNotFound
            }
            
            return token
        }
    }
    
    func setToken(_ token: String) async {
        await secureStorage.setValue(key: Key.oAuth2TokenForUnsplash.rawValue, value: token)
    }
    
    func cleanToken() async {
        await secureStorage.clean(key: Key.oAuth2TokenForUnsplash.rawValue)
    }
}

private enum Key: String {
    case oAuth2TokenForUnsplash
}
