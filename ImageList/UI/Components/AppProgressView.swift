//
//  AppProgressView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import SwiftUI

struct AppProgressView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .scaleEffect(2)
                .tint(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AppProgressView()
        .background(.black)
}
