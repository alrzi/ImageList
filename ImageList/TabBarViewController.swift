import UIKit

final class TabBarController: UITabBarController {
    private let imagesListViewController: UIViewController
    private let profileViewController: UIViewController
    
    init(
        imagesListViewController: UIViewController,
        profileViewController: UIViewController
    ) {
        self.imagesListViewController = imagesListViewController
        self.profileViewController = profileViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        
        viewControllers = [
            generateViewController(imagesListViewController, image: .tabBarLeft),
            generateViewController(profileViewController, image: .tabBarRight)
        ]
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
        appearance.backgroundColor = .myBlack
        appearance.selectionIndicatorTintColor = .black
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
    }
}
