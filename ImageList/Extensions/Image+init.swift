//
//  Image+init.swift
//  ImageList
//
//  Created by Александр Зиновьев on 19.09.2025.
//

import Foundation
import UIKit
import SwiftUI

extension Image {
    init?(data: Data) {
        guard let image = UIImage(data: data) else {
            return nil
        }
        
        self = .init(uiImage: image)
    }
}
