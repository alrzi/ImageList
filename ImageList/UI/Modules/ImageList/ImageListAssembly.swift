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
    private let imageListManager: ImageListManaging
    private let factory: ImageListCellViewModelFactory

    init(
        imageListManager: ImageListManaging,
        factory: ImageListCellViewModelFactory
    ) {
        self.imageListManager = imageListManager
        self.factory = factory
    }

    @MainActor
    func assemble(_ context: ViewContext<Void, ImageListOutput>) -> UIViewController {
        let viewModel = ImageListViewModel(
            imageListManager: imageListManager,
            imageListType: .all,
            factory: factory,
            eventsHandler: { context.output($0) }
        )

        let view = ImageListView(viewModel: viewModel)

        return UIHostingController(rootView: view)
    }
}
