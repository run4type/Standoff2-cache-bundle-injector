//
//  ExpandedProdView.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//


import SwiftUI
import Foundation
import UIKit
import BackgroundTasks
struct ExpandedProductView: View {
    let product: Product
    @Binding var selectedProduct: Product?
    var animation: Namespace.ID
    @State var type: String
    @State var ejection: Bool = false
    @State var isStepOne: Bool = false
    @State private var fileExists = false
    @State private var loadedImage: UIImage?
    @State private var downloadProgress: Double = 0.0
    @State private var isDownloading = false
    @State private var fileName: String = ""
    @State private var fileUrl: String = ""
    @State private var session: URLSession?
    @State private var downloadTask: URLSessionDownloadTask?
    let applicationIdentifier = "com.axlebolt.standoff2"
    
   
    
    
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { closeView() }
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: closeView) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                
                if let loadedImage = loadedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(height: 250)
                        .shadow(radius: 10)
                        .onAppear {
                            loadImage(from: product.imageUrl)
                            checkFileExists()
                        }
                } else {
                    ProgressView()
                        .frame(height: 250)
                        .onAppear {
                            loadImage(from: product.imageUrl)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                
                                checkFileExists()
                            }
                        }
                }
                
                Text(product.title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                   
                
                Text(product.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                    Button(action: handleAction) {
                        Text(ejectAction() ? "eject" : checkFileExists() ? (isStepOne ? "finish" : "inject") : (isDownloading ? "Cancel" : "Download"))
                            .bold()
                            .padding(10)
                            .frame(maxWidth: UIScreen.main.bounds.width / 2.5)
                            .background(ejectAction() ? Color.red : fileExists ?  Color.green : Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                
                
                
                if isDownloading {
                    VStack {
                        ProgressView(value: downloadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal, 20)
                        
                        Text("\(Int(downloadProgress * 100))%")
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: 350, maxHeight: UIScreen.main.bounds.height / 1.45)
            .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
            .cornerRadius(30)
        }
    }
    
    // MARK: - Actions
    
    func closeView() {
        withAnimation(.spring()) {
            selectedProduct = nil
          
        }
    }
    
    func logToFile(_ message: String) {
        let logFileURL = URL(fileURLWithPath: "/var/mobile/penisware.txt")
        let timestamp = Date().description(with: .current)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logMessage.data(using: .utf8)!)
                fileHandle.closeFile()
            }
        } else {
            try? logMessage.write(to: logFileURL, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Main action

    func handleAction() {
        fileName = product.filename
        TapticEngine(volume: .heavy)
        logToFile("handleAction triggered. File exists: \(fileExists), Type: \(type), isDownloading: \(isDownloading)")
        if ejectAction(){
            eject()
            return
        }else{
            if fileExists {
                logToFile("Inject action for file: \(getFilePath())")
                
                if type == "Cache" {
                    if !isStepOne {
                        injectCache_step_one()
                        isStepOne = true
                        logToFile("Injected cache step one completed.")
                    } else {
                        injectCache_step_two()
                        logToFile("Injected cache step two completed.")
                    }
                }
                if type == "Bundles" {
                    injectBundle()
                    logToFile("Injected bundle completed.")
                }
            } else {
                if isDownloading {
                    cancelDownload()
                    logToFile("Download canceled.")
                } else {
                    fileUrl = product.productUrl
                    fileName = product.filename
                    startDownload(from: fileUrl)
                    logToFile("Download started from URL: \(fileUrl)")
                }
            }
        }
   
    }

    // MARK: - File Management
    func eject(){
        var typecard = type == "Bundles" ? "bundle" : "unity"
        logToFile("typecard = \(typecard)")
        let fm = FileManager.default
        if typecard == "bundle"{
            let bundlePath = getBundlePath()
            let backupPath = URL(fileURLWithPath: "/var/mobile/bundle_\(product.filename).bundle")
            let antipath = URL(fileURLWithPath: "/var/mobile/\(product.filename).bundle")
            do{
                try RootHelper.move(from: bundlePath, to: antipath)
                try RootHelper.move(from:backupPath , to: bundlePath)
                
            }catch{
                logToFile("ejection error")
            }
        }
    }
    func injectCache_step_one() {
        let cachepath = getCachePath()
        let filePath = getFilePath()
        let backupPath = URL(fileURLWithPath: "/var/mobile/unity_\(fileName).unity")
        
        logToFile("Cache step one: starting...")

        do {
            logToFile("Moving cache from \(cachepath.path) to backup at \(backupPath.path)")
            try RootHelper.move(from: cachepath, to: backupPath)
            
            logToFile("Moving file from \(filePath) to cache at \(cachepath.path)")
            try RootHelper.move(from: URL(fileURLWithPath: filePath), to: cachepath)
            
            logToFile("Cache step one completed: files moved successfully.")
        } catch {
            logToFile("Cache step one error: \(error.localizedDescription)")
        }
    }

    func injectCache_step_two() {
        let cachepath = getCachePath()
        let filePath = getFilePath()
        let backupPath = URL(fileURLWithPath: "/var/mobile/unity_\(fileName).unity")
        
        logToFile("Cache step two: starting...")

        do {
            logToFile("Restoring cache from \(cachepath.path) to \(filePath)")
            try RootHelper.move(from: cachepath, to: URL(fileURLWithPath: filePath))
            
            logToFile("Restoring backup from \(backupPath.path) to cache at \(cachepath.path)")
            try RootHelper.move(from: backupPath, to: cachepath)
            
            logToFile("Cache step two completed: files restored successfully.")
        } catch {
            logToFile("Cache step two error: \(error.localizedDescription)")
        }
    }

    func injectBundle() {
        let bundlePath = getBundlePath()
        let filePath = getFilePath()
        let backupPath = URL(fileURLWithPath: "/var/mobile/bundle_\(fileName).bundle")
        
        logToFile("Bundle injection: starting...")
       
        do {
           
            logToFile("Backing up bundle from \(bundlePath.path) to \(backupPath.path)")
            try RootHelper.move(from: bundlePath, to: backupPath)
            
            logToFile("Injecting new bundle from \(filePath) to \(bundlePath.path)")
            try RootHelper.move(from: URL(fileURLWithPath: filePath), to: bundlePath)
            
            logToFile("Bundle injection completed: bundle injected successfully.")
        } catch {
            logToFile("Bundle injection error: \(error.localizedDescription)")
        }
    }

    // MARK: - Paths

    func getCachePath() -> URL {
        let apps = LSApplicationWorkspace.default().allApplications()!
        return apps.first { $0.applicationIdentifier == applicationIdentifier }!
            .bundleURL
            .appendingPathComponent("Data")
            .appendingPathComponent("data.unity3d")
    }

    func getBundlePath() -> URL {
        let apps = LSApplicationWorkspace.default().allApplications()!
        return apps.first { $0.applicationIdentifier == applicationIdentifier }!
            .bundleURL
            .appendingPathComponent("Data")
            .appendingPathComponent("Raw")
            .appendingPathComponent("DLC")
            .appendingPathComponent("BuiltInCollections")
            .appendingPathComponent("builtincollections_definitions.bundle")
    }

    func getFilePath() -> String {
        "/var/mobile/\(product.filename).\(type == "Bundles" ? "bundle" : "unity")"
    }
    func ejectAction() -> Bool{
        if FileManager.default.fileExists(atPath: "/var/mobile/bundle_\(product.filename).\(type == "Bundles" ? "bundle" : "unity")"){
            ejection = true
          return true
        }else{
           return false
        }
     
    }

    func checkFileExists() -> Bool {
        
       
        
       
        let destinationURL = URL(fileURLWithPath: getFilePath())
        do {
           
            fileExists = FileManager.default.fileExists(atPath: destinationURL.path)
            if fileExists {
                
                logToFile("FIND\(getFilePath())")
            return true
            }else{
                logToFile("FILENAME:\(product.filename)")
                logToFile("NOTFIND\(getFilePath())")
                return false
            }
           
        }
    }
   
    func saveFile(from location: URL) {
        let destinationURL = URL(fileURLWithPath: getFilePath())
        let fileManager = FileManager.default
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
                logToFile("ALL INCLUDE")
            }
            
            try fileManager.copyItem(at: location, to: destinationURL)
            print("✅ File saved to: \(destinationURL.path)")
            logToFile("✅ File saved to ")
           
            checkFileExists()
        } catch {
            print("❌ Error saving file: \(error.localizedDescription)")
        }
        
        isDownloading = false
    }
    
    // MARK: - Download Logic
    
    func startDownload(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        isDownloading = true
        downloadProgress = 0.0
        
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: DownloadDelegate(onProgress: { progress in
            DispatchQueue.main.async {
                self.downloadProgress = progress
            }
        }, onComplete: { location in
            saveFile(from: location)
        }), delegateQueue: nil)
        
        downloadTask = session?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
        downloadProgress = 0.0
        print("🚫 Download cancelled")
    }
    
    // MARK: - Image Loading
    
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

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    var onProgress: (Double) -> Void
    var onComplete: (URL) -> Void
    
    init(onProgress: @escaping (Double) -> Void, onComplete: @escaping (URL) -> Void) {
        self.onProgress = onProgress
        self.onComplete = onComplete
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        onProgress(progress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        onComplete(location)
    }
}
