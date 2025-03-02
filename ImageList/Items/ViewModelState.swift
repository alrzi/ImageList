//
//  ViewModelState.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

enum ViewModelState<Info> {
    case loading
    case loaded(Info)
    case error
    
    var isLoaded: Bool {
        switch self {
        case .loading, .error: false
        case .loaded: true
        }
    }
}
