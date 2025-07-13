struct FeedViewState {
    var isLoading: Bool = true
    var isRefreshing: Bool = false
    var posts: [PostCellViewModel] = []
    var page: Int = 0
    var perPage: Int = 10
    var needsLoad: Bool = true
}
