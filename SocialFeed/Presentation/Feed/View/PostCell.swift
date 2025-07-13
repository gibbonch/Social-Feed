import UIKit
import AlamofireImage

/// Ячейка поста.
final class PostCell: UITableViewCell {
    
    // MARK: - Callbacks
    
    var onLikeTap: (() -> Void)?
    var onStoreTap: (() -> Void)?
    var onTextExpansion: (() -> Void)?
    
    // MARK: - Subviews
    
    private lazy var authorView: PostAuthorView = {
        let view = PostAuthorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray.withAlphaComponent(0.4)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var postTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var expandableContentView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var createdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        button.setImage(.heart, for: .normal)
        button.tintColor = .lightGrayAssets
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var storeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(storeButtonTapped), for: .touchUpInside)
        button.setImage(.bookmark, for: .normal)
        button.tintColor = .lightGrayAssets
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Constraints
    
    private var expandableContentHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    
    private var originalText = ""
    private var isExpanded = false
    private var isLiked = false
    private var isStored = false
    private var totalLikes = 0
    private var currentImageURL: URL?
    
    // MARK: - Constants
    
    private let insets = UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
    private let numberOfLinesWhenCollapsed = 3
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupCell()
        setupConstraints()
        setupGestures()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        postImageView.af.cancelImageRequest()
        currentImageURL = nil
    }
    
    // MARK: - Internal Methods
    
    func configure(viewModel: PostCellViewModel) {
        authorView.setUsername(viewModel.username)
        headerLabel.text = viewModel.title
        createdLabel.text = viewModel.created.formatDate
        originalText = viewModel.text
        isExpanded = viewModel.isExpanded
        isLiked = viewModel.isLiked
        likesCountLabel.text = "\(viewModel.totalLikes)"
        totalLikes = viewModel.totalLikes
        isStored = viewModel.isStored
        
        if let avatarURL = viewModel.avatarURL {
            authorView.setAvatar(url: avatarURL)
        } else {
            authorView.setAvatar(image: .avatar)
        }
        
        if let postImageURL = viewModel.postImageURL {
            loadPostImage(from: postImageURL)
        } else {
            postImageView.image = nil
            currentImageURL = nil
        }
        
        updateTextDisplay()
        updateLikeButton()
        updateStoreButton()
    }
    
    // MARK: - Private Methods
    
    private func loadPostImage(from url: URL) {
        guard currentImageURL != url else { return }
        
        postImageView.af.cancelImageRequest()
        
        currentImageURL = url
        
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width * 2/3
        )
        
        let imageFilter = AspectScaledToFillSizeFilter(size: targetSize)
        
        postImageView.af.setImage(
            withURL: url,
            placeholderImage: nil,
            filter: imageFilter,
            progress: nil,
            progressQueue: .main,
            imageTransition: .crossDissolve(0.2),
            runImageTransitionIfCached: false)
    }
    
    private func updateTextDisplay() {
        let font = postTextLabel.font ?? .systemFont(ofSize: 12, weight: .regular)
        let availableWidth = UIScreen.main.bounds.width - insets.left - insets.right
        
        if isExpanded {
            postTextLabel.text = originalText
            expandableContentHeightConstraint.constant = originalText.height(
                withConstrainedWidth: availableWidth,
                font: font
            )
        } else {
            let fittingText = originalText.fittingSubstring(
                font: font,
                width: availableWidth,
                maxLines: numberOfLinesWhenCollapsed
            )
            
            postTextLabel.text = fittingText
            
            expandableContentHeightConstraint.constant = fittingText.height(
                withConstrainedWidth: availableWidth,
                font: font
            )
        }
    }
    
    private func updateLikeButton() {
        likeButton.tintColor = isLiked ? .redAssets : .lightGrayAssets
    }
    
    private func updateStoreButton() {
        storeButton.tintColor = isStored ? .redAssets : .lightGrayAssets
    }
    
    private func setupCell() {
        contentView.addSubview(authorView)
        contentView.addSubview(postImageView)
        contentView.addSubview(headerLabel)
        expandableContentView.addSubview(postTextLabel)
        contentView.addSubview(expandableContentView)
        contentView.addSubview(createdLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(storeButton)
    }
    
    private func setupConstraints() {
        // authorView
        NSLayoutConstraint.activate([
            authorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            authorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            authorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            authorView.heightAnchor.constraint(equalToConstant: PostAuthorView.avatarSize.height)
        ])
        
        // postImageView
        NSLayoutConstraint.activate([
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.topAnchor.constraint(equalTo: authorView.bottomAnchor, constant: 8),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 2 / 3)
        ])
        
        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            headerLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12)
        ])
        
        // expandableContentView
        expandableContentHeightConstraint = expandableContentView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            expandableContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            expandableContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            expandableContentView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            expandableContentHeightConstraint
        ])
        
        // postTextLabel
        NSLayoutConstraint.activate([
            postTextLabel.leadingAnchor.constraint(equalTo: expandableContentView.leadingAnchor),
            postTextLabel.trailingAnchor.constraint(equalTo: expandableContentView.trailingAnchor),
            postTextLabel.topAnchor.constraint(equalTo: expandableContentView.topAnchor)
        ])
        
        // createdLabel
        NSLayoutConstraint.activate([
            createdLabel.topAnchor.constraint(equalTo: expandableContentView.bottomAnchor, constant: 8),
            createdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            createdLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
        ])
        
        // likeButton
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24),
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            likeButton.topAnchor.constraint(equalTo: createdLabel.bottomAnchor, constant: 12)
        ])
        
        // likesCountLabel
        NSLayoutConstraint.activate([
            likesCountLabel.topAnchor.constraint(equalTo: likeButton.topAnchor),
            likesCountLabel.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor),
            likesCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 12),
        ])
        
        // storeButton
        NSLayoutConstraint.activate([
            storeButton.widthAnchor.constraint(equalToConstant: 24),
            storeButton.heightAnchor.constraint(equalToConstant: 24),
            storeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.left),
            storeButton.topAnchor.constraint(equalTo: createdLabel.bottomAnchor, constant: 12)
        ])
        
        // bottom constraint
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: insets.bottom)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(expandCell))
        postTextLabel.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    // MARK: - Actions
    
    @objc private func expandCell() {
        guard let tableView = superview as? UITableView, !isExpanded else {
            return
        }
        
        isExpanded = true
        
        let font = postTextLabel.font ?? .systemFont(ofSize: 12, weight: .regular)
        let availableWidth = UIScreen.main.bounds.width - insets.left - insets.right
        
        postTextLabel.text = originalText
        
        expandableContentHeightConstraint.constant = originalText.height(
            withConstrainedWidth: availableWidth,
            font: font
        )
        
        tableView.performBatchUpdates { [weak self] in
            self?.layoutIfNeeded()
        } completion: { [weak self] completed in
            if completed {
                self?.onTextExpansion?()
            }
        }
    }
    
    @objc private func likeButtonTapped() {
        isLiked.toggle()
        updateLikeButton()
        totalLikes += isLiked ? 1 : -1
        likesCountLabel.text = "\(totalLikes)"
        onLikeTap?()
    }
    
    @objc private func storeButtonTapped() {
        isStored.toggle()
        updateStoreButton()
        onStoreTap?()
    }
}
