//
//  AuthView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.02.2025.
//

import SwiftUI
import Foundation

@MainActor
struct AuthView<ViewModel: AuthViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - View

extension AuthView: View {
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .idle:
                AppProgressView()
                
            case .loaded:
                VStack {
                    Spacer()
                    
                    Image(._05WelcomeScreen)
                    
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) {
                    Button(action: viewModel.onNext) {
                        Text("Войти")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                    .padding(.bottom, 16)
                }
                
            case .error:
                ErrorView(onRetry: viewModel.onRetry)
            }
        }
        .background(.black)
        .onAppear(perform: viewModel.onAppear)
    }
}

#if DEBUG
#Preview("Loading") {
    AuthView(viewModel: ViewModel(state: .loading))
}

#Preview("Loaded") {
    AuthView(viewModel: ViewModel(state: .loaded(())))
}

#Preview("Error") {
    AuthView(viewModel: ViewModel(state: .error))
}

private final class ViewModel: AuthViewModelProtocol {
    let state: ViewModelState<()>
    
    init(state: ViewModelState<()>) {
        self.state = state
    }
    
    func onAppear() { }
    func onNext() { }
    func onRetry() { }
}
#endif
