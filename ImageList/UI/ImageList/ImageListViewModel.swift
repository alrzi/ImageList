//
//  ImageListViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import Foundation

@MainActor
protocol ImageListViewModelProtocol: ObservableObject {
    var state: ImageListState { get }
    var likeUpdateState: LoadingState { get }
        
    var isRefreshAlertPresented: Bool { get set }
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
    private let imageListManager: ImageListManaging
    private let shouldRefreshOnAppear: Bool
    private let eventsHandler: (ImageListOutput) -> Void
    
    private var fetchingRequestParams = FetchingRequestParams(maxPerPage: 10)
    private var isLikeUpdateInProgress = false
        
    @Published private(set) var state: ImageListState = .idle
    @Published private(set) var likeUpdateState: LoadingState = .idle
    
    @Published var isRefreshAlertPresented = false
    @Published var isPaginationAlertPresented = false
    @Published var isLikeUpdateAlertPresented = false
    
    init(
        imageListManager: ImageListManaging,
        shouldRefreshOnAppear: Bool = false,
        eventsHandler: @escaping (ImageListOutput) -> Void
    ) {
        self.imageListManager = imageListManager
        self.shouldRefreshOnAppear = shouldRefreshOnAppear
        self.eventsHandler = eventsHandler
        
        $state
            .compactMap { $0.refreshState?.isError }
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .assign(to: &$isRefreshAlertPresented)
        
        $state
            .compactMap { $0.paginationState?.isError }
            .assign(to: &$isPaginationAlertPresented)
               
        $likeUpdateState
            .map { $0.isError }
            .assign(to: &$isLikeUpdateAlertPresented)
    }
    
    func onAppear() {
        Task {
            guard !state.isLoaded && shouldRefreshOnAppear else {
                return
            }
            
            await requestInitialSetOfItems()
        }
    }
    
    func onRefresh() async {
        await refreshList()
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
        guard case .loaded(let models, _, _) = state, let model = models.elementOrNil(at: index) else {
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
            await paginateMoreItemsIfNeeded(index: index)
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
            let fetchedImages = try await imageListManager.fetchPhotosNextPage(fetchingRequestParams)
            
            fetchingRequestParams.incrementPage()
            
            let models = fetchedImages.map { $0.toPhotoModel(with: $1) }
            
            state = .loaded(models, paginationState: .idle, refreshState: .idle)
        }
        catch {
            state = .error
            debugPrint(error)
        }
    }
    
    func paginateMoreItemsIfNeeded(index: Int) async {
        guard index == state.lastElementIndex else {
            return
        }
        
        guard case .loaded(let currentModels, let paginationState, _) = state, !paginationState.isLoading else {
            return
        }
                
        state = .loaded(currentModels, paginationState: .loading, refreshState: .idle)
        
        do {
            let fetchedImages = try await imageListManager.fetchPhotosNextPage(fetchingRequestParams)
            
            fetchingRequestParams.incrementPage()
            
            let models = fetchedImages.map { $0.toPhotoModel(with: $1) }
            
            state = .loaded(currentModels + models, paginationState: .idle, refreshState: .idle)
        }
        catch {
            state = .loaded(currentModels, paginationState: .error(.paginationError), refreshState: .idle)
            debugPrint(error)
        }
    }
    
    func refreshList() async {
        guard case .loaded(let currentModels, _, let refreshState) = state, !refreshState.isLoading else {
            return
        }
        
        state = .loaded(currentModels, paginationState: .idle, refreshState: .loading)
        
        do {
            fetchingRequestParams.resetPage()
            
            let fetchedImages = try await imageListManager.fetchPhotosNextPage(fetchingRequestParams)
            
            fetchingRequestParams.incrementPage()
            
            let models = fetchedImages.map { $0.toPhotoModel(with: $1) }
            
            state = .loaded(models, paginationState: .idle, refreshState: .idle)
        }
        catch {
            state = .loaded(currentModels, paginationState: .idle, refreshState: .error(.refreshError))
            debugPrint(error)
        }
    }
    
    func updateLike(for index: Int) async {
        guard !likeUpdateState.isLoading else {
            return
        }
           
        guard case .loaded(var models, _, _) = state, let model = models.elementOrNil(at: index) else {
            return
        }
        
        likeUpdateState = .loading
             
        do {
            let isLiked = try await imageListManager.changeLike(photoId: model.id, isLiked: !model.isLiked)
            
            _ = models.remove(at: index)
            models.insert(model.withIsLiked(isLiked), at: index)
            
            state = .loaded(models, paginationState: .idle, refreshState: .idle)
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
    
    static var refreshError: Self {
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
