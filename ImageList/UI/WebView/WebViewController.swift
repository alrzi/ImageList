//
//  WebViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.01.2023.
//

import UIKit
import WebKit
import Combine

final class WebViewController: UIViewController {
    @objc
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.accessibilityIdentifier = "WebView"
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        return webView
    }()
      
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressViewStyle = .default
        progressView.tintColor = .myBackground
        return progressView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private let viewModel: WebViewModel
        
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        setConstraints()
        bind()
    }
}

// MARK: - Private

private extension WebViewController {
    func setViews() {
        view.addSubviews(webView, progressView)
        view.backgroundColor = .white
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bind() {
        viewModel.$request
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [webView] in webView.load($0) }
            .store(in: &cancellables)
        
        viewModel.$webViewProgress
            .receive(on: DispatchQueue.main)
            .map { $0.isHidden }
            .sink { [progressView] in progressView.isHidden = $0 }
            .store(in: &cancellables)
                
        viewModel.$webViewProgress
            .receive(on: DispatchQueue.main)
            .map { $0.progressValue }
            .sink { [progressView] in progressView.progress = $0 }
            .store(in: &cancellables)
        
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.viewModel.onProgressValueUpdated($0) }
            .store(in: &cancellables)
    }
}

private extension WebViewProgress {
    var isHidden: Bool {
        switch self {
        case .onGoing: false
        case .finished: true
        }
    }
    
    var progressValue: Float {
        switch self {
        case .onGoing(let progress): progress
        case .finished: 0
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else {
            return .allow
        }
                
        guard viewModel.isURLValid(url) else {
            return .allow
        }
        
        return .cancel
    }
}
