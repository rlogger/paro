//
//  WelcomeView.swift
//  eater
//

import SwiftUI

struct WelcomeView: View {
    @State private var showCuisineSelection = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // First Eater
                Text("Eater")
                    .font(.system(size: 80, weight: .black))
                    .foregroundColor(.black)
                    .padding(.top, 100)
                
                // Second Eater
                Text("Eater")
                    .font(.system(size: 80, weight: .black))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Third Eater
                Text("Eater")
                    .font(.system(size: 80, weight: .black))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                Spacer()
                
                // Small Carrot Symbol Button
                Button(action: {
                    showCuisineSelection = true
                }) {
                    Image(systemName: "carrot.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Fourth Eater
                Text("Eater")
                    .font(.system(size: 80, weight: .black))
                    .foregroundColor(.black)
                
                // Fifth Eater
                Text("Eater")
                    .font(.system(size: 80, weight: .black))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showCuisineSelection) {
                CuisineSelectionView()
            }
        }
    }
}
