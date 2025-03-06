//
//  ImageServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol ImageServiceProtocol: Sendable {
    func fetchImage(url: URL) async throws -> Data
}
