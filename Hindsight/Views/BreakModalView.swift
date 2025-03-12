import SwiftUI

struct BreakModalView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isAnimating = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(appState.currentQuote.text)
                .font(.custom("Caprasimo", size: 40))
                .lineSpacing(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 2)
                .transition(.opacity.combined(with: .scale))
                .id(appState.currentQuote.text)
                .padding()
            
            if let author = appState.currentQuote.author {
                Text("- \(author)")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .transition(.opacity)
            }
                        
            VStack(spacing: 8.0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appState.dismissBreak()
                    }
                }) {
                    ZStack {
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(red: 1, green: 0.2, blue: 0.6))
                                .opacity(appState.dismissButtonEnabled ? 1 : 0.4)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(red: 0.6, green: 0.1, blue: 0.3))
                                        .frame(width: geometry.size.width * (appState.remainingWaitTime / appState.dismissDelay))
                                        .alignmentGuide(.leading) { _ in 0 },
                                    alignment: .leading
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .brightness(appState.dismissButtonEnabled && isHovered ? -0.1 : 0)
                                .animation(.easeOut(duration: 0.2), value: isHovered)
                        }
                        
                        Text("RETURN")
                            .font(.system(size: 22, weight: .heavy))
                            .kerning(1.5)
                            .foregroundColor(.white)
                            .shadow(
                                color: .black.opacity(appState.dismissButtonEnabled ? 0.25 : 0),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                    }
                    .frame(width: 200, height: 60)
                    .contentShape(Rectangle())
                }
                .disabled(!appState.dismissButtonEnabled)
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)
        }
        .frame(width: 500, height: 400)
        .padding(40)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.608, green: 0.043, blue: 0.792),
                        Color(red: 0.071, green: 0.122, blue: 0.361)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.071, green: 0.122, blue: 0.361),
                                Color(red: 0.071, green: 0.122, blue: 0.361)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 30
                    )
                    .blur(radius: 40)
            }
            .opacity(1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(40)
        .transition(.opacity.combined(with: .scale))
    }
}

#if DEBUG
struct BreakModalView_Previews: PreviewProvider {
    static var previews: some View {
        BreakModalView()
            .environmentObject(AppState())
            .previewLayout(.sizeThatFits)
            .background(Color.gray)
    }
}
#endif

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct HoverButtonStyle: ButtonStyle {
    let appState: AppState
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            // Background with progress
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Base button
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 1, green: 0.2, blue: 0.6))
                        .opacity(appState.dismissButtonEnabled ? 1 : 0.4)
                    
                    // Progress overlay
                    Rectangle()
                        .fill(Color(red: 0.6, green: 0.1, blue: 0.3))
                        .frame(width: geometry.size.width * (appState.remainingWaitTime / appState.dismissDelay))
                }
            }
            
            // Button label
            configuration.label
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
        .offset(y: appState.dismissButtonEnabled ? (configuration.isPressed ? 2 : isHovered ? -2 : 0) : 0)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        .onHover { hovering in
            isHovered = hovering && appState.dismissButtonEnabled
            
            #if DEBUG
            print("Hover state: \(hovering)")
            print("Remaining time: \(appState.remainingWaitTime)")
            print("Dismiss delay: \(appState.dismissDelay)")
            print("Progress: \(appState.remainingWaitTime / appState.dismissDelay)")
            print("Button enabled: \(appState.dismissButtonEnabled)")
            #endif
        }
    }
} 
