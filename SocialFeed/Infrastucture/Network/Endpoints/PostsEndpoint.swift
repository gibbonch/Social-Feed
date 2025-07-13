import Alamofire

enum PostsEndpoint: Endpoint {
    
    case getPosts(page: Int, perPage: Int)
    case getPost(id: String)
    case postLike(id: String)
    case deleteLike(id: String)
    
    var path: String {
        switch self {
        case .getPosts(page: _, perPage: _):
            return "/posts"
        case .getPost(id: let id):
            return "posts/\(id)"
        case .postLike(id: let id), .deleteLike(id: let id):
            return "posts/\(id)/like"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            
        case .getPosts(page: _, perPage: _), .getPost(id: _):
            return .get
        case .postLike(id: _):
            return .post
        case .deleteLike(id: _):
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getPosts(page: let page, perPage: let perPage):
            return ["page": page, "per_page": perPage]
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var mockResponseFileName: String? {
        switch self {
        case .getPosts(page: _, perPage: _):
            return "get_posts"
        default:
            return nil
        }
    }
}
