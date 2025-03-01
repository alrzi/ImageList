//
//  ProfileLogOutConfirmationError.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import Foundation

struct ProfileLogOutConfirmationError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let cancelButtonText: String
    let confirmationButtonText: String
    let onConfirm: () -> Void
}
