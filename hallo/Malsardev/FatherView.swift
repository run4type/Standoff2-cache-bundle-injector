//
//  ContentView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import SwiftUI

struct FatherView: View {
    @StateObject var userProfile: Profile
    
    
    init(){
        let initializer = Profile()
        _userProfile = StateObject(wrappedValue: initializer)
    }
    
    var body: some View {
        ZStack{
            Color(hex: "#141414").edgesIgnoringSafeArea(.all)
          
            VStack{
             
                if userProfile.subscribeType != subType.none{
                    MainView(userProfile: userProfile)
                }else{
                    AuthView(userProfile: userProfile)
                }
            }
        }
    }
}

