//
//  ImageListViewModelFactoryProtocol.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import ImageListDomain

protocol ImageListViewModelFactoryProtocol: Sendable {
    @MainActor
    func makeImageListViewModel(
        imageListType: ImageListType,
        eventsHandler: @escaping (ImageListOutput) -> Void
    ) -> ImageListViewModel
}
