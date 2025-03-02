//
//  KeychainService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 02.03.2025.
//

import Foundation

protocol KeychainServiceProtocol: Sendable {
    func getValue(key: String) async -> String?
    func setValue(key: String, value: String) async
    func clean(key: String) async
}

actor KeychainService: KeychainServiceProtocol {
    private let kSecClassValue = NSString(format: kSecClass)
    private let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    private let kSecValueDataValue = NSString(format: kSecValueData)
    private let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    private let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    private let kSecReturnDataValue = NSString(format: kSecReturnData)
    private let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

    func getValue(key: String) -> String? {
        let keychainQuery = NSMutableDictionary(
            objects: [
                kSecClassGenericPasswordValue,
                key,
                kCFBooleanTrue as Any,
                kSecMatchLimitOneValue
            ],
            forKeys: [
                kSecClassValue,
                kSecAttrAccountValue,
                kSecReturnDataValue,
                kSecMatchLimitValue
            ]
        )

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)

        var contentsOfKeychain: String?

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: .utf8)
            }
        }
        else {
            debugPrint("KeychainService status when trying to get value for \(key):", status)
        }

        return contentsOfKeychain
    }

    func setValue(key: String, value: String) {
        guard let dataFromString = value.data(using: String.Encoding.utf8) else {
            return
        }
            
        let keychainQuery = NSMutableDictionary(
            objects: [
                kSecClassGenericPasswordValue,
                key,
                dataFromString
            ],
            forKeys: [
                kSecClassValue,
                kSecAttrAccountValue,
                kSecValueDataValue
            ]
        )
        
        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    func clean(key: String) {
        let keychainQuery = NSMutableDictionary(
            objects: [
                kSecClassGenericPasswordValue,
                key
            ],
            forKeys: [
                kSecClassValue,
                kSecAttrAccountValue
            ]
        )
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
}
