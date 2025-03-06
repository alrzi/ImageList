//
//  ImageServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol ImageServiceProtocol: Sendable {
    func fetchProfileImage(url: URL) async throws -> Data
}
