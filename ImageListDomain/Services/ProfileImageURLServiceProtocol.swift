//
//  ProfileImageURLServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol ProfileImageURLServiceProtocol: Sendable {
    func fetchProfileImageUrl(username: String) async throws -> URL
}
