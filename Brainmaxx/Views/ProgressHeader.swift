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
        case .easy: 20
        case .medium: 35
        case .hard: 50
        }
        // Start at 0, max out at 100 + bonus
        return Int((percentageComplete / 100) * (100 + difficultyBonus))
    }
    
    private var estimatedSalary: Int {
        let difficultyMultiplier: Double = switch difficulty {
        case .easy: 1.0
        case .medium: 1.5
        case .hard: 2.0
        }
        // Start at 0, gradually increase to max based on difficulty
        let maxSalary = 500_000 * difficultyMultiplier
        return Int((percentageComplete / 100) * maxSalary)
    }
    
    var body: some View {
        HStack(spacing: 24) {
            // Points Counter
            VStack(alignment: .leading, spacing: 6) {
                Text("POINTS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(animatedPoints)")
                        .font(.system(size: 28, weight: .bold))
                    Text("/\(totalQuestions * 20)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
                .frame(height: 40)
            
            // IQ Score
            VStack(alignment: .leading, spacing: 6) {
                Text("IQ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text("\(estimatedIQ)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.purple)
            }
            
            Divider()
                .frame(height: 40)
            
            // Salary
            VStack(alignment: .leading, spacing: 6) {
                Text("SALARY")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(formatCurrency(estimatedSalary))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
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