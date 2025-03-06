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
        Group {
            if let image = UIImage(data: model.image) {
                Image(uiImage: image)
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
                                    Color(uiColor: UIColor.myGradientStart),
                                    Color(uiColor: UIColor.myGradientStop)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        Button(action: onLikeTap) {
                            if model.isLiked {
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
                        .animation(.easeInOut(duration: 0.5), value: model.isLiked)
                    }
            }
            else {
                RoundedRectangle(cornerRadius: 12)
            }
        }
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    ImageListCellView(
        model: .init(
            imageId: "1",
            isLiked: false,
            date: .now,
            imageSize: .init(width: 400, height: 300),
            detailImageURLString: "",
            image: .empty
        ),
        onLikeTap: { }
    )
}
