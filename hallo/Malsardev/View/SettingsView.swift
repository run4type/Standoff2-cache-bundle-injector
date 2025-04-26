//
//  SettingsView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//
import SwiftUI

struct SettingsView: View {
    @StateObject var userProfile: Profile
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
          
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#1e1e1e"), Color(hex: "#141414")]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
              
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.6), radius: 10, x: 0, y: 5)
                    
                    VStack(alignment: .leading) {
                        Text("Hello,")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(userProfile.username)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.8), value: isVisible)
                
              
                SettingsCard(title: "Subscription", icon: "crown.fill",
                             content: "Type: **\(subscriptionText)**", color: .yellow, isVisible: isVisible)
                
                SettingsCard(title: "Expiration Date", icon: "calendar",
                             content: "Expires on: **\(formattedExpirationDate)**", color: .orange, isVisible: isVisible)
                
             
                SettingsCardButton(title: "Reset Malsar", icon: "arrow.clockwise.circle.fill",
                                   action: {
                
                }, color: .red, isVisible: isVisible)
                
                Spacer()
                
            
                Button(action: {
               
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                                                   startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(color: .red.opacity(0.8), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 1.6), value: isVisible)
            }
            .padding()
        }
        .onAppear {
            isVisible = true
        }
    }
    
   
    private var subscriptionText: String {
        switch userProfile.subscribeType {
        case subType.full: return "Full"
        case subType.cache: return "Cache"
        case subType.bundles: return "Bundle"
        case subType.none: return "No subscription"
        }
    }
    
 
    private var formattedExpirationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: userProfile.subscribe)
    }
}


struct SettingsCard: View {
    var title: String
    var icon: String
    var content: String
    var color: Color
    var isVisible: Bool
    
    var body: some View {
        GroupBox(label: Label(title, systemImage: icon)
                    .foregroundColor(color)
                    .font(.headline)) {
            Text(content)
                .foregroundColor(.white)
                .padding(.top, 2)
        }
        .groupBoxStyle(GlassmorphismStyle())
        .padding(.horizontal)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 1.0), value: isVisible)
    }
}


struct SettingsCardButton: View {
    var title: String
    var icon: String
    var action: () -> Void
    var color: Color
    var isVisible: Bool
    
    var body: some View {
        GroupBox {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                    Text(title)
                }
                .font(.headline)
                .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .groupBoxStyle(GlassmorphismStyle())
        .padding(.horizontal)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 1.2), value: isVisible)
    }
}


struct GlassmorphismStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
            
            configuration.content
                .padding(.top, 2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .blur(radius: 5)
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
