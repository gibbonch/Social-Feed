/// Протокол для управления отложенными действиями лайков/анлайков, которые еще не синхронизированы с сервером
protocol PendingLikeActionsManaging {
    
    /// Добавляет в очередь действие лайка для указанного поста
    func queueLikeAction(for postId: String)
    
    /// Добавляет в очередь действие дизлайка для указанного поста
    func queueUnlikeAction(for postId: String)
    
    /// Получает все отложенные действия для конкретного поста
    func pendingActions(for postId: String) -> [PendingLikeAction]
    
    /// Удаляет все отложенные действия из очереди
    func clearAllPendingActions()
    
    /// Удаляет отложенное действие для конкретного поста
    func removePendingAction(for postId: String)
}
