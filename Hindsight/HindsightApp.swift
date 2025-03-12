//
//  HindsightApp.swift
//  Hindsight
//
//  Created by David Sizemore on 2/4/25.
//

import SwiftUI

@main
struct HindsightApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            MenuBarIcon()
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup {
            EmptyView()  // This prevents the main window from showing
        }
        
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
}
