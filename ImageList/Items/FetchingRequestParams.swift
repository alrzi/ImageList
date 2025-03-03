//
//  FetchingRequestParams.swift
//  ImageList
//
//  Created by Александр Зиновьев on 03.03.2025.
//

import Foundation

struct FetchingRequestParams {
    let maxPerPage: Int
    private(set) var page: Int = 1
    
    init(maxPerPage: Int) {
        self.maxPerPage = maxPerPage
    }
    
    mutating func incrementPage() {
        page += 1
    }
    
    mutating func resetPage() {
        page = 1
    }
}
