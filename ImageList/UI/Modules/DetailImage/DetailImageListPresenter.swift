//
//  DetailImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.03.2023.
//

import Foundation
import UIKit
import Kingfisher

@MainActor
protocol DetailImageListPresenterProtocol {
    var view: DetailImageListViewControllerProtocol? { get }
    
    func fetchImage()
}

private enum DetailImageState {
    case loading
    case error(URL)
    case finished(UIImage)
}

@MainActor
final class DetailImageListPresenter {
    weak var view: DetailImageListViewControllerProtocol?
    let url: URL
    
    private var imageState: DetailImageState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    init(url: URL) {
        self.url = url
    }

    private func configureImageState() {
        switch imageState {
        case .loading:
            view?.startSpinner()
        
        case .error(let url):
            view?.stopSpinner()
            view?.showAlertAndMaybeTryAgainWith(url: url)
        
        case .finished(let image):
            view?.hideScribble()
            view?.stopSpinner()
            view?.didReceiveImage(image)
        }
    }
}

extension DetailImageListPresenter: DetailImageListPresenterProtocol {
    func fetchImage() {
        imageState = .loading
        
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            Task { @MainActor in
                self?.updateState(result: result)
            }
        }
    }

    func updateState(result: Result<RetrieveImageResult, KingfisherError>) {
        switch result {
        case .success(let result):
            imageState = .finished(result.image)

        case .failure:
            imageState = .error(url)
        }
    }
}
