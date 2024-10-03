import Foundation
import UIKit
import MachO

// https://gist.github.com/sdlee3/691463a4869311a2c9404150346bd365

extension UIDevice {
    public var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    public var isJailBroken: Bool {
        get {
            if JailBrokenHelper.hasCydiaInstalled() { return true }
            if JailBrokenHelper.isContainsSuspiciousApps() { return true }
            if JailBrokenHelper.isSuspiciousSystemPathsExists() { return true }
            return JailBrokenHelper.canEditSystemFiles()
        }
    }
    
    public var isFridaDetected: Bool {
        get {
            if JailBrokenHelper.checkDYLD() { return true }
            if JailBrokenHelper.isFridaRunning() { return true }
            return false
        }
    }
}

private struct JailBrokenHelper {
    @MainActor static func hasCydiaInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    
    static func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    static func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    static func canEditSystemFiles() -> Bool {
        let jailBreakText = "Developer Insider"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    static var suspiciousAppsPathToCheck: [String] {
        return ["/Applications/Cydia.app",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app"
        ]
    }
    
    static var suspiciousSystemPathsToCheck: [String] {
        return ["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                "/private/var/lib/apt",
                "/private/var/lib/apt/",
                "/private/var/lib/cydia",
                "/private/var/mobile/Library/SBSettings/Themes",
                "/private/var/stash",
                "/private/var/tmp/cydia.log",
                "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                "/usr/bin/sshd",
                //"/usr/libexec/sftp-server",
                //"/usr/sbin/sshd",
                "/etc/apt",
                //"/bin/bash",
                "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
    }

    static func checkDYLD() -> Bool {
        let suspiciousLibraries = [
            "FridaGadget",
            "frida",
            "cynject",
            "libcycript"
        ]
        for libraryIndex in 0..<_dyld_image_count() {
            guard let loadedLibrary = String(validatingCString: _dyld_get_image_name(libraryIndex)) else { continue }
            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) {
                    return true
                }
            }
        }
        return false
    }

    static func isFridaRunning() -> Bool {
       func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
           let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
           return littleEndian ? _OSSwapInt16(port) : port
       }
     
       var serverAddress = sockaddr_in()
       serverAddress.sin_family = sa_family_t(AF_INET)
       serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
       serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(27042))
       let sock = socket(AF_INET, SOCK_STREAM, 0)
     
       let result = withUnsafePointer(to: &serverAddress) {
           $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
               connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
           }
       }
       if result != -1 {
           return true
       }
       return false
    }
}
