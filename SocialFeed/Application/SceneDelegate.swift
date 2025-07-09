import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = assembly()
        window?.makeKeyAndVisible()
    }
    
    private func assembly() -> UIViewController {
        let viewModel = FeedViewModelImpl(fetchPostsUseCase: FetchMockPostsUseCase())
        let viewController = FeedViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
