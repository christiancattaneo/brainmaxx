import SwiftUI

struct EnhancedFuturisticLoadingView: View {
    var title: String = "Generating Questions"
    var subtitle: String = "Using AI to create your curriculum"
    var showSparkles: Bool = true
    
    // Colors
    private let primaryColor = Color.blue
    private let secondaryColor = Color.purple
    private let accentColor = Color.cyan
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let rotationAngle = time.remainder(dividingBy: 60) * 6 // Complete a full rotation every 60 seconds
            
            ZStack {
                // Background gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.2)
                    ]),
                    center: .center,
                    startRadius: 1,
                    endRadius: 200
                )
                .opacity(0.5)
                
                // Neural network visualization
                ZStack {
                    // Central brain or AI core
                    ZStack {
                        // Center pulsing core
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [primaryColor.opacity(0.9), secondaryColor.opacity(0.3)]),
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 40, height: 40)
                            .scaleEffect(1 + 0.15 * sin(time))
                            .shadow(color: primaryColor.opacity(0.5), radius: 10)
                        
                        // Orbiting particles around core
                        ForEach(0..<6) { index in
                            Circle()
                                .fill(accentColor)
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: 30 * cos(rotationAngle + Double(index) * .pi / 3),
                                    y: 30 * sin(rotationAngle + Double(index) * .pi / 3)
                                )
                                .opacity(0.7)
                        }
                        
                        // Outer ring
                        Circle()
                            .strokeBorder(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        primaryColor.opacity(0.8),
                                        secondaryColor.opacity(0.5),
                                        accentColor.opacity(0.8),
                                        primaryColor.opacity(0.8)
                                    ]),
                                    center: .center
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 70, height: 70)
                            .rotationEffect(Angle(degrees: -rotationAngle * 15))
                    }
                    
                    // Neural nodes
                    ForEach(0..<7) { index in
                        let angle = Double(index) * 2 * .pi / 7
                        let radius: CGFloat = 120
                        let xPos = cos(angle) * radius
                        let yPos = sin(angle) * radius
                        
                        // Connection lines from center to nodes
                        NeuralLine(
                            from: CGPoint(x: 0, y: 0),
                            to: CGPoint(x: xPos, y: yPos)
                        )
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    primaryColor.opacity(0),
                                    primaryColor.opacity(0.2 + 0.3 * sin(time + Double(index)))
                                ]),
                                startPoint: .init(x: 0, y: 0),
                                endPoint: .init(x: xPos/radius, y: yPos/radius)
                            ),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 3])
                        )
                        
                        // Actual node
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        (index % 2 == 0 ? primaryColor : secondaryColor).opacity(0.8),
                                        (index % 2 == 0 ? primaryColor : secondaryColor).opacity(0.3)
                                    ]),
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: 15
                                )
                            )
                            .frame(width: 20, height: 20)
                            .offset(x: xPos, y: yPos)
                            .opacity(0.4 + 0.4 * sin(time * 0.5 + Double(index)))
                        
                        // Data particles moving from center to nodes
                        ForEach(0..<2) { particleIdx in
                            let timeOffset = Double(particleIdx) * 0.5
                            let progress = ((time / 10) + timeOffset).truncatingRemainder(dividingBy: 1.0)
                            
                            Circle()
                                .fill(index % 3 == 0 ? accentColor : primaryColor)
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: xPos * CGFloat(progress),
                                    y: yPos * CGFloat(progress)
                                )
                                .opacity(progress < 0.9 ? 1.0 : (1.0 - (progress - 0.9) * 10))
                        }
                    }
                    
                    // Floating particles - now using the timeline for continuous movement
                    if showSparkles {
                        ForEach(0..<15) { index in
                            let baseAngle = Double(index) * 0.1 + time * (0.1 + Double(index % 5) * 0.02)
                            let xNoise = sin(baseAngle * 2) * 70
                            let yNoise = cos(baseAngle * 3) * 70
                            let radius = 60.0 + 50.0 * sin(time * 0.2 + Double(index) * 0.3)
                            let xPos = cos(baseAngle) * radius + xNoise
                            let yPos = sin(baseAngle) * radius + yNoise
                            
                            Circle()
                                .fill(index % 3 == 0 ? accentColor : secondaryColor)
                                .frame(width: CGFloat.random(in: 2...4))
                                .offset(x: xPos, y: yPos)
                                .opacity(0.4 + 0.4 * sin(time + Double(index)))
                        }
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
                .padding(.top, 180)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Helper for drawing lines
struct NeuralLine: Shape {
    var from: CGPoint
    var to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}

#Preview {
    EnhancedFuturisticLoadingView()
        .frame(width: 400, height: 400)
        .preferredColorScheme(.dark)
} 