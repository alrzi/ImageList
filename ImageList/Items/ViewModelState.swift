//
//  ViewModelState.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

enum ViewModelState<Info> {
    case idle
    case loading
    case loaded(Info)
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
}

extension ViewModelState where Info: Collection {
    var lastElementIndex: Int {
        if case .loaded(let collection) = self {
            return collection.count - 1
        }
        else {
            return 0
        }
    }
}
