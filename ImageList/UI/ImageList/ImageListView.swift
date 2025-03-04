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
                
            case .loaded(let models, let paginationState, _):
                if !models.isEmpty {
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
                            
                            if paginationState.isLoading {
                                ProgressView()
                                    .scaleEffect(2)
                                    .tint(.white)
                                    .padding(.vertical, 16)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.onRefresh()
                    }
                    .padding(.horizontal, paddingHorizontal)
                    .onAppear {
                        UIRefreshControl.appearance().tintColor = UIColor.white
                    }
                }
                else {
                    Text("Пока пусто")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.white)
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
            "Не удалось обновить список",
            isPresented: $viewModel.isRefreshAlertPresented,
            presenting: viewModel.state.refreshState?.error,
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
            presenting: viewModel.state.paginationState?.error,
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

#if DEBUG
#Preview {
    ImageListView(viewModel: ImageListViewModel(imageListManager: DebugImageListManager()) { _ in })
}
#endif
