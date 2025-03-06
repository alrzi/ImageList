//
//  SecureStorageProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol SecureStorageProtocol: Sendable {
    func getValue(key: String) async -> String?
    func setValue(key: String, value: String) async
    func clean(key: String) async
}
