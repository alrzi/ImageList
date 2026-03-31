//
//  ImageListView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import SwiftUI
import ImageListDomain

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
                SkeletonModelsView()

            case let .loaded(models):
                if models.isEmpty {
                    Text("Пока пусто")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.white)
                }
                else {
                    GeometryReader { proxy in
                        ScrollableLazyVStack {
                            ForEach(Array(models.enumerated()), id: \.1.id) { index, model in
                                ImageListCellView(
                                    model: model,
                                    onLikeTap: { viewModel.onLikeTap(at: index) }
                                )
                                .frame(
                                    width: model.imageSize(for: proxy.width, paddingHorizontal: paddingHorizontal)
                                        .width,
                                    height: model.imageSize(for: proxy.width, paddingHorizontal: paddingHorizontal)
                                        .height
                                )
                                .onTapGesture { viewModel.onImageTap(at: index) }
                                .onTapGesture(count: 2) { viewModel.onLikeTap(at: index) }
                                .onAppear { viewModel.onImageAppear(at: index) }
                            }

                            if viewModel.isPaginating {
                                ProgressView()
                                    .scaleEffect(2)
                                    .tint(.white)
                                    .padding(.vertical, 16)
                                    .transition(.opacity)
                            }
                        }
                        .scrollDisabled(models.isEmpty)
                    }
                    .refreshable {
                        viewModel.onRefresh()
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
                Button(action: {}) {
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
            presenting: viewModel.updateState.refreshError,
            actions: { error in
                Button(action: {}) {
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
            presenting: viewModel.updateState.paginationError,
            actions: { error in
                Button(action: {}) {
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

private struct SkeletonModelsView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { _ in
                SkeletonView(shape: .rect(cornerRadius: 12))
                    .frame(height: 200)
            }
            .padding(.horizontal, 16)
        }
        .scrollDisabled(true)
    }
}

#if DEBUG
    #Preview {
        ImageListView(viewModel: makeImageListViewModelDebug())
    }
#endif
