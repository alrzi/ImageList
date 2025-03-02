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
                VStack(alignment: .leading, spacing: 8) {
                    ProfileTopView(
                        profileModel: model,
                        onLogOut: viewModel.onLogOut
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
            case .error:
                ErrorView(onRetry: viewModel.onRetry)
            }
        }
        .background(.black)
        .onAppear(perform: viewModel.onAppear)
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
    }
}

private struct ProfileTopView: View {
    let profileModel: ProfileModel
    let onLogOut: () -> Void
    
    var body: some View {
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
    }
}

#Preview("Error") {
    ProfileView(viewModel: ViewModel(state: .error))
}

#Preview("Loading") {
    ProfileView(viewModel: ViewModel(state: .loading))
}

private final class ViewModel: ProfileViewModelProtocol {
    let state: ViewModelState<ProfileModel>
    let logOutConfirmationError: ErrorInfo? = nil
    
    var isLogOutConfirmationErrorPresented = false
    
    init(state: ViewModelState<ProfileModel>) {
        self.state = state
    }
    
    func onAppear() { }
    func onRetry() { }
    func onLogOut() { }
    func onConfirmLogOut() { }
}
