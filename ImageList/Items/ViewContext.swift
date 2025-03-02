//
//  ViewContext.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import Foundation

struct ViewContext<InputType: Sendable, OutputType: Sendable>: Sendable {
    let input: InputType
    let output: @MainActor @Sendable (OutputType) -> Void
}

extension ViewContext where InputType == Void {
    init(output: @MainActor @Sendable @escaping (OutputType) -> Void) {
        self.input = ()
        self.output = output
    }
}

extension ViewContext where OutputType == Void, InputType == Void {
    init () {
        self.input = ()
        self.output = { _ in }
    }
}
