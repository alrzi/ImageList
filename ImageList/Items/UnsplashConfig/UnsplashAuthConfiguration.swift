protocol AuthConfigurationProtocol {
    var accessKey: String { get }
    var secretKey: String { get }
    var redirectURI: String { get }
    var accessScope: String { get }
    var defaultBaseHost: String { get }
    var oAuthHost: String { get }
}

extension AuthConfigurationProtocol {
    #if DEBUG
    static var standard: UnsplashAuthConfiguration {
        UnsplashAuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScope,
            defaultBaseHost: DefaultBaseHost,
            oAuthHost: OAuthHost
        )
    }
    #endif
}

struct UnsplashAuthConfiguration: AuthConfigurationProtocol {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseHost: String
    let oAuthHost: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: [UnsplashAccessScope],
        defaultBaseHost: String,
        oAuthHost: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope.map { $0.string }.joined(separator: "+")
        self.defaultBaseHost = defaultBaseHost
        self.oAuthHost = oAuthHost
    }
}

// swiftlint:disable identifier_name
private let AccessKey = "SS4lXp7vzIwOgPt0F2sOiUW-jsD6--h2Red2jA82kbQ"
private let SecretKey = "0xgcQI41BRbflXzVQ8oIAmKQd--Dk-cYJ-TV44d5d3k"
private let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
private let AccessScope: [UnsplashAccessScope] = [.public, .readUser, .writeLikes]
private let DefaultBaseHost = "https://api.unsplash.com"
private let OAuthHost = "https://unsplash.com"
// swiftlint:enable identifier_name
