import Foundation
import AppKit
import SwiftUI
import ServiceManagement
import IOKit.pwr_mgt

class AppState: NSObject, ObservableObject {
    @Published var isPaused: Bool = false
    @Published var showingBreakModal: Bool = false
    @Published var dismissButtonEnabled: Bool = false
    @Published var currentQuote: Quote
    @Published var remainingWaitTime: TimeInterval = 0
    @Published private(set) var timeUntilNextBreak: TimeInterval = 0
    @Published var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin()
        }
    }
    
    private var timer: Timer?
    private var waitTimer: Timer?
    #if DEBUG
    private let breakInterval: TimeInterval = 30 // 30 seconds for testing
    #else
    private let breakInterval: TimeInterval = 20 * 60 // 20 minutes
    #endif
    
    private var breakWindow: NSWindow?
    private var sleepObserver: Any?
    private var wakeObserver: Any?
    private var preventSleepAssertionID: IOPMAssertionID = 0
    
    private var updateTimer: Timer?
    
    private var activity: NSObjectProtocol?
    
    override init() {
        self.currentQuote = QuoteManager.shared.getRandomQuote()
        super.init()
        setupSleepWakeHandlers()
        setupBreakWindow()
        startTimer()
        
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showBreak()
        }
        #endif
        
        // Check current launch at login status
        #if !DEBUG
        launchAtLogin = SMAppService.mainApp.status == .enabled
        #endif
        
        // Allow system sleep when app is idle
        activity = ProcessInfo.processInfo.beginActivity(
            options: .userInitiated,
            reason: "Break timer active"
        )
    }
    
    private func setupBreakWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.borderless, .fullSizeContentView, .titled],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.center()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.acceptsMouseMovedEvents = true
        
        let hostingView = NSHostingView(
            rootView: BreakModalView()
                .environmentObject(self)
        )
        window.contentView = hostingView
        
        breakWindow = window
    }
    
    private func setupSleepWakeHandlers() {
        sleepObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pauseTimer()
        }
        
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resumeTimer()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: breakInterval, repeats: true) { [weak self] _ in
            self?.showBreak()
        }
        
        // Start the continuous update timer if not already running
        if updateTimer == nil {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimeUntilNextBreak()
            }
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        updateTimer?.invalidate()
        updateTimer = nil
        isPaused = true
    }
    
    func resumeTimer() {
        startTimer()
        isPaused = false
    }
    
    private func preventSleep() {
        var assertionID: IOPMAssertionID = 0
        let reason = "Break in progress" as CFString
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID)
        
        if success == kIOReturnSuccess {
            self.preventSleepAssertionID = assertionID
        }
    }
    
    private func allowSleep() {
        if preventSleepAssertionID != 0 {
            IOPMAssertionRelease(preventSleepAssertionID)
            preventSleepAssertionID = 0
        }
    }
    
    func showBreak() {
        #if DEBUG
        print("showBreak called at: \(Date())")
        #endif
        
        // Temporarily prevent sleep during break
        preventSleep()
        
        currentQuote = QuoteManager.shared.getRandomQuote()
        remainingWaitTime = dismissDelay
        
        withAnimation(.easeOut(duration: 0.3)) {
            showingBreakModal = true
        }
        dismissButtonEnabled = false
        
        // Start countdown timer
        waitTimer?.invalidate()
        waitTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            withAnimation {
                self.remainingWaitTime -= 1
                if self.remainingWaitTime <= 0 {
                    timer.invalidate()
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.breakWindow?.makeKeyAndOrderFront(nil)
            if let window = self?.breakWindow {
                window.animator().alphaValue = 0
                window.animator().alphaValue = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) {
            self.waitTimer?.invalidate()
            withAnimation(.easeInOut(duration: 0.3)) {
                self.dismissButtonEnabled = true
            }
            // Allow sleep again after break is dismissed
            self.allowSleep()
        }
    }
    
    func dismissBreak() {
        waitTimer?.invalidate()
        withAnimation(.easeIn(duration: 0.3)) {
            showingBreakModal = false
        }
        
        // Add fade-out animation
        if let window = breakWindow {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                window.animator().alphaValue = 0
            } completionHandler: {
                window.orderOut(nil)
                self.startTimer()
            }
        } else {
            startTimer()
        }
    }
    
    deinit {
        breakWindow = nil
        if let sleepObserver = sleepObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(sleepObserver)
        }
        if let wakeObserver = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
        }
        waitTimer?.invalidate()
        updateTimer?.invalidate()
        
        // Clean up the activity
        if let activity = activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
    }
    
    var dismissDelay: TimeInterval {
        #if DEBUG
        return 5 // 5 seconds for testing
        #else
        return 30 // 30 seconds
        #endif
    }
    
    private func updateTimeUntilNextBreak() {
        guard let timer = timer else {
            timeUntilNextBreak = breakInterval
            return
        }
        
        let fireDate = timer.fireDate
        timeUntilNextBreak = fireDate.timeIntervalSinceNow
    }
    
    private func updateLaunchAtLogin() {
        #if DEBUG
        print("Debug mode: Launch at login settings not modified")
        #else
        if launchAtLogin {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
        #endif
    }
}

extension AppState: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        // Create a more frequent update timer when menu is open
        updateTimer?.invalidate()
        updateTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimeUntilNextBreak()
            // Force menu to update
            if let menuView = menu.items.first?.view as? NSHostingView<MenuBarView> {
                DispatchQueue.main.async {
                    menuView.setNeedsDisplay(menuView.bounds)
                    menuView.needsLayout = true
                }
            }
        }
        // Add to RunLoop with common mode
        if let timer = updateTimer {
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        // Restore normal update frequency
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeUntilNextBreak()
        }
    }
} 