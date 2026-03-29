//
//  Array+elementOrNil.swift
//  ImageList
//
//  Created by Александр Зиновьев on 14.02.2023.
//

import Foundation

extension Array {
    func elementOrNil(at index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }

        return self[index]
    }
}
