//
//  WelcomeView.swift
//  paro
//

import SwiftUI

struct WelcomeView: View {
    @State private var showAuthentication = false
    @State private var showCuisineSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Text("Paro")
                        .font(.system(size: 80, weight: .black))
                        .padding(.top, 100)
                    Text("Paro")
                        .font(.system(size: 80, weight: .black))
                    Text("Paro")
                        .font(.system(size: 80, weight: .black))
                }

                Spacer()

                Button(action: handleCarrotButtonTap) {
                    Image(systemName: "carrot.fill")
                        .font(.system(size: 30))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Start ordering")

                Spacer()

                VStack(spacing: 20) {
                    Text("Paro")
                        .font(.system(size: 80, weight: .black))
                    Text("Paro")
                        .font(.system(size: 80, weight: .black))
                        .padding(.bottom, 100)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showAuthentication) {
                AuthenticationView { success in
                    if success {
                        showCuisineSelection = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showCuisineSelection) {
                CuisineSelectionView()
            }
        }
    }

    private func handleCarrotButtonTap() {
        if AuthService.shared.isAuthenticated() {
            showCuisineSelection = true
        } else {
            showAuthentication = true
        }
    }
}

#Preview {
    WelcomeView()
}
