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
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 60
        config.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024,
                                diskCapacity: 100 * 1024 * 1024)
        config.requestCachePolicy = .useProtocolCachePolicy
        let networkClient = NetworkClient(environment: .mock, configuration: config)
        
        let provider = PostsProvider(client: networkClient)
        
        let viewModel = FeedViewModelImpl(fetchPostsUseCase: FetchPostsUseCaseImpl(postProvider: provider))
        let viewController = FeedViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
}
