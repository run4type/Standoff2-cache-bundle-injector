//
//  AuthView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import SwiftUI
import Foundation

struct AuthView: View {
    @State private var login: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?
    @State private var circleOffset: CGFloat = -150
    @State private var circleScale: CGFloat = 1.2
    @State private var circleOpacity: Double = 0.3
    @State private var isButtonPressed: Bool = false
    @State private var finalAnimation: Bool = false
    @State private var typeToset:subType = .none
    @StateObject var userProfile: Profile
    enum Field {
        case login, password
    }
    
    var body: some View {
        ZStack {
         
            Color(hex: "#141414").edgesIgnoringSafeArea(.all)
            
       
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 300, height: 300)
                .scaleEffect(circleScale)
                .opacity(circleOpacity)
                .blur(radius: 40)
                .offset(x: 0, y: circleOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.5)) {
                        circleOffset = -50
                        circleScale = 1.5
                        circleOpacity = 0.4
                    }
                }
            
            
            VStack(spacing: 20) {
                Text("Welcome to Malsar!")
                    .font(.system(size: 25, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("Log in")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                
                VStack(spacing: 15) {
                    inputField(placeholder: "Enter login", text: $login, field: .login)
                        .onChange(of: login) { newValue in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                circleOffset = 50
                            }
                        }
                    
                    inputField(placeholder: "Enter password", text: $password, field: .password, isSecure: true)
                        .onChange(of: password) { newValue in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                circleOffset = 150
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                
               
                Button(action: {
                  
                    Task {
                    /*    let response = await auth(
                            ver: "1.0",
                            name: "...",
                            ownerid: "...",
                            username: login,
                            password: password,
                            hwid: UIDevice.current.identifierForVendor?.uuidString ?? "gey"
                        )
                     */
                        if true {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                finalAnimation = true
                                circleOffset = 400
                                circleOpacity = 0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    userProfile.subscribeType = subType.full
                                }
                            }
                        }
                        
                    }
                 
                    
                }) {
                    Rectangle()
                        .foregroundStyle(Color(hex: "#222222"))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .frame(width: 265, height: 60)
                        .scaleEffect(isButtonPressed ? 0.95 : 1)
                        .overlay(
                            Text("Enter")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                        )
                        .shadow(color: .white.opacity(0.2), radius: isButtonPressed ? 5 : 15)
                }
                .padding(.top, 30)
            }
            .offset(y: finalAnimation ? -100 : 0)
            .opacity(finalAnimation ? 0 : 1)
        }
    }
    
    

    func auth(ver: String, name: String, ownerid: String, username: String, password: String, hwid: String) async -> Bool {
        guard let url = URL(string: "https://keyauth.ru/api/1.2/?type=init&ver=\(ver)&name=\(name)&ownerid=\(ownerid)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return false
        }
        var dataSave: Data = Data()
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(KeyAuthResponse.self, from: data)
            
            print("Сессия ID: \(response.sessionid)")
            print("Версия: \(response.appinfo.version)")
            
            guard let url_end = URL(string:
                                    "https://keyauth.ru/api/1.2/?type=login&username=\(username)&pass=\(password)&sessionid=\(response.sessionid)&name=\(name)&ownerid=\(ownerid)&hwid=\(hwid)") else {
                showAlert(title: "Error", message: "Invalid URL")
                return false
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            let (data_end, _) = try await URLSession.shared.data(from: url_end)
            dataSave = data_end
            let loginResponse = try decoder.decode(LoginResponse.self, from: data_end)
            
            print("Ответ от сервера: \(loginResponse.message)")
            
            if loginResponse.success, let info = loginResponse.info {
                
               
                print("Успешный вход")
                print("Пользователь: \(info.username)")
                userProfile.username = info.username
                print("IP: \(info.ip)")
                print("HWID: \(info.hwid ?? "Не указан")")
                print("Дата создания аккаунта: \(info.createdate)")
                print("Последний вход: \(info.lastlogin)")
                
                for sub in info.subscriptions {
                    if sub.subscription == "bundle" {
                        typeToset = subType.bundles
                    } else if sub.subscription == "cache" {
                        typeToset = subType.cache
                    } else if sub.subscription == "full" {
                        typeToset = subType.full
                    }
                    
                    print("Подписка: \(sub.subscription)")
                    print("Истекает: \(sub.expiry)")
                    print("Оставшееся время: \(sub.timeleft) секунд")
                    
                    userProfile.subscribe = Date().addingTimeInterval(TimeInterval(sub.timeleft))
                }
                
                return true
            } else {
            
                showAlert(title: "Error", message: loginResponse.message)
                return false
            }
            
        } catch {
            let decoder = JSONDecoder()
            do {
                let errorResponse = try decoder.decode(errorResponse.self,from:dataSave)
                
                showAlert(title: "penis error", message: errorResponse.message)
                print("Ошибка: \(error.localizedDescription)")
                return false
            }catch{
                showAlert(title: "Error", message: "Unknown error")
                print("Ошибка: \(error.localizedDescription)")
                return false
            }
        }
    }

  
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            window.rootViewController?.present(alert, animated: true)
        }
    }

    

    @ViewBuilder
    private func inputField(placeholder: String, text: Binding<String>, field: Field, isSecure: Bool = false) -> some View {
        let isFocused = focusedField == field
        
        Rectangle()
            .foregroundStyle(Color(hex: "#222222"))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(width: 265, height: 60)
            .scaleEffect(isFocused ? 1.05 : 1)
            .overlay(
                ZStack(alignment: .leading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.white)
                            .opacity(0.6)
                            .padding(.leading, 10)
                            .font(.system(size: 16))
                            .transition(.opacity)
                    }
                    if isSecure {
                        SecureField("", text: text)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .font(.system(size: 16))
                            .focused($focusedField, equals: field)
                    } else {
                        TextField("", text: text)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .font(.system(size: 16))
                            .focused($focusedField, equals: field)
                    }
                }
                .padding()
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isFocused)
    }
}

