import UIKit

final class TabBarController: UITabBarController {
    private let imagesListNavigationController: UINavigationController
    private let profileViewController: UIViewController
    
    init(
        imagesListNavigationController: UINavigationController,
        profileViewController: UIViewController
    ) {
        self.imagesListNavigationController = imagesListNavigationController
        self.profileViewController = profileViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        
        if #available(iOS 18.0, *) {
            delegate = self
        }
        
        viewControllers = [
            generateViewController(imagesListNavigationController, image: UIImage(resource: ._03TabBarLeft)),
            generateViewController(profileViewController, image: UIImage(resource: ._04TabBarRight))
        ]
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        self
    }
}

extension TabBarController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        .zero
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let view = transitionContext.view(forKey: .to) else {
            return
        }
        
        let container = transitionContext.containerView
        container.addSubview(view)
        
        transitionContext.completeTransition(true)
    }
}

private extension TabBarController {
    func generateViewController(_ rootViewController: UIViewController, image: UIImage) -> UIViewController {
        let vc = rootViewController
        vc.tabBarItem.image = image
        return vc
    }
    
    func setAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
    }
}
