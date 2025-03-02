//
//  ImageListAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import SwiftUI
import Foundation

final class ImageListAssembly {
    private let imageListProvider: ImageListProviding
    private let imageListService: ImageListServiceProtocol
    
    init(
        imageListProvider: ImageListProviding,
        imageListService: ImageListServiceProtocol
    ) {
        self.imageListProvider = imageListProvider
        self.imageListService = imageListService
    }
    
    @MainActor
    func assemble(_ context: ViewContext<(), ImageListOutput>) -> UIViewController {
        let viewModel = ImageListViewModel(
            imageListProvider: imageListProvider,
            imageListService: imageListService,
            eventsHandler: { context.output($0) }
        )
        
        let view = ImageListView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
