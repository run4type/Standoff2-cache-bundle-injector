//
//  HomeViewModel.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var caches: [Product] = []
    @Published var bundles: [Product] = []
    
    func fetchCaches() {
        guard let url = URL(string: "https://pastebin.com/raw/HKmXLcjZ") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
                    DispatchQueue.main.async {
                        self.caches = decodedProducts
                    }
                } catch {
                    print("Ошибка декодирования: \(error)")
                }
            }
        }.resume()
    }
    func fetchBundles() {
        guard let url = URL(string: "https://pastebin.com/raw/jgH87tRT") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
                    DispatchQueue.main.async {
                        self.bundles = decodedProducts
                    }
                } catch {
                    print("Ошибка декодирования: \(error)")
                }
            }
        }.resume()
    }
}
