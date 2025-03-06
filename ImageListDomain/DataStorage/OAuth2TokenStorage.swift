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

public struct OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    public let keychain: SecureStorageProtocol
    
    public init(keychain: SecureStorageProtocol) {
        self.keychain = keychain
    }
    
    public var token: String {
        get async throws(OAuth2TokenStorageError) {
            guard let token = await keychain.getValue(key: Key.oAuth2TokenForUnsplash.rawValue) else {
                throw .tokenNotFound
            }
            
            return token
        }
    }
    
    public func setToken(_ token: String) async {
        await keychain.setValue(key: Key.oAuth2TokenForUnsplash.rawValue, value: token)
    }
    
    public func cleanToken() async {
        await keychain.clean(key: Key.oAuth2TokenForUnsplash.rawValue)
    }
}

private enum Key: String {
    case oAuth2TokenForUnsplash
}
