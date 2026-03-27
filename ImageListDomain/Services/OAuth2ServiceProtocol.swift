//
//  OAuth2ServiceProtocol.swift
//  ImageListDomain
//
//  Created by Александр Зиновьев on 05.03.2025.
//

import Foundation

public protocol OAuth2ServiceProtocol: Sendable {
    func fetchOAuthToken(withCode code: String) async throws -> String
}
