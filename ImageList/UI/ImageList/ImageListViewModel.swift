//
//  ImageListViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import Foundation

@MainActor
protocol ImageListViewModelProtocol: ObservableObject {
    var state: ViewModelState<[ImageListCellViewModel]> { get }
    var likeUpdateError: ErrorInfo? { get set }
    
    func onAppear()
    func onRetry()
    func onLikeTap(at index: Int)
    func onImageTap(at index: Int)
}

final class ImageListViewModel: ImageListViewModelProtocol {
    private let imageListProvider: ImageListProviding
    private let imageListService: ImageListServiceProtocol
    
    private let eventsHandler: (ImageListOutput) -> Void
    
    private var page: Int = 1
    private var isLikeUpdateInProgress = false
    
    @Published private(set) var state: ViewModelState<[ImageListCellViewModel]> = .loading
    @Published var likeUpdateError: ErrorInfo?
    
    init(
        imageListProvider: ImageListProviding,
        imageListService: ImageListServiceProtocol,
        eventsHandler: @escaping (ImageListOutput) -> Void
    ) {
        self.imageListProvider = imageListProvider
        self.imageListService = imageListService
        self.eventsHandler = eventsHandler
    }
    
    func onAppear() {
        guard !state.isLoaded else {
            return
        }
        
        Task {
            await updateList()
        }
    }
    
    func onLikeTap(at index: Int) {
        Task {
            await updateLike(for: index)
        }
    }
    
    func onImageTap(at index: Int) {
        guard case .loaded(var models) = state, let model = models.elementOrNil(at: index) else {
            return
        }
        
        do {
            eventsHandler(.onImageTap(try model.detailImageURL))
        }
        catch {
            debugPrint(error)
        }
    }
    
    func onRetry() {
        Task {
            await updateList()
        }
    }
}

// MARK: - Private

private extension ImageListViewModel {
    func updateList() async {
        state = .loading
        
        do {
            let fetchedImages = try await imageListProvider.fetchPhotosNextPage(page)
            
            page += 1
            
            let models = fetchedImages.map { photo, imageData in
                ImageListCellViewModel(
                    id: photo.id,
                    isLiked: photo.isLiked,
                    date: photo.createdAt,
                    imageSize: photo.size,
                    detailImageURLString: photo.urls.full,
                    image: imageData
                )
            }
            
            state = .loaded(models)
        }
        catch {
            state = .error
            debugPrint(error)
        }
    }
    
    func updateLike(for index: Int) async {
        guard
            !isLikeUpdateInProgress,
            case .loaded(var models) = state,
            let model = models.elementOrNil(at: index)
        else {
            return
        }
        
        isLikeUpdateInProgress = true
             
        do {
            let isLiked = try await imageListService.changeLike(photoId: model.id, isLiked: !model.isLiked)
            
            _ = models.remove(at: index)
            models.insert(model.withIsLiked(isLiked), at: index)
            
            state = .loaded(models)
            
            isLikeUpdateInProgress = false
        }
        catch {
            likeUpdateError = .init(
                title: "Не удалось обновить лайк",
                message: "Проверьте подключение к интернету",
                cancelButtonText: "",
                confirmationButtonText: "Ок",
                onConfirm: { }
            )
            debugPrint(error)
        }
    }
}
