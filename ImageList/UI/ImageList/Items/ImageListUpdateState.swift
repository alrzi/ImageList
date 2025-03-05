//
//  ImageListUpdateState.swift
//  ImageList
//
//  Created by Александр Зиновьев on 04.03.2025.
//

import Foundation

enum ImageListUpdateState {
    case idle
    case pullToRefresh(LoadingState)
    case paginate(LoadingState)
    
    // Refresh
    
    var isRefreshing: Bool {
        switch self {
        case .idle, .paginate: false
        case .pullToRefresh(let loadingState): loadingState.isLoading
        }
    }
    
    var isRefreshingError: Bool {
        switch self {
        case .idle, .paginate: false
        case .pullToRefresh(let loadingState): loadingState.isError
        }
    }
    
    var refreshError: ErrorInfo? {
        switch self {
        case .idle, .pullToRefresh: nil
        case .paginate(let loadingState): loadingState.error
        }
    }
    
    // Pagination
    
    var isPaginating: Bool {
        switch self {
        case .idle, .pullToRefresh: false
        case .paginate(let loadingState): loadingState.isLoading
        }
    }
    
    var isPaginationError: Bool {
        switch self {
        case .idle, .pullToRefresh: false
        case .paginate(let loadingState): loadingState.isError
        }
    }
    
    var paginationError: ErrorInfo? {
        switch self {
        case .idle, .pullToRefresh: nil
        case .paginate(let loadingState): loadingState.error
        }
    }
}
