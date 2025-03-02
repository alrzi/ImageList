import UIKit

protocol DetailImageListViewControllerProtocol: AnyObject {
    var presenter: DetailImageListPresenterProtocol { get }
    
    func startSpinner()
    func stopSpinner()
    func showAlertAndMaybeTryAgainWith(url: URL)
    func hideScribble()
    func didReceiveImage(_ image: UIImage)
}

final class DetailImagesListViewController: UIViewController {
    private let photoImageView: UIImageView = {
        let image = UIImageView()
        image.alpha = 0
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let scribbleImageView: UIImageView = {
        let image = UIImageView(image: .scribble)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.accessibilityIdentifier = "backButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var blurredBackgroundBackButtonView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.layer.cornerRadius = 20
        visualEffectView.layer.masksToBounds = true
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private lazy var shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.setImage(.share, for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        return shareButton
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private var scrollView = DetailScrollView()
    
    internal let presenter: DetailImageListPresenterProtocol
    
    init(presenter: DetailImageListPresenterProtocol) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        setConstraints()
        presenter.fetchImage()
    }
    
    @objc
    private func goBack() {
        dismiss(animated: true)
    }
    
    @objc
    private func share() {
        guard let image = photoImageView.image else {
            return
        }
        
        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        present(activityController, animated: true, completion: nil)
    }
}

// MARK: - UI
private extension DetailImagesListViewController {
    func setViews() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        view.addSubview(blurredBackgroundBackButtonView)
        view.addSubview(shareButton)
        view.addSubview(spinner)
        view.addSubview(scribbleImageView)
        
        blurredBackgroundBackButtonView.contentView.addSubview(backButton)
        scrollView.setImageView(photoImageView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            
            // blurredBackgroundBackButtonView
            blurredBackgroundBackButtonView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            blurredBackgroundBackButtonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            blurredBackgroundBackButtonView.widthAnchor.constraint(equalToConstant: 40),
            blurredBackgroundBackButtonView.heightAnchor.constraint(equalToConstant: 40),
            
            // backButton
            backButton.leadingAnchor.constraint(equalTo: blurredBackgroundBackButtonView.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: blurredBackgroundBackButtonView.bottomAnchor),
            backButton.trailingAnchor.constraint(equalTo: blurredBackgroundBackButtonView.trailingAnchor),
            backButton.topAnchor.constraint(equalTo: blurredBackgroundBackButtonView.topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            // shareButton
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // spinner
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            
            // scribble
            scribbleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scribbleImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension DetailImagesListViewController: @preconcurrency DetailImageListViewControllerProtocol {
    func didReceiveImage(_ image: UIImage) {
        photoImageView.image = image
        
        view.layoutIfNeeded()
        scrollView.rescaleImage()
        scrollView.layoutIfNeeded()
        scrollView.centerImage()
        
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.photoImageView.alpha = 1
        }
    }
    
    func hideScribble() {
        scribbleImageView.isHidden = true
    }
    
    func startSpinner() {
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
    }
    
    func showAlertAndMaybeTryAgainWith(url: URL) {
        print("showAlertAndMaybeTryAgainWith")
    }
}
