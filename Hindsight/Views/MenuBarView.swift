import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status and countdown section
            HStack(spacing: 8) {
                Circle()
                    .fill(appState.isPaused ? Color.orange : Color.green)
                    .frame(width: 6, height: 6)
                    .frame(width: 20, height: 20)
                
                Text(statusText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.vertical, 2)
            
            // Menu items
            Button(action: {
                if appState.isPaused {
                    appState.resumeTimer()
                } else {
                    appState.pauseTimer()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: appState.isPaused ? "play" : "pause")
                        .foregroundColor(appState.isPaused ? .green : .orange)
                        .frame(width: 20, height: 20)
                        .font(.system(size: 12))
                    Text(appState.isPaused ? "Resume Breaks" : "Pause Breaks")
                }
            }
            .buttonStyle(MenuButtonStyle())
            .padding(.vertical, 4)
            
            Divider()
                .padding(.vertical, 2)
            
            Button(action: {
                appState.launchAtLogin.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .foregroundColor(appState.launchAtLogin ? .green : .secondary)
                        .frame(width: 20, height: 20)
                        .font(.system(size: 12))
                    Text("Launch at Login")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(MenuButtonStyle())
            .padding(.vertical, 4)
            
            Divider()
                .padding(.vertical, 2)
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .font(.system(size: 12))
                    Text("Quit Oblique Pauses")
                }
            }
            .buttonStyle(MenuButtonStyle())
            .padding(.vertical, 4)
        }
        .frame(width: 220)
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    private var statusText: String {
        if appState.isPaused {
            return "Breaks Paused"
        }
        
        let timeUntilNext = appState.timeUntilNextBreak
        let minutes = Int(timeUntilNext / 60)
        let seconds = Int(timeUntilNext.truncatingRemainder(dividingBy: 60))
        
        return String(format: "Next break in %d:%02d", minutes, seconds)
    }
}

// Custom button style for menu items
struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(configuration.isPressed ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
    }
}

// Custom toggle style for menu items
struct MenuToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                    .font(.system(size: 14))
                Spacer()
            }
        }
        .buttonStyle(MenuButtonStyle())
    }
} 