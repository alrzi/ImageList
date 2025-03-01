//
//  ImageListView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import SwiftUI

@MainActor
struct ImageListView<ViewModel: ImageListViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    private var paddingHorizontal: CGFloat = 8
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension ImageListView: View {
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                AppProgressView()
                
            case .loaded(let models):
                GeometryReader { proxy in
                    ScrollableLazyVStack {
                        ForEach(Array(models.enumerated()), id: \.1.id) { index, model in
                            ImageListCellView(
                                model: model,
                                onLikeTap: { viewModel.onLikeTap(at: index) }
                            )
                            .frame(
                                width: model.imageSize(for: proxy.size.width, paddingHorizontal: paddingHorizontal).width,
                                height: model.imageSize(for: proxy.size.width, paddingHorizontal: paddingHorizontal).height
                            )
                            .onTapGesture { viewModel.onImageTap(at: index) }
                        }
                    }
                }
                
            case .error:
                ErrorView(onRetry: viewModel.onRetry)
            }
        }
        .padding(.horizontal, paddingHorizontal)
        .background(.black)
        .onAppear(perform: viewModel.onAppear)
    }
}

#Preview("Loading") {
    ImageListView(viewModel: ViewModel(state: .loading))
}

#Preview("Error") {
    ImageListView(viewModel: ViewModel(state: .error))
}

private final class ViewModel: ImageListViewModelProtocol {
    let state: State<[ImageListCellViewModel]>
    
    init(state: State<[ImageListCellViewModel]>) {
        self.state = state
    }
    
    func onAppear() { }
    func onRetry() { }
    func onLikeTap(at index: Int) { }
    func onImageTap(at index: Int) { }
}
