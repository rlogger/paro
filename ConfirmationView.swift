//
//  ConfirmationView.swift
//  eater
//

import SwiftUI

struct ConfirmationView: View {
    let selectedCuisines: [String]
    @Environment(\.dismiss) private var dismiss
    
    // Generate random confirmation code
    @State private var confirmationCode = String(Int.random(in: 100000...999999))
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                
                // Confirmation Code
                Text(confirmationCode)
                    .font(.system(size: min(geometry.size.width * 0.15, 80), weight: .black))
                    .foregroundColor(.black)
                    .padding(.top, geometry.size.height * 0.08)
                    .padding(.horizontal, 20)
                
                // Spacer
                Spacer()
                    .frame(height: geometry.size.height * 0.06)
                
                // Order Details
                VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                    
                    // Uber Eats
                    Text("Uber Eats")
                        .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                        .foregroundColor(.black)
                    
                    // Pad Thai Noodles
                    Text("Pad Thai Noodles")
                        .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                        .foregroundColor(.black)
                    
                    // Choice of Protein
                    Text("Choice of Protein: Vegetables")
                        .font(.system(size: min(geometry.size.width * 0.06, 30), weight: .medium))
                        .foregroundColor(.black)
                    
                    // Price
                    Text("Price $13.95")
                        .font(.system(size: min(geometry.size.width * 0.06, 30), weight: .medium))
                        .foregroundColor(.black)
                    
                }
                .padding(.horizontal, 20)
                
                // Spacer
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // After Uber Eats
                Text("After Uber Eats: $23.80")
                    .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                
                // Spacer
                Spacer()
                    .frame(height: geometry.size.height * 0.08)
                
                // Delivery Updates
                Text("Delivery updates will be sent over text")
                    .font(.system(size: min(geometry.size.width * 0.06, 30), weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                
                // Fill remaining space
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .background(Color.white)
    }
}
