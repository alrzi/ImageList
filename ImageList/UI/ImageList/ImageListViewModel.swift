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
    var paginationState: LoadingState { get }
    var likeUpdateState: LoadingState { get }
    
    var isPaginationAlertPresented: Bool { get set }
    var isLikeUpdateAlertPresented: Bool { get set }
    
    func onAppear()
    func onRetry()
    func onRefresh() async
    func onLikeTap(at index: Int)
    func onImageTap(at index: Int)
    func onImageAppear(at index: Int)
}

final class ImageListViewModel: ImageListViewModelProtocol {
    private let imageListProvider: ImageListProviding
    private let imageListService: ImageListServiceProtocol
    
    private let eventsHandler: (ImageListOutput) -> Void
    
    private var page: Int = 1
    private var isLikeUpdateInProgress = false
        
    @Published private(set) var state: ViewModelState<[ImageListCellViewModel]> = .idle
    @Published private(set) var paginationState: LoadingState = .idle
    @Published private(set) var likeUpdateState: LoadingState = .idle
    
    @Published var isPaginationAlertPresented = false
    @Published var isLikeUpdateAlertPresented = false
    
    init(
        imageListProvider: ImageListProviding,
        imageListService: ImageListServiceProtocol,
        eventsHandler: @escaping (ImageListOutput) -> Void
    ) {
        self.imageListProvider = imageListProvider
        self.imageListService = imageListService
        self.eventsHandler = eventsHandler
        
        $paginationState
            .map { $0.isError }
            .assign(to: &$isPaginationAlertPresented)
        
        $likeUpdateState
            .map { $0.isError }
            .assign(to: &$isLikeUpdateAlertPresented)
    }
    
    func onAppear() {
        Task {
            guard !state.isLoaded else {
                return
            }
            
            await requestInitialSetOfItems()
        }
    }
    
    func onRefresh() async {
        await requestInitialSetOfItems()
    }
    
    func onRetry() {
        Task {
            await requestInitialSetOfItems()
        }
    }
    
    func onLikeTap(at index: Int) {
        Task {
            await updateLike(for: index)
        }
    }
    
    func onImageTap(at index: Int) {
        guard case .loaded(let models) = state, let model = models.elementOrNil(at: index) else {
            return
        }
        
        do {
            eventsHandler(.onImageTap(try model.detailImageURL))
        }
        catch {
            debugPrint(error)
        }
    }
    
    func onImageAppear(at index: Int) {
        Task {
            await requestMoreItemsIfNeeded(index: index)
        }
    }
}

// MARK: - Private

private extension ImageListViewModel {
    func requestInitialSetOfItems() async {
        guard !state.isLoading else {
            return
        }
        
        state = .loading
        
        do {
            let fetchedImages = try await imageListProvider.fetchPhotosNextPage(page)
            
            page += 1
            
            let models = fetchedImages.map { $0.toPhotoModel(with: $1) }
            
            state = .loaded(models)
        }
        catch {
            state = .error
            debugPrint(error)
        }
    }
    
    func requestMoreItemsIfNeeded(index: Int) async {
        guard index == state.lastElementIndex else {
            return
        }
        
        guard case .loaded(let currentModels) = state else {
            return
        }
        
        guard !paginationState.isLoading else {
            return
        }
                
        paginationState = .loading
        
        do {
            let fetchedImages = try await imageListProvider.fetchPhotosNextPage(page)
            
            page += 1
            
            let models = fetchedImages.map { $0.toPhotoModel(with: $1) }
            
            state = .loaded(currentModels + models)
        }
        catch {
            paginationState = .error(.paginationError)
            debugPrint(error)
        }
    }
    
    func updateLike(for index: Int) async {
        guard !likeUpdateState.isLoading else {
            return
        }
           
        guard case .loaded(var models) = state, let model = models.elementOrNil(at: index) else {
            return
        }
        
        likeUpdateState = .loading
             
        do {
            let isLiked = try await imageListService.changeLike(photoId: model.id, isLiked: !model.isLiked)
            
            _ = models.remove(at: index)
            models.insert(model.withIsLiked(isLiked), at: index)
            
            state = .loaded(models)
            likeUpdateState = .idle
        }
        catch {
            likeUpdateState = .error(.likeUpdateError)
            debugPrint(error)
        }
    }
}

private extension Photo {
    func toPhotoModel(with imageData: Data) -> ImageListCellViewModel {
        ImageListCellViewModel(
            id: id,
            isLiked: isLiked,
            date: createdAt,
            imageSize: size,
            detailImageURLString: urls.full,
            image: imageData
        )
    }
}

private extension ErrorInfo {
    static var likeUpdateError: Self {
        .init(
            message: "Мы проверим что случилось, отдохните чуть-чуть и попробуйте еще раз",
            cancelButtonText: "",
            confirmationButtonText: "Ок",
            onConfirm: { }
        )
    }
    
    static var paginationError: Self {
        .init(
            message: "Мы проверим что случилось, отдохните чуть-чуть и попробуйте еще раз",
            cancelButtonText: "",
            confirmationButtonText: "Ок",
            onConfirm: { }
        )
    }
}
