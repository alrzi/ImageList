
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
