//
//  DetailImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.03.2023.
//

import Foundation
import ImageListDomain
import UIKit

@MainActor
protocol DetailImageListPresenterProtocol {
    var view: DetailImageListViewControllerProtocol? { get }

    func fetchImage()
}

final class DetailImageListPresenter: DetailImageListPresenterProtocol {
    weak var view: DetailImageListViewControllerProtocol?
    let url: URL
    private let imageLoader: CachedImageLoaderProtocol

    private var imageState: DetailImageState = .loading {
        didSet {
            configureImageState()
        }
    }

    init(url: URL, imageLoader: CachedImageLoaderProtocol) {
        self.url = url
        self.imageLoader = imageLoader
    }

    private func configureImageState() {
        switch imageState {
        case .loading:
            view?.startSpinner()

        case let .error(url):
            view?.stopSpinner()
            view?.showAlertAndMaybeTryAgainWith(url: url)

        case let .finished(image):
            view?.hideScribble()
            view?.stopSpinner()
            view?.didReceiveImage(image)
        }
    }
}

extension DetailImageListPresenter {
    func fetchImage() {
        imageState = .loading

        Task {
            do {
                let data = try await imageLoader.loadImage(from: url)
                try Task.checkCancellation()

                if let image = UIImage(data: data) {
                    imageState = .finished(image)
                }
                else {
                    imageState = .error(url)
                }
            }
            catch {
                imageState = .error(url)
            }
        }
    }
}

private enum DetailImageState {
    case loading
    case error(URL)
    case finished(UIImage)
}
