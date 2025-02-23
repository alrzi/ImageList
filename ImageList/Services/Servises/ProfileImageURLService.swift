//
//  ProfileImageURLService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//

import Foundation

protocol ProfileImageURLServiceProtocol {
    func fetchProfileImageUrl(username: String) async throws -> URL
}

final class ProfileImageURLService: ProfileImageURLServiceProtocol {
    private let decoder: JSONDecoder
    private let networkService: NetworkClientProtocol
    private let oAuth2TokenStorage: OAuth2TokenStorage
    
    init(
        decoder: JSONDecoder = .convertFromSnakeCase,
        networkService: NetworkClientProtocol,
        oAuth2TokenStorage: OAuth2TokenStorage
    ) {
        self.decoder = decoder
        self.networkService = networkService
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
    
    func fetchProfileImageUrl(username: String) async throws -> URL {
        let token = try oAuth2TokenStorage.token
                
        let request = ProfileImageURLRequest(
            token: token,
            username: username,
            authConfiguration: OAuthConfigurationProvider.config
        )
                
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode(UserResult.self, from: data)
        
        guard let url = URL(string: result.profileImage.large) else {
            throw Errors.urlCreationFailed
        }
        
        return url
    }
}
 
private extension ProfileImageURLService {
    struct UserResult: Decodable {
        let profileImage: ProfileImage
    }
    
    struct ProfileImage: Decodable {
        let small: String
        let medium: String
        let large: String
    }
}

private enum Errors: Error {
    case urlCreationFailed
}

private struct ProfileImageURLRequest: RequestConvertible {
    let token: String
    let username: String
    let method: HTTPMethod = .get
    let timeoutInterval: TimeInterval = 30
    let authConfiguration: UnsplashAuthConfiguration
    
    func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
        guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
            throw .malformedURLString
        }
        
        components.path = "/users/\(username)"
        
        guard let url = components.url else {
            throw .componentToURLFailure
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
