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
                            Image(systemName: "heart")
                                .resizable()
                                .symbolVariant(model.isLiked ? .fill : .none)
                                .foregroundStyle(model.isLiked ? .red : .white.opacity(0.5))
                                .frame(width: 22, height: 18)
                                .padding()
                        }
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
            id: "1",
            isLiked: false,
            date: .now,
            imageSize: .init(width: 400, height: 300),
            image: .empty
        ),
        onLikeTap: { }
    )
}
