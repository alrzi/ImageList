//
//  ProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile() async throws -> Profile
}

final class ProfileService: ProfileServiceProtocol {
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
    
    func fetchProfile() async throws -> Profile {
        let token = try oAuth2TokenStorage.token
        
        let request = ProfileRequest(
            token: token,
            authConfiguration: OAuthConfigurationProvider.config
        )
        
        let data = try await networkService.fetchData(for: request)
        
        let result = try decoder.decode(ProfileResult.self, from: data)
        
        return result.toProfile()
    }
}

private struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    func toProfile() -> Profile {
        Profile(
            username: self.username,
            name: self.firstName + " " + self.lastName,
            loginName: "@" + self.username,
            bio: self.bio ?? ""
        )
    }
}

private struct ProfileRequest: RequestConvertible {
    let token: String
    let method: HTTPMethod = .get
    let timeoutInterval: TimeInterval = 30
    let authConfiguration: UnsplashAuthConfiguration
    
    func asURLRequest() throws(RequestConvertibleError) -> URLRequest {
        guard var components = URLComponents(string: authConfiguration.defaultBaseHost) else {
            throw .malformedURLString
        }
        
        components.path = "/me"
        
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
