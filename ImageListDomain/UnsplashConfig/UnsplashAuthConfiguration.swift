
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
    var missingFields: [String] {
        var fields: [String] = []
        if accessKey.isEmpty { fields.append("accessKey") }
        if secretKey.isEmpty { fields.append("secretKey") }
        if redirectURI.isEmpty { fields.append("redirectURI") }
        if accessScope.isEmpty { fields.append("accessScope") }
        return fields
    }
    
    var isValid: Bool {
        missingFields.isEmpty
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
        
        public init?(string: String) {
            switch string {
            case "public": self = .public
            case "read_user": self = .readUser
            case "write_likes": self = .writeLikes
            case "read_collections": self = .readCollections
            case "write_collections": self = .writeCollections
            default:
                #if DEBUG
                print("⚠️ Неизвестный access scope: \(string)")
                #endif
                return nil
            }
        }
        
        public static func parse(from string: String) -> [AccessScope] {
            guard !string.isEmpty else {
                return [.public, .readUser, .writeLikes]
            }
            
            let parsedScopes = string.components(separatedBy: "+").compactMap { AccessScope(string: $0) }
            return parsedScopes.isEmpty ? [.public, .readUser, .writeLikes] : parsedScopes
        }
    }
}
