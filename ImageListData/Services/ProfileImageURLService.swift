//
//  ProfileImageURLService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//

import Foundation
import ImageListDomain
internal import NetworkServiceDomain

struct ProfileImageURLService: ProfileImageURLServiceProtocol {
    let networkService: NetworkClientProtocol
    let authConfigurationProvider: AuthConfigurationProviding
    
    func fetchProfileImageUrl(username: String) async throws -> URL {
        let request = API.ProfileImageURLRequest(
            username: username,
            authConfiguration: authConfigurationProvider.config
        )
                
        let response = try await networkService.perform(request)
        
        guard let url = URL(string: response.profileImage.large) else {
            throw Errors.urlCreationFailed
        }
        
        return url
    }
}

private enum Errors: Error {
    case urlCreationFailed
}
