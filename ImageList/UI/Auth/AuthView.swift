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
        switch viewModel.state {
        case .idle:
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
            }
            .background(.black)
            .onAppear(perform: viewModel.onAppear)
        
        case .loading:
            ProgressView()
                .tint(.black)
                .scaleEffect(2)
        }
    }
}

#if DEBUG
#Preview {
    AuthView(viewModel: ViewModel())
}

private final class ViewModel: AuthViewModelProtocol {
    let state: AuthViewState = .loading
    
    func onAppear() { }
    func onNext() { }
}
#endif
