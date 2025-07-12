protocol FavoriteManaging {
    
    func addPendingLike(_ postId: String)
    func addPendingUnlike(_ postId: String)
    func pendingActions(for postId: String) -> [FavoriteAction]
    func clearPendingActions()
}
