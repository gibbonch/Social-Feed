import Foundation

final class PostsProvider: PostsProviding {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchPosts(page: Int, perPage: Int, completion: @escaping FetchPostsCompletion) {
        let endpoint = PostsEndpoint.getPosts(page: page, perPage: perPage)
        client.request(endpoint, responseType: [PostSchema].self) { result in
            switch result {
            case .success(let schemas):
                completion(.success(schemas))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPost(by id: String, completion: @escaping FetchPostCompletion) {
        // not implemented yet
    }
}
