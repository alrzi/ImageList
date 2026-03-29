//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

internal import NetworkServiceDomain
import Foundation
import ImageListDomain

struct OAuth2Service: OAuth2ServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding

    func fetchOAuthToken(withCode code: String) async throws -> String {
        let request = API.OAuth2TokenRequest(
            code: code,
            authConfiguration: authConfigurationProvider.config
        )

        let response = try await networkService.perform(request)

        return response.accessToken
    }
}
