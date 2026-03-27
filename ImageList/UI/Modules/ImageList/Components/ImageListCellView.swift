//
//  ImageListCellView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation
import SwiftUI

struct ImageListCellView: View {
    let model: ImageListCellViewModel
    let onLikeTap: () -> Void
    
    var body: some View {
        model.image
            .resizable()
            .overlay(alignment: .bottom) {
                HStack {
                    Text(model.date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding([.horizontal, .bottom], 8)
                .padding(.top, 8)
                .background {
                    LinearGradient(
                        colors: [
                            Color(.myGradientStart),
                            Color(.myGradientStop)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .overlay(alignment: .topTrailing) {
                LikeButton(isLiked: model.isLiked, onTap: onLikeTap)
                    .animation(.easeInOut(duration: 0.5), value: model.isLiked)
            }
            .clipShape(.rect(cornerRadius: 16))
    }
}

private struct LikeButton: View {
    let isLiked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            if isLiked {
                Image(systemName: "heart")
                    .resizable()
                    .symbolVariant(.fill)
                    .foregroundStyle(.red)
                    .frame(width: 22, height: 18)
                    .padding()
                    .transition(.asymmetric(insertion: .scale(scale: 2), removal: .identity))
            }
            else {
                Image(systemName: "heart")
                    .resizable()
                    .symbolVariant(.none)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 22, height: 18)
                    .padding()
                    .transition(.identity)
            }
        }
    }
}

#Preview {
    let model = ImageListCellViewModel(
        imageId: "1",
        isLiked: true,
        date: .now,
        imageSize: .zero,
        detailImageURLString: "",
        imageData: .empty
    )
    
    if let model {
        ImageListCellView(model: model, onLikeTap: { })
    }
}
