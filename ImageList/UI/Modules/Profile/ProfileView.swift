//
//  ProfileView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2025.
//

import SwiftUI

@MainActor
struct ProfileView<ViewModel: ProfileViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension ProfileView: View {
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .idle:
                AppProgressView()
                
            case .loaded(let model):
                VStack {
                    ProfileTopView(
                        profileModel: model,
                        onLogOut: viewModel.onLogOut
                    )
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 0)
                    
                    if let viewModel = viewModel.imageListViewModel {
                        ImageListView(viewModel: viewModel)
                            .padding(.vertical, 8)
                        
                        Spacer(minLength: 0)
                    }
                }
                
            case .error:
                ErrorView(onRetry: viewModel.onRetry)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .alert(
            "Пока, пока!",
            isPresented: $viewModel.isLogOutConfirmationErrorPresented,
            presenting: viewModel.logOutConfirmationError,
            actions: { error in
                Button(error.confirmationButtonText, role: .destructive) {
                    error.onConfirm()
                }
               
                Button(error.cancelButtonText, role: .cancel) { }
            },
            message: { error in
                Text(error.message)
            }
        )
        .alert(
            "Не удалось актуализировать профайл, количество лайком может быть неверно!",
            isPresented: $viewModel.isAccountAccuracyErrorPresented,
            presenting: viewModel.accountAccuracyError,
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

private struct ProfileTopView: View {
    let profileModel: ProfileModel
    let onLogOut: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                if let image = profileModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .clipShape(.circle)
                }
                else {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .gray)
                }
                
                Spacer()
                
                Button(action: onLogOut) {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 22)
                        .foregroundStyle(.pink)
                        .padding(.vertical, 11)
                        .padding(.leading, 16)
                        .padding(.trailing, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(profileModel.name)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(profileModel.email)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.gray)
                
                Text(profileModel.greeting)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 12)
                        
            FavoriteView(likesNumber: profileModel.totalLikes.formatted())
        }
    }
    
    struct FavoriteView: View {
        let likesNumber: String
        
        var body: some View {
            HStack {
                Text("Избранное")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(likesNumber)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.blue, in: .capsule)
            }
        }
    }
}

#if DEBUG
#Preview("Error") {
    ProfileView(viewModel: ViewModel(state: .error))
}

#Preview("Loading") {
    ProfileView(viewModel: ViewModel(state: .loading))
}

#Preview("Loaded") {
    ProfileView(
        viewModel: ViewModel(
            state: .loaded(
                ProfileModel(
                    name: "Aleks",
                    email: "@gmail.com",
                    greeting: "Hello",
                    totalLikes: 20,
                    imageData: .empty
                )
            )
        )
    )
}

private final class ViewModel: ProfileViewModelProtocol {
    let state: ViewModelState<ProfileModel>
    let logOutConfirmationError: ErrorInfo? = nil
    let accountAccuracyError: ErrorInfo? = nil
    
    let imageListViewModel: ImageListViewModel? = ImageListViewModel(imageListManager: DebugImageListManager(), imageListType: .onlyFavorite) { _ in }
    
    var isLogOutConfirmationErrorPresented = false
    var isAccountAccuracyErrorPresented = false
    
    init(state: ViewModelState<ProfileModel>) {
        self.state = state
    }
    
    func onAppear() { }
    func onRetry() { }
    func onLogOut() { }
    func onConfirmLogOut() { }
}
#endif
