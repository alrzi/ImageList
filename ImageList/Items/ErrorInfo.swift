//
//  ErrorInfo.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

struct ErrorInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let cancelButtonText: String
    let confirmationButtonText: String
    let onConfirm: () -> Void
}
