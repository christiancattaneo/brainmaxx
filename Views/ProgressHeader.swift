import SwiftUI

struct ProgressHeader: View {
    let points: Int
    let totalQuestions: Int
    let difficulty: Difficulty
    
    @State private var animatedPoints: Int = 0
    @State private var showIncrease: Bool = false
    
    private var percentageComplete: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(points) / Double(totalQuestions * 20) * 100
    }
    
    private var estimatedIQ: Int {
        let difficultyBonus: Double = switch difficulty {
        case .easy: 10
        case .medium: 25
        case .hard: 40
        }
        return 100 + Int((percentageComplete / 100) * difficultyBonus)
    }
    
    private var estimatedSalary: Int {
        let difficultyMultiplier: Double = switch difficulty {
        case .easy: 1.5
        case .medium: 2.0
        case .hard: 3.0
        }
        return 50_000 + Int((percentageComplete / 100) * 450_000 * difficultyMultiplier)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Points Counter
            VStack(alignment: .leading, spacing: 2) {
                Text("Points")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(animatedPoints)")
                        .font(.system(size: 20, weight: .bold))
                    Text("/\(totalQuestions * 20)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // IQ Score
            VStack(alignment: .leading, spacing: 2) {
                Text("IQ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(estimatedIQ)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
            }
            
            Divider()
                .frame(height: 24)
            
            // Salary
            VStack(alignment: .leading, spacing: 2) {
                Text("Salary")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatCurrency(estimatedSalary))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Spacer()
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: percentageComplete / 100)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(percentageComplete))%")
                    .font(.system(size: 10, weight: .bold))
            }
            .frame(width: 32, height: 32)
        }
        .onChange(of: points) { oldValue, newValue in
            if newValue > oldValue {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showIncrease = true
                }
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 8)) {
                    animatedPoints = newValue
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showIncrease = false
                    }
                }
            } else {
                animatedPoints = newValue
            }
        }
        .onAppear {
            animatedPoints = points
        }
    }
    
    private var progressColor: Color {
        if percentageComplete < 33 {
            return .red
        } else if percentageComplete < 66 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressHeader(points: 60, totalQuestions: 10, difficulty: .medium)
            .padding()
            .background(Color(.systemBackground))
        ProgressHeader(points: 120, totalQuestions: 10, difficulty: .hard)
            .padding()
            .background(Color(.systemBackground))
        ProgressHeader(points: 20, totalQuestions: 10, difficulty: .easy)
            .padding()
            .background(Color(.systemBackground))
    }
    .padding()
} 