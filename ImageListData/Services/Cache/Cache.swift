//
//  Cache.swift
//  ImageListData
//
//  Created by Александр Зиновьев on 09.09.2025.
//

import Foundation

public protocol CacheProtocol<Key, Value>: Sendable {
    associatedtype Key: Hashable, Sendable
    associatedtype Value: Sendable
    
    func setValue(_ value: Value, for key: Key) async
    func getValue(for key: Key) async -> Value?
}

final actor Cache<Key, Value>: CacheProtocol
where
    Key: Sendable & Hashable,
    Value: Sendable
{
    private(set) var values: [Key: Value] = [:]
    
    func setValue(_ value: Value, for key: Key) async {
        values[key] = value
    }
    
    func getValue(for key: Key) async -> Value? {
        values[key]
    }
}
