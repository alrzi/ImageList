//
//  CachedImageView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 29.03.2026.
//

import ImageListDomain
import SwiftUI

struct CachedImageView: View {
    let url: URL?
    let imageLoader: CachedImageLoaderProtocol
    let placeholder: Image

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
            }
            else if isLoading {
                SkeletonView(shape: .rect)
            }
            else {
                placeholder
            }
        }
        .task(id: url) {
            await loadImage()
        }
        .onDisappear {
            loadTask?.cancel()
        }
    }

    private func loadImage() async {
        guard let url else {
            return
        }

        image = nil
        isLoading = true

        loadTask = Task {
            do {
                let data = try await imageLoader.loadImage(from: url)
                try Task.checkCancellation()

                if let uiImage = UIImage(data: data) {
                    self.image = uiImage
                }
            }
            catch is CancellationError {
                // Отменено
            }
            catch {
                // Ошибка загрузки - остаётся placeholder
            }

            isLoading = false
        }

        await loadTask?.value
    }
}
