import Combine
import Foundation

protocol FeedViewModel {
    var state: AnyPublisher<FeedViewState, Never> { get }
    func viewLoaded()
    func likeTappedOnPost(at indexPath: IndexPath)
    func storeTappedOnPost(at indexPath: IndexPath)
    func postExpanded(at indexPath: IndexPath)
    func loadNextPageIfNeeded()
}
