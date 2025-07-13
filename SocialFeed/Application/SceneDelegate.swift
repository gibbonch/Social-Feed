import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = assembly()
        window?.makeKeyAndVisible()
    }
    
    /// Composition Root
    private func assembly() -> UIViewController {
        let feedVM = FeedViewModelImpl(
            fetchPostsUseCase: DependencyContainer.shared.fetchPostsUseCase,
            likePostUseCase: DependencyContainer.shared.likePostUseCase,
            storePostUseCase: DependencyContainer.shared.storePostUseCase
        )
        let feedVC = FeedViewController(viewModel: feedVM)
        let navigationController = UINavigationController(rootViewController: feedVC)
        
        return navigationController
    }
}
