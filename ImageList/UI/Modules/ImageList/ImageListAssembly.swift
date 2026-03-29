//
//  ImageListAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import ImageListDomain
import SwiftUI

final class ImageListAssembly {
    private let imageListViewModelFactory: ImageListViewModelFactoryProtocol

    init(imageListViewModelFactory: ImageListViewModelFactoryProtocol) {
        self.imageListViewModelFactory = imageListViewModelFactory
    }

    @MainActor
    func assemble(_ context: ViewContext<Void, ImageListOutput>) -> UIViewController {
        let viewModel = imageListViewModelFactory.makeImageListViewModel(
            imageListType: .all,
            eventsHandler: { context.output($0) }
        )

        let view = ImageListView(viewModel: viewModel)

        return UIHostingController(rootView: view)
    }
}
