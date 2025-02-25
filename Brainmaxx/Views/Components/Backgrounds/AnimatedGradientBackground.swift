import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animateGradient1 = false
    @State private var animateGradient2 = false
    
    var body: some View {
        ZStack {
            // First animated gradient layer
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.indigo.opacity(0.3)
                ],
                startPoint: animateGradient1 ? .topLeading : .bottomTrailing,
                endPoint: animateGradient1 ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(
                Animation.easeInOut(duration: 5.0)
                    .repeatForever(autoreverses: true),
                value: animateGradient1
            )
            
            // Second animated gradient layer
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.2),
                    Color.blue.opacity(0.2),
                    Color.cyan.opacity(0.2)
                ],
                startPoint: animateGradient2 ? .topTrailing : .bottomLeading,
                endPoint: animateGradient2 ? .bottomLeading : .topTrailing
            )
            .ignoresSafeArea()
            .animation(
                Animation.easeInOut(duration: 6.0)
                    .repeatForever(autoreverses: true),
                value: animateGradient2
            )
            .blendMode(.plusLighter)
        }
        .onAppear {
            // Start the animations with slight delays
            withAnimation {
                animateGradient1 = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    animateGradient2 = true
                }
            }
        }
    }
}

#Preview {
    AnimatedGradientBackground()
} 