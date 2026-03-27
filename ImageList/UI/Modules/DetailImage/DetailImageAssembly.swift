//
//  DetailImageAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 02.03.2025.
//

import SwiftUI
import Foundation

final class DetailImageAssembly {
    @MainActor
    func assemble(_ context: ViewContext<DetailImageInput, ()>) -> UIViewController {
        let presenter = DetailImageListPresenter(url: context.input.url)
        
        let viewController = DetailImagesListViewController(presenter: presenter)
        presenter.view = viewController
        
        return viewController
    }
}
