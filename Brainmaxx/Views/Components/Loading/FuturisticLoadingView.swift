import SwiftUI

struct FuturisticLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 0.6
    @State private var innerRotation: Double = 0
    @State private var sparkleOffset: CGFloat = 0
    
    var title: String = "Generating Questions"
    var subtitle: String = "Using AI to create your curriculum"
    var showSparkles: Bool = true
    
    var body: some View {
        ZStack {
            // Outer rotating ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Inner rotating elements
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12, height: 12)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(index) * 120))
                    .rotationEffect(.degrees(innerRotation))
            }
            
            // Center pulsing dot
            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
                .scaleEffect(scale)
            
            if showSparkles {
                // Floating sparkles
                ForEach(0..<5) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat.random(in: 8...14)))
                        .foregroundColor(.blue.opacity(0.6))
                        .offset(
                            x: CGFloat.random(in: -50...50),
                            y: -sparkleOffset + CGFloat(index * 20)
                        )
                        .animation(
                            Animation
                                .easeInOut(duration: Double.random(in: 1.5...2.5))
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: sparkleOffset
                        )
                }
            }
            
            // Loading text
            VStack(spacing: 12) {
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Start animations
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: false)
            ) {
                innerRotation = 360
            }
            
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
                opacity = 1
                sparkleOffset = 40
            }
        }
    }
}

#Preview {
    FuturisticLoadingView()
} 