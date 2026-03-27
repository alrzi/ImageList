//
//  ImageListViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import Foundation
import ImageListDomain

@MainActor
protocol ImageListViewModelProtocol: ObservableObject {
    var state: ImageListState { get }
    var likeUpdateState: LoadingState { get }
    var updateState: ImageListUpdateState { get }
    var isPaginating: Bool { get }
    
    var isRefreshAlertPresented: Bool { get set }
    var isPaginationAlertPresented: Bool { get set }
    var isLikeUpdateAlertPresented: Bool { get set }
    
    func onAppear()
    func onRetry()
    func onRefresh()
    func onLikeTap(at index: Int)
    func onImageTap(at index: Int)
    func onImageAppear(at index: Int)
}

final class ImageListViewModel: ImageListViewModelProtocol {
    private let imageListManager: ImageListManaging
    private let imageListType: ImageListType
    private let eventsHandler: (ImageListOutput) -> Void
    
    private var fetchingRequestParams = FetchingRequestParams()
    
    @Published private(set) var state: ImageListState = .idle
    @Published private(set) var likeUpdateState: LoadingState = .idle
    @Published private(set) var updateState: ImageListUpdateState = .idle
    @Published private(set) var isPaginating = false
    
    @Published var isRefreshAlertPresented = false
    @Published var isPaginationAlertPresented = false
    @Published var isLikeUpdateAlertPresented = false
    
    init(
        imageListManager: ImageListManaging,
        imageListType: ImageListType,
        eventsHandler: @escaping (ImageListOutput) -> Void
    ) {
        self.imageListType = imageListType
        self.imageListManager = imageListManager
        self.eventsHandler = eventsHandler
        
        $updateState
            .compactMap { $0.isRefreshingError }
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .assign(to: &$isRefreshAlertPresented)
        
        $updateState
            .compactMap { $0.isPaginationError }
            .assign(to: &$isPaginationAlertPresented)
        
        $updateState
            .map { $0.isPaginating }
            .assign(to: &$isPaginating)
        
        $likeUpdateState
            .map { $0.isError }
            .assign(to: &$isLikeUpdateAlertPresented)
    }
    
    func onAppear() {
        Task {
            guard !state.isLoaded || imageListType.shouldRefreshOnAppearIfAlreadyLoaded else {
                return
            }
            
            await requestInitialSetOfItems()
        }
    }
    
    func onRefresh() {
        Task {
            await refreshList()
        }
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
            fetchingRequestParams.resetPage()
            
            let fetchedImages = try await imageListManager.fetchPhotosNextPage(fetchingRequestParams.page)
            
            fetchingRequestParams.incrementPage()
            
            let models = fetchedImages.compactMap { $0.toPhotoModel(with: $1) }
            
            state = .loaded(models)
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
        
        guard case .loaded(let currentModels) = state, !updateState.isPaginating else {
            return
        }
        
        updateState = .paginate(.loading)
        
        do {
            let fetchedImages = try await imageListManager.fetchPhotosNextPage(fetchingRequestParams.page)
            
            if fetchedImages.isEmpty {
                updateState = .paginate(.idle)
                
                return
            }
            
            fetchingRequestParams.incrementPage()
            
            let models = fetchedImages.compactMap { $0.toPhotoModel(with: $1) }
            
            updateState = .paginate(.idle)
            state = .loaded(currentModels + models)
        }
        catch {
            updateState = .paginate(.error(.paginationError))
            debugPrint(error)
        }
    }
    
    func refreshList() async {
        guard case .loaded = state, !updateState.isRefreshing else {
            return
        }
        
        updateState = .pullToRefresh(.loading)
        
        do {
            fetchingRequestParams.resetPage()
            
            let fetchedImages = try await imageListManager.fetchPhotosNextPage(fetchingRequestParams.page)
            
            fetchingRequestParams.incrementPage()
            
            let models = fetchedImages.compactMap { $0.toPhotoModel(with: $1) }
            
            updateState = .pullToRefresh(.idle)
            state = .loaded(models)
        }
        catch {
            updateState = .pullToRefresh(.error(.refreshError))
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
            let isLiked = try await imageListManager.changeLike(photoId: model.imageId, isLiked: !model.isLiked)
            
            switch imageListType {
            case .all:
                _ = models.remove(at: index)
                models.insert(model.withIsLiked(isLiked), at: index)
                state = .loaded(models)
                
            case .onlyFavorite:
                if !isLiked {
                    _ = models.remove(at: index)
                    state = .loaded(models)
                    
                    eventsHandler(.onLikeRemoved)
                }
            }
            
            likeUpdateState = .idle
        }
        catch {
            likeUpdateState = .error(.likeUpdateError)
            debugPrint(error)
        }
    }
}

private extension Photo {
    func toPhotoModel(with imageData: Data) -> ImageListCellViewModel? {
        ImageListCellViewModel(
            imageId: id,
            isLiked: isLiked,
            date: createdAt,
            imageSize: size,
            detailImageURLString: urls.full,
            imageData: imageData
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

private extension ImageListType {
    var shouldRefreshOnAppearIfAlreadyLoaded: Bool {
        switch self {
        case .all: false
        case .onlyFavorite: true
        }
    }
}
