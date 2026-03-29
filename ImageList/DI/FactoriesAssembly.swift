//
//  FactoriesAssembly.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import Foundation
import ImageListDomain
import Swinject

final class FactoriesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ImageListCellViewModelFactory.self) { r in
            ImageListCellViewModelFactory(
                imageLoader: r.resolve(CachedImageLoaderProtocol.self)!
            )
        }
    }
}
