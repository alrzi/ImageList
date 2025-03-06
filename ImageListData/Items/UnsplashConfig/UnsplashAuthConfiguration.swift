
public struct UnsplashAuthConfiguration: Sendable {
    public let accessKey: String
    public let secretKey: String
    public let redirectURI: String
    public let accessScope: String
    public let defaultBaseHost: String
    public let oAuthHost: String
    
    public init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: [AccessScope],
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

public extension UnsplashAuthConfiguration {
    enum AccessScope: Sendable {
        case `public`
        case readUser
        case writeLikes
        case readCollections
        case writeCollections
        
        public var string: String {
            switch self {
            case .public: "public"
            case .readUser: "read_user"
            case .writeLikes: "write_likes"
            case .readCollections: "read_collections"
            case .writeCollections: "write_collections"
            }
        }
    }
}

extension UnsplashAuthConfiguration {
    public static var standard: UnsplashAuthConfiguration {
        UnsplashAuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScopes,
            defaultBaseHost: DefaultBaseHost,
            oAuthHost: OAuthHost
        )
    }
}

// swiftlint:disable identifier_name
public let AccessKey = "SS4lXp7vzIwOgPt0F2sOiUW-jsD6--h2Red2jA82kbQ"
public let SecretKey = "0xgcQI41BRbflXzVQ8oIAmKQd--Dk-cYJ-TV44d5d3k"
public let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
public let AccessScopes: [UnsplashAuthConfiguration.AccessScope] = [.public, .readUser, .writeLikes]
public let DefaultBaseHost = "https://api.unsplash.com"
public let OAuthHost = "https://unsplash.com"
// swiftlint:enable identifier_name
