//
//  MainView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTab = 0
    @Namespace private var animation
    @StateObject var userProfile: Profile
    var body: some View {
        
        TabView(selection: $selectedTab) {
                  HomeView(userProfile: userProfile)
                      .tabItem {
                          Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                      }
                      .tag(0)
                      .transition(.scale.combined(with: .opacity))
                  
                MyModsView()
                      .tabItem {
                          Label("My mods", systemImage: selectedTab == 1 ? "archivebox.fill" : "archivebox")
                      }
                      .tag(1)
                      .transition(.slide.combined(with: .opacity))
                  
            SettingsView(userProfile: userProfile)
                      .tabItem {
                          Label("Settings", systemImage: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                      }
                      .tag(2)
                      .transition(.move(edge: .trailing).combined(with: .opacity))
              }
        .accentColor(Color(hex: "#ffffff"))
              .onAppear {
                  UITabBar.appearance().backgroundColor =  UIColor(Color(hex: "#222222"))
              }
            .onChange(of: selectedTab) { _ in
                          withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                              TapticEngine(volume: .light)
                          }
                      }
    }
}

