//
//  ImageListAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import SwiftUI
import Foundation

final class ImageListAssembly {
    private let imageListManager: ImageListManaging
    
    init(imageListManager: ImageListManaging) {
        self.imageListManager = imageListManager
    }
    
    @MainActor
    func assemble(_ context: ViewContext<(), ImageListOutput>) -> UIViewController {
        let viewModel = ImageListViewModel(
            imageListManager: imageListManager,
            eventsHandler: { context.output($0) }
        )
        
        let view = ImageListView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
