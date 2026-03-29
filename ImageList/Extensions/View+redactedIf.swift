//
//  View+redactedIf.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import Foundation
import SwiftUI

extension View {
    func redacted(if condition: @autoclosure () -> Bool) -> some View {
        redacted(reason: condition() ? .placeholder : [])
    }
}
