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
    case loaded([ImageListCellViewModel], paginationState: LoadingState, refreshState: LoadingState)
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
        if case .loaded(let collection, _, _) = self {
            return collection.count - 1
        }
        else {
            return 0
        }
    }
    
    var paginationState: LoadingState? {
        switch self {
        case .idle, .loading, .error: nil
        case .loaded(_, let state, _): state
        }
    }
    
    var refreshState: LoadingState? {
        switch self {
        case .idle, .loading, .error: nil
        case .loaded(_, _, let state): state
        }
    }
}
