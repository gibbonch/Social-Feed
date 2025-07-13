enum FeedSegment: String, CaseIterable {
    case remote = "Рекомендации"
    case local = "Сохраненные"
    
    var index: Int {
        switch self {
        case .remote:
            return 0
        case .local:
            return 1
        }
    }
}
