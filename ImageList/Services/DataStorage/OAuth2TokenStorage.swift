//
//  OAuth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation
import SwiftKeychainWrapper

enum OAuth2TokenStorageError: Error {
    case tokenNotFound
}

protocol OAuth2TokenStorageProtocol: AnyObject {
    var token: String { get throws(OAuth2TokenStorageError) }
    
    func setToken(_ token: String?)
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let keyChain = KeychainWrapper.standard
    
    var token: String {
        get throws(OAuth2TokenStorageError) {
            if let token = keyChain.string(forKey: Key.token.rawValue) {
                token
            }
            else {
                throw .tokenNotFound
            }
        }
    }
    
    func setToken(_ token: String?) {
        if let token {
            keyChain.set(token, forKey: Key.token.rawValue)
        }
        else {
            keyChain.removeObject(forKey: Key.token.rawValue)
        }
    }
}

private enum Key: String {
    case token
}
