/// Структура, описывающая текущее состояние экрана `Ленты постов`.
struct FeedViewState {
    var isLoading = false
    var isRefreshing = false
    var posts: [PostCellViewModel] = []
    var page = 0
    var perPage = 10
    var hasMoreData: Bool = true
}
