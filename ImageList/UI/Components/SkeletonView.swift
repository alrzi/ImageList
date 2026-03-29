//
//  SkeletonView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 19.09.2025.
//

import Foundation
import SwiftUI

struct SkeletonView<S: Shape>: View {
    var shape: S
    var color: Color = .gray.opacity(0.3)

    @State private var isAnimating = false
    @State private var hasAppeared = false

    var body: some View {
        shape
            .fill(color)
            .overlay {
                GeometryReader {
                    let size = $0.size
                    let skeletonWidth = size.width / 2
                    let blurRadius = max(skeletonWidth / 2, 30)
                    let blurDiameter = blurRadius * 2

                    let minX = -(skeletonWidth + blurDiameter)
                    let maxX = size.width + skeletonWidth + blurDiameter

                    Rectangle()
                        .fill(.gray)
                        .frame(width: skeletonWidth, height: size.height * 2)
                        .frame(height: size.height)
                        .blur(radius: blurRadius)
                        .rotationEffect(.degrees(rotation))
                        .blendMode(.lighten)
                        .offset(x: isAnimating ? maxX : minX)
                }
            }
            .clipShape(shape)
            .compositingGroup()
            .onAppear {
                guard !hasAppeared else {
                    return
                }
                hasAppeared = true

                withAnimation(animation) {
                    isAnimating = true
                }
            }
            .transaction {
                if $0.animation != animation {
                    $0.animation = .none
                }
            }
    }

    private var rotation: Double {
        5
    }

    private var animation: Animation {
        .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: false)
    }
}

#Preview {
    VStack {
        SkeletonView(shape: .rect(cornerRadius: 12))
            .frame(width: 300, height: 40, alignment: .leading)
    }
}
