//
//  AuthViewOutput.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation

enum AuthViewOutput: Sendable {
    case onAuthenticated(token: String)
    case onAuthenticate
}
