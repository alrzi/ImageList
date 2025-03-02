//
//  WebViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2023.
//

import Foundation
import Combine

@MainActor
protocol WebViewModelProtocol: AnyObject {
    var request: URLRequest? { get }
    var webViewProgress: WebViewProgress { get }
    
    func onProgressValueUpdated(_ newValue: Double)
    func onBackButton()
    func isURLValid(_ url: URL) -> Bool
}

final class WebViewModel: WebViewModelProtocol {
    private let authHelper: WebViewAuthHelper
    private let onComplete: (WebViewOutput) -> Void
    
    @Published private(set) var request: URLRequest?
    @Published private(set) var webViewProgress: WebViewProgress = .idle
    
    init(
        authHelper: WebViewAuthHelper = .init(),
        onComplete: @escaping (WebViewOutput) -> Void
    ) {
        self.authHelper = authHelper
        self.onComplete = onComplete
                        
        do {
            request = try API.AuthRequest(authConfiguration: .standard).asURLRequest()
        }
        catch {
            debugPrint(error)
        }
    }
    
    func onProgressValueUpdated(_ newValue: Double) {
        webViewProgress = shouldHideProgress(for: newValue) ? .idle : .onGoing(Float(newValue))
    }
    
    func onBackButton() {
        onComplete(.init(code: nil))
    }
    
    func isURLValid(_ url: URL) -> Bool {
        if let code = authHelper.code(from: url) {
            onComplete(.init(code: code))
            
            return true
        }
        else {
            return false
        }
    }
}

// MARK: - Private

private extension WebViewModel {
    func shouldHideProgress(for value: Double) -> Bool {
        (value - 0.745) >= 0.0
    }
}
