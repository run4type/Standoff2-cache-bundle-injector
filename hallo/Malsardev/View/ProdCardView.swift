//
//  ProdCardView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    @Binding var selectedProduct: Product?
    var animation: Namespace.ID
    
    @State private var loadedImage: UIImage? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if let loadedImage = loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .frame(height: 200)
                    
                    .matchedGeometryEffect(id: product.id, in: animation)
            } else {
                ProgressView() 
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            
            Text(product.title)
                .font(.headline)
            
            Text(product.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(hex: "#222222"))
        .cornerRadius(12)
        .shadow(radius: 4)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                TapticEngine(volume: .medium)
                selectedProduct = product
                
            }
        }
        .onAppear {
            loadImage(from: product.imageUrl)
        }
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    loadedImage = image
                }
            }
        }.resume()
    }
}
