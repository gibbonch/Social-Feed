import Combine
import Foundation

protocol FeedViewModel {
    var state: AnyPublisher<FeedViewState, Never> { get }
    func viewLoaded()
    func likeTappedOnPost(with id: String)
    func storeTappedOnPost(with id: String)
    func postExpanded(at indexPath: IndexPath)
    func loadNextPage()
    func segmentChanged(to segment: FeedSegment)
    func refresh()
}
