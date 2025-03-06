//
//  ProfileServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol ProfileServiceProtocol: Sendable {
    func fetchProfile() async throws -> Profile
}
