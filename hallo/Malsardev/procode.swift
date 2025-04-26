//
//  procode.swift
//  Malsardev
//
//  Created by David I on 12.03.2025.
//

import Foundation
import UIKit

struct Product: Identifiable, Equatable, Decodable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: String
    let productUrl: String
    let filename: String
}

enum subType {
    case none
    case cache
    case bundles
    case full
}


class Profile : ObservableObject {
    @Published var username: String
    @Published var subscribe: Date
    @Published var subscribeType: subType
    init() {
        self.username = "none"
        self.subscribe = Date.now
        self.subscribeType = subType.none
    }
}


func TapticEngine(volume: UIImpactFeedbackGenerator.FeedbackStyle){
    let generator = UIImpactFeedbackGenerator(style: volume)
    generator.impactOccurred()
}

class RootHelper {
    static let rootHelperPath = Bundle.main.url(forAuxiliaryExecutable: "MalsarPlugin")?.path ?? "/"
   
    static func writeStr(_ str: String, to url: URL) throws  {
        let code = spawnRoot(rootHelperPath, ["writedata", str, url.path], nil, nil)
        guard code == 0 else {  throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func move(from sourceURL: URL, to destURL: URL) throws {
        let code = spawnRoot(rootHelperPath, ["filemove", sourceURL.path, destURL.path], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func copy(from sourceURL: URL, to destURL: URL) throws {
        let code = spawnRoot(rootHelperPath, ["filecopy", sourceURL.path, destURL.path], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func createDirectory(at url: URL) throws {
        let code = spawnRoot(rootHelperPath,  ["makedirectory", url.path, ""], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func removeItem(at url: URL) throws  {
        let code = spawnRoot(rootHelperPath, ["removeitem", url.path, ""], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func setPermission(url: URL) throws {
        let code = spawnRoot(rootHelperPath, ["permissionset", url.path, ""], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func rebuildIconCache() throws {
        let code = spawnRoot(rootHelperPath, ["rebuildiconcache", "", ""], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
    static func loadMCM() throws {
        let code = spawnRoot(rootHelperPath, ["", "", ""], nil, nil)
        guard code == 0 else { throw NSError(domain: "errror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"]) }
    }
}
class OpaInject {
    static let opainjectPath = Bundle.main.url(forAuxiliaryExecutable: "opainject")?.path ?? "/"
    static let logPath = "/var/mobile/opainject_log.txt"

    static func log(_ message: String) {
        let logMessage = "\(Date()): \(message)\n"
        let logURL = URL(fileURLWithPath: logPath)

        if let handle = try? FileHandle(forWritingTo: logURL) {
            handle.seekToEndOfFile()
            handle.write(logMessage.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? logMessage.write(to: logURL, atomically: true, encoding: .utf8)
        }
    }

    static func injectDylibIntoTask(task_pid: pid_t) throws {
        log("Starting injection into PID: \(task_pid)")
        log("opainjectPath: \(opainjectPath)")

        let fileExists = FileManager.default.fileExists(atPath: opainjectPath)
        log("opainject exists: \(fileExists)")

        let dylibExists = FileManager.default.fileExists(atPath: "/var/containers/Bundle/alert.dylib")
        log("alert.dylib exists: \(dylibExists)")

        var output: String? = nil
        var errorOutput: String? = nil

        let code = spawnRoot(opainjectPath, ["\(task_pid)", "/var/containers/Bundle/alert.dylib", ""], nil, nil)
        log("spawnRoot exit code: \(code)")

        let fullOutput = "Exit Code: \(code)\nStandard Output:\n\(output ?? "")\nError Output:\n\(errorOutput ?? "")"
        try fullOutput.write(toFile: "/var/mobile/output.txt", atomically: true, encoding: .utf8)

        guard code == 0 else {
            log("Injection failed with code \(code)")
            throw NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Helper.writedata: returned non-zero code \(code)"])
        }

        log("Injection successful")
    }
}
struct KeyAuthResponse: Codable {
    let success: Bool
    let message: String
    let sessionid: String
    let appinfo: AppInfo
    let nonce: String
}

struct AppInfo: Codable {
    let numUsers: String
    let numOnlineUsers: String
    let numKeys: String
    let version: String
    let customerPanelLink: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let info: UserInfo?
    let nonce: String
}

struct errorResponse: Codable {
    let success: Bool
    let message: String
}
struct UserInfo: Codable {
    let username: String
    let subscriptions: [Subscription]
    let ip: String
    let hwid: String?
    let createdate: String
    let lastlogin: String
}

struct Subscription: Codable {
    let subscription: String
    let key: String?
    let expiry: String
    let timeleft: Int
}


