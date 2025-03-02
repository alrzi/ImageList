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
            case .loading, .idle:
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
                            .onTapGesture(count: 2) { viewModel.onLikeTap(at: index) }
                            .onAppear { viewModel.onImageAppear(at: index) }
                        }
                        
                        if viewModel.paginationState.isLoading {
                            ProgressView()
                                .scaleEffect(2)
                                .tint(.white)
                                .padding(.vertical, 16)
                        }
                    }
                    .refreshable {
                        await viewModel.onRefresh()
                    }
                    .padding(.horizontal, paddingHorizontal)
                    .onAppear {
                        UIRefreshControl.appearance().tintColor = UIColor.white
                    }
                }
                
            case .error:
                ErrorView(onRetry: viewModel.onRetry)
            }
        }
        .alert(
            "Не удалось обновить лайк",
            isPresented: $viewModel.isLikeUpdateAlertPresented,
            presenting: viewModel.likeUpdateState.error,
            actions: { error in
                Button(action: { }) {
                    Text(error.confirmationButtonText)
                }
            },
            message: { error in
                Text(error.message)
            }
        )
        .alert(
            "Не удалось подгрузить еще картинок",
            isPresented: $viewModel.isPaginationAlertPresented,
            presenting: viewModel.paginationState.error,
            actions: { error in
                Button(action: { }) {
                    Text(error.confirmationButtonText)
                }
            },
            message: { error in
                Text(error.message)
            }
        )
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
    let state: ViewModelState<[ImageListCellViewModel]>
    let paginationState: LoadingState = .idle
    let likeUpdateState: LoadingState = .idle
    
    var isPaginationAlertPresented = false
    var isLikeUpdateAlertPresented = false
    
    init(state: ViewModelState<[ImageListCellViewModel]>) {
        self.state = state
    }
    
    func onAppear() { }
    func onRetry() { }
    func onRefresh() { }
    func onLikeTap(at index: Int) { }
    func onImageTap(at index: Int) { }
    func onImageAppear(at index: Int) { }
}
