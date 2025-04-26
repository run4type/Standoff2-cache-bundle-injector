//
//  HomeView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var isAnimating = false
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedProduct: Product? = nil
    @Namespace private var tabAnimation
    @Namespace private var productAnimation
    @StateObject var userProfile: Profile
    @State private var selectedTab = "Bundles"
    
    var filteredTabs: [String] {
        switch userProfile.subscribeType {
        case .bundles:
            return ["Bundles"]
        case .cache:
            return ["Caches"]
        case .full:
            return ["Bundles", "Caches"]
        case .none:
            return ["..."]
        }
    }
    
    var body: some View {
        ZStack {
          
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#1e1e1e"), Color(hex: "#141414")]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeInOut(duration: 0.8), value: isAnimating)
            
            VStack {
             
                Text("Malsar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.25 : 0.8)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)
                    .padding(.top, 10)
                
               
                if filteredTabs.count > 1 {
                    HStack(spacing: 20) {
                        ForEach(filteredTabs, id: \.self) { tab in
                            VStack(spacing: 4) {
                                Text(tab)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
                                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                                    .animation(.spring(), value: selectedTab)
                                
                                if selectedTab == tab {
                                    Rectangle()
                                        .frame(width: 60, height: 2)
                                        .foregroundColor(.white)
                                        .matchedGeometryEffect(id: "underline", in: tabAnimation)
                                } else {
                                    Rectangle()
                                        .frame(width: 60, height: 2)
                                        .foregroundColor(.clear)
                                }
                            }
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 10)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAnimating)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedTab = tab
                                    TapticEngine(volume: .rigid)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    
                
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.gray.opacity(0.7))
                        .padding(.vertical, 10)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: isAnimating)
                }
                
              
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        if filteredTabs.contains("Bundles") {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.bundles) { product in
                                        ProductCardView(
                                            product: product,
                                            selectedProduct: $selectedProduct,
                                            animation: tabAnimation
                                        )
                                        .padding(.horizontal)
                                        .scaleEffect(isAnimating ? 1 : 0.9)
                                        .opacity(isAnimating ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)
                                    }
                                }
                            }
                            .frame(width: geometry.size.width)
                            .blur(radius: selectedProduct == nil ? 0 : 20)
                            .animation(.easeInOut, value: selectedProduct)
                            .onAppear {
                                viewModel.fetchBundles()
                            }
                        }
                        
                        if filteredTabs.contains("Caches") {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.caches) { product in
                                        ProductCardView(
                                            product: product,
                                            selectedProduct: $selectedProduct,
                                            animation: tabAnimation
                                        )
                                        .padding(.horizontal)
                                        .scaleEffect(isAnimating ? 1 : 0.9)
                                        .opacity(isAnimating ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: isAnimating)
                                    }
                                }
                            }
                            .frame(width: geometry.size.width)
                            .onAppear {
                                viewModel.fetchCaches()
                            }
                        }
                    }
                    .offset(x: selectedTab == "Bundles" ? 0 : -geometry.size.width)
                    .animation(.spring(), value: selectedTab)
                }
            }
            
        
            if let product = selectedProduct {
                ExpandedProductView(
                    product: product,
                    selectedProduct: $selectedProduct,
                    animation: tabAnimation,
                    type: selectedTab
                )
                .zIndex(1)
            }
        }
        .onAppear {
            isAnimating = true
            if let firstTab = filteredTabs.first {
                selectedTab = firstTab
            }
        }
    }
}
