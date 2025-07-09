import UIKit

/// View автора поста. Содержит изображение пользователя и имя.
final class PostAuthorView: UIView {
    
    // MARK: - Constants
    
    static let avatarSize = CGSize(width: 32, height: 32)
    
    // MARK: - Subviews
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    func setAvatar(image: UIImage) {
        avatarImageView.image = image
    }
    
    func setAvatar(url: URL) {
        
    }
    
    func setUsername(_ username: String) {
        usernameLabel.text = username
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubview(avatarImageView)
        addSubview(usernameLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: Self.avatarSize.height),
            avatarImageView.widthAnchor.constraint(equalToConstant: Self.avatarSize.width),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: topAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
