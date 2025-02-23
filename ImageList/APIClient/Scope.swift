enum Scope {
    case `public`
    case readUser
    case writeLikes
    case readCollections
    case writeCollections
    
    var string: String {
        switch self {
        case .public: "public"
        case .readUser: "read_user"
        case .writeLikes: "write_likes"
        case .readCollections: "read_collections"
        case .writeCollections: "write_collections"
        }
    }
}
