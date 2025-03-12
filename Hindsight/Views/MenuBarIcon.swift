import SwiftUI

struct MenuBarIcon: View {
    var body: some View {
        Image("MenuBarIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundStyle(.primary)
    }
}

#if DEBUG
struct MenuBarIcon_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarIcon()
            .frame(width: 200, height: 200)
            .background(Color.blue)
            .previewLayout(.sizeThatFits)
    }
}
#endif 