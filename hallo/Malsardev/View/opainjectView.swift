//
//  MyModsView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//


import SwiftUI

struct MyModsView: View {
    @State var tsutil = ObjcHelper()
    var body: some View {
        ZStack {
            Color(hex: "#141414").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill") 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                
                Text("Feature in Development")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("This feature is currently unavailable. We are working on it!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Button("external soon") {
                   /* Task {
                        do {
                            try RootHelper.setPermission(url: URL(fileURLWithPath: OpaInject.opainjectPath))
                            try RootHelper.setPermission(url: URL(fileURLWithPath: "/var/containers/Bundle/alert.dylib"))
                            OpaInject.log("Permissions set for opainject")
                          
                           
                            try OpaInject.injectDylibIntoTask(task_pid: 465)
                        } catch {
                            OpaInject.log("Error: \(error.localizedDescription)")
                        }
                    }
                    */
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .frame(width: 300)
            .background(Color(hex: "#222222"))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}
