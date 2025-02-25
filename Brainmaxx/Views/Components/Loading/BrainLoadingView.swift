import SwiftUI

struct BrainLoadingView: View {
    var title: String = "Generating Questions"
    var subtitle: String = "Using AI to create your curriculum"
    var showSparkles: Bool = true
    
    // Colors
    private let primaryColor = Color.blue
    private let secondaryColor = Color.purple
    private let accentColor = Color.cyan
    
    // Star shape
    struct Star: Shape {
        let points: Int
        let innerRatio: CGFloat
        
        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let outerRadius = min(rect.width, rect.height) / 2
            let innerRadius = outerRadius * innerRatio
            
            var path = Path()
            
            let angleIncrement = .pi * 2 / CGFloat(points * 2)
            
            for i in 0..<(points * 2) {
                let angle = CGFloat(i) * angleIncrement - .pi / 2
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let x = center.x + cos(angle) * radius
                let y = center.y + sin(angle) * radius
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            path.closeSubpath()
            return path
        }
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            ZStack {
                // Remove the simple background gradient and make it transparent
                // Background gradient
                /*RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.2)
                    ]),
                    center: .center,
                    startRadius: 1,
                    endRadius: 200
                )
                .opacity(0.5)*/
                
                // Animated stars in the background
                if showSparkles {
                    ForEach(0..<20) { index in
                        let baseAngle = Double(index) * 0.314 + time * (0.05 + Double(index % 7) * 0.01)
                        let distance = 70.0 + 80.0 * sin(time * 0.2 + Double(index) * 0.17)
                        let xPos = cos(baseAngle) * distance
                        let yPos = sin(baseAngle) * distance
                        
                        Star(points: (index % 3) + 4, innerRatio: 0.4 + 0.1 * sin(time + Double(index)))
                            .fill(
                                index % 3 == 0 ? primaryColor : 
                                index % 3 == 1 ? secondaryColor : accentColor
                            )
                            .frame(width: 8 + 4 * sin(time * 0.5 + Double(index)), 
                                   height: 8 + 4 * sin(time * 0.5 + Double(index)))
                            .offset(x: xPos, y: yPos)
                            .opacity(0.5 + 0.3 * sin(time * 0.8 + Double(index)))
                            .rotationEffect(Angle(degrees: time * 20 + Double(index * 5)))
                    }
                }
                
                // Central content
                ZStack {
                    // Pulsing glow effect behind the brain
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.blue.opacity(0.2),
                                    Color.purple.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 100
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(1.0 + 0.2 * sin(time * 0.8))
                    
                    // Radiating lines
                    ForEach(0..<24) { index in
                        let angle = Double(index) * .pi / 12
                        let minLength = 70.0
                        let maxLength = 110.0
                        let length = minLength + (maxLength - minLength) * 0.5 * (1 + sin(time * 0.5 + Double(index) * 0.2))
                        let lineColor = index % 6 < 3 ? primaryColor : secondaryColor
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        lineColor.opacity(0.7),
                                        lineColor.opacity(0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: length, height: 1.5)
                            .offset(x: length/2 + 40)
                            .rotationEffect(Angle(radians: angle))
                            .opacity(0.3 + 0.4 * sin(time * 0.3 + Double(index) * 0.2))
                    }
                    
                    // Brain image
                    Image("brain-lightbulb")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .saturation(1.2)
                        .brightness(0.1)
                        .contrast(1.1)
                        .scaleEffect(1.0 + 0.05 * sin(time * 1.2))
                    
                    // Small moving particles along radiating lines
                    ForEach(0..<12) { index in
                        let angle = Double(index) * .pi / 6
                        let baseTime = (time * 0.3 + Double(index) * 0.17).truncatingRemainder(dividingBy: 1.0)
                        let distance = 60 + baseTime * 80
                        
                        let xPos = cos(angle) * distance
                        let yPos = sin(angle) * distance
                        
                        Circle()
                            .fill(
                                index % 3 == 0 ? primaryColor : 
                                index % 3 == 1 ? secondaryColor : accentColor
                            )
                            .frame(width: 4, height: 4)
                            .offset(x: xPos, y: yPos)
                            .opacity((1.0 - baseTime) * 0.8)
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

#Preview {
    BrainLoadingView()
        .frame(width: 400, height: 400)
        .preferredColorScheme(.dark)
} 