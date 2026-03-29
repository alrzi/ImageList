//
//  DetailImageAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 02.03.2025.
//

import Foundation
import ImageListDomain
import SwiftUI

final class DetailImageAssembly {
    private let imageLoader: CachedImageLoaderProtocol

    init(imageLoader: CachedImageLoaderProtocol) {
        self.imageLoader = imageLoader
    }

    @MainActor
    func assemble(_ context: ViewContext<DetailImageInput, Void>) -> UIViewController {
        let presenter = DetailImageListPresenter(
            url: context.input.url,
            imageLoader: imageLoader
        )

        let viewController = DetailImagesListViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }
}
