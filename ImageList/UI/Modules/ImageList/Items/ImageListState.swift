//
//  ImageListState.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation

enum ImageListState {
    case idle
    case loading
    case loaded([ImageListCellViewModel])
    case error

    var isLoaded: Bool {
        switch self {
        case .loading, .error, .idle: false
        case .loaded: true
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading: true
        case .loaded, .error, .idle: false
        }
    }

    var lastElementIndex: Int {
        if case let .loaded(collection) = self {
            return collection.count - 1
        }
        else {
            return 0
        }
    }
}
