import SwiftUI

struct SparklesOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(x: CGFloat(i * 20 - 20), y: isAnimating ? -10 : 0)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SparklesOverlay()
        .frame(width: 200, height: 100)
        .background(Color.blue)
} 