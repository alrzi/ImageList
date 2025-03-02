//
//  DetailImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.03.2023.
//

import Foundation
import Kingfisher
import UIKit

protocol DetailImageListPresenterProtocol {
    var view: DetailImageListViewControllerProtocol? { get }
    
    func fetchImage()
}

private enum DetailImageState {
    case loading
    case error(URL)
    case finished(UIImage)
}

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
            guard let self else {
                return
            }
            
            switch result {
            case .success(let result):
                imageState = .finished(result.image)
            
            case .failure:
                imageState = .error(url)
            }
        }
    }
}
