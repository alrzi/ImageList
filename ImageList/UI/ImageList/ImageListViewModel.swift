//
//  ImageListViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.02.2025.
//

import Foundation

@MainActor
protocol ImageListViewModelProtocol: ObservableObject {
    var state: State<[ImageListCellViewModel]> { get }
    
    func onAppear()
    func onRetry()
    func onLikeTap(at index: Int)
    func onImageTap(at index: Int)
}

final class ImageListViewModel: ImageListViewModelProtocol {
    private let imageListProvider: ImageListProviding
    private let imageListService: ImageListServiceProtocol
    
    private var page: Int = 1
    private var isLikeUpdateInProgress = false
    
    @Published private(set) var state: State<[ImageListCellViewModel]> = .loading
    
    init(
        imageListProvider: ImageListProviding,
        imageListService: ImageListServiceProtocol
    ) {
        self.imageListProvider = imageListProvider
        self.imageListService = imageListService
    }
    
    func onAppear() {
        guard !state.isLoaded else {
            return
        }
        
        updateList()
    }
    
    func onLikeTap(at index: Int) {
        updateLike(for: index)
    }
    
    func onImageTap(at index: Int) {
        
    }
    
    func onRetry() {
        updateList()
    }
}

// MARK: - Private

private extension ImageListViewModel {
    func updateList() {
        Task { [weak self, imageListProvider] in
            guard let self else {
                return
            }
            
            do {
                let fetchedImages = try await imageListProvider.fetchPhotosNextPage(page)
                
                page += 1
                
                let models = fetchedImages.map { photo, imageData in
                    ImageListCellViewModel(
                        id: photo.id,
                        isLiked: photo.isLiked,
                        date: photo.createdAt,
                        imageSize: photo.size,
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
    }
    
    func updateLike(for index: Int) {
        Task { [weak self, imageListService] in
            guard
                let self,
                !isLikeUpdateInProgress,
                case .loaded(var models) = state,
                let model = models.elementOrNil(at: index)
            else {
                return
            }
            
            isLikeUpdateInProgress = true
                       
            let isLiked = try await imageListService.changeLike(photoId: model.id, isLiked: !model.isLiked)
            
            _ = models.remove(at: index)
            models.insert(model.withIsLiked(isLiked), at: index)
            
            state = .loaded(models)
            
            isLikeUpdateInProgress = false
        }
    }
}
