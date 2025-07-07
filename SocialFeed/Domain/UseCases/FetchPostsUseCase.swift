import Foundation

protocol FetchPostsUseCase {
    
    func execute(page: Int, perPage: Int, completion: @escaping FetchPostsCompletion)
}

final class FetchMockPostsUseCase: FetchPostsUseCase {
    
    private let queue = DispatchQueue(
        label: "com.fetch-posts-use-case.serial-queue",
        qos: .userInitiated
    )
    
    func execute(page: Int, perPage: Int, completion: @escaping FetchPostsCompletion) {
        queue.async {
            usleep(UInt32.random(in: 500_000...2_000_000))
            completion(.success([Post].mock))
        }
    }
}
