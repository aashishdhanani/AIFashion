import SwiftUI

struct ChatMessageLoadingView: View {
    var animationDuration: Double
    @State private var isScaledUp = [false, false, false]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 10, height: 10) // Set the size for the circles
                    .scaleEffect(isScaledUp[index] ? 1.5 : 1)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true).delay(Double(index) * animationDuration / 2)) {
                            isScaledUp[index].toggle()
                        }
                    }
            }
        }
    }
}

#Preview {
    ChatMessageLoadingView(animationDuration: 0.5)
}
