import SwiftUI

struct AIGlowingBackground: View {
    @State private var animate = false
    @State private var pulseScale: CGFloat = 1.0
    
    // Configurable properties
    var baseColors: [Color] = [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]
    var circleSize: CGFloat = 150
    var pulseSize: CGFloat = 120
    var animationDuration: Double = 3
    var pulseAnimationDuration: Double = 2
    var horizontalOffset: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: baseColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            
            // Animated overlay gradients
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: circleSize, height: circleSize)
                .blur(radius: 20)
                .offset(x: animate ? horizontalOffset : -horizontalOffset, y: 0)
                .animation(
                    Animation.easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
            
            // Pulsing circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: pulseSize, height: pulseSize)
                .scaleEffect(pulseScale)
                .blur(radius: 5)
        }
        .onAppear {
            // Start the horizontal animation
            animate = true
            
            // Start the pulsing animation
            withAnimation(
                Animation
                    .easeInOut(duration: pulseAnimationDuration)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.2
            }
        }
    }
}

#Preview {
    AIGlowingBackground()
        .frame(height: 200)
} 