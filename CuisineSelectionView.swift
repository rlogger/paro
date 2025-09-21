//
//  CuisineSelectionView.swift
//  eater
//

import SwiftUI

struct CuisineSelectionView: View {
    @State private var selectedCuisines: Set<String> = ["Water"] // Auto-select first element
    @State private var isOrderPressed = false
    @Environment(\.dismiss) private var dismiss
    
    let cuisines = ["Water", "Italian", "Thai", "Fries", "Indian", "Panda"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // All cuisine options
                VStack(spacing: 0) {
                    ForEach(cuisines, id: \.self) { cuisine in
                        Button(action: {
                            if selectedCuisines.contains(cuisine) {
                                selectedCuisines.remove(cuisine)
                            } else {
                                selectedCuisines.insert(cuisine)
                            }
                        }) {
                            Text(cuisine)
                                .font(.system(size: min(geometry.size.width * 0.12, 60), weight: .black))
                                .foregroundColor(selectedCuisines.contains(cuisine) ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height / 8)
                                .background(
                                    selectedCuisines.contains(cuisine) ? Color.black : Color.clear
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Order button
                Button(action: {
                    // Trigger animation
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isOrderPressed = true
                    }
                    
                    // Reset animation after short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isOrderPressed = false
                        }
                    }
                    
                    // API call here
                    if !selectedCuisines.isEmpty {
                        print("Making API call to order: \(Array(selectedCuisines))")
                        makeOrderAPICall(cuisines: Array(selectedCuisines))
                    }
                }) {
                    Text("Order")
                        .font(.system(size: min(geometry.size.width * 0.12, 60), weight: .black))
                        .foregroundColor(isOrderPressed ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height / 8)
                        .background(isOrderPressed ? Color.green : Color.clear)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
    
    private func makeOrderAPICall(cuisines: [String]) {
        // Implement your API call here
        // Example:
        /*
        let url = URL(string: "https://your-api-endpoint.com/order")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let orderData = ["cuisines": cuisines]
        request.httpBody = try? JSONSerialization.data(withJSONObject: orderData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle response
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                // Process response data
                print("Order placed successfully for \(cuisines)")
            }
        }.resume()
        */
        
        print("Order placed for \(cuisines)")
    }
}
