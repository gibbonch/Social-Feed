import Foundation

/// UI-модель ячейки поста.
struct PostCellViewModel {
    let id: String
    let avatarURL: URL?
    let username: String
    let postImageURL: URL?
    let title: String
    let text: String
    let created: Date
    let totalLikes: Int
    let isLiked: Bool
    let isStored: Bool
    let isExpanded: Bool
}

extension PostCellViewModel: Hashable {
    static func ==(lhs: PostCellViewModel, rhs: PostCellViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Билдер UI-модели ячейки поста для удобного создания и изменения
struct PostCellViewModelBuilder {
    var isLiked: Bool
    var isStored: Bool
    var isExpanded: Bool
    var totalLikes: Int
    private let id: String
    private let avatarURL: URL?
    private let username: String
    private let postImageURL: URL?
    private let title: String
    private let text: String
    private let created: Date

    /// Инициализатор из UI-модели.
    init(postCellViewModel: PostCellViewModel) {
        self.id = postCellViewModel.id
        self.avatarURL = postCellViewModel.avatarURL
        self.username = postCellViewModel.username
        self.postImageURL = postCellViewModel.postImageURL
        self.title = postCellViewModel.title
        self.text = postCellViewModel.text
        self.created = postCellViewModel.created
        self.totalLikes = postCellViewModel.totalLikes
        self.isLiked = postCellViewModel.isLiked
        self.isStored = postCellViewModel.isStored
        self.isExpanded = postCellViewModel.isExpanded
    }

    /// Инициализатор из бизнес-модели Post.
    init(post: Post) {
        self.id = post.id
        self.avatarURL = URL(string: post.avatar ?? "")
        self.username = post.username
        self.postImageURL = URL(string: post.image)
        self.title = post.title
        self.text = post.text
        self.created = post.created
        self.totalLikes = post.totalLikes
        self.isLiked = post.isLiked
        self.isStored = post.isStored
        self.isExpanded = false
    }

    func build() -> PostCellViewModel {
        return PostCellViewModel(
            id: id,
            avatarURL: avatarURL,
            username: username,
            postImageURL: postImageURL,
            title: title,
            text: text,
            created: created,
            totalLikes: totalLikes,
            isLiked: isLiked,
            isStored: isStored,
            isExpanded: isExpanded
        )
    }
}
