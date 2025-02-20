import SwiftUI

struct ResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Binding var navigationPath: NavigationPath
    let quizResult: QuizResult
    
    // Computed properties for estimates
    private var estimatedSATScore: Int {
        // Base score starts at 400 (200 per section)
        let baseScore = 400
        
        // Maximum additional points possible (1600 - 400 = 1200)
        let maxAdditionalPoints = 1200
        
        // Difficulty multiplier
        let difficultyMultiplier: Double = switch quizResult.difficulty {
            case .easy: 0.7    // Max ~1240
            case .medium: 0.85  // Max ~1420
            case .hard: 1.0    // Max 1600
        }
        
        // Calculate score based on performance and difficulty
        let additionalPoints = Int((quizResult.percentageCorrect / 100) * Double(maxAdditionalPoints) * difficultyMultiplier)
        
        // Ensure score is between 400 and 1600
        return min(1600, max(400, baseScore + additionalPoints))
    }
    
    private var estimatedIQ: Int {
        let difficultyBonus: Double = switch quizResult.difficulty {
        case .easy: 20
        case .medium: 35
        case .hard: 50
        }
        // Start at 0, max out at 100 + bonus
        return Int((quizResult.percentageCorrect / 100) * (100 + difficultyBonus))
    }
    
    private var estimatedSalary: Int {
        let difficultyMultiplier: Double = switch quizResult.difficulty {
        case .easy: 1.0
        case .medium: 1.5
        case .hard: 2.0
        }
        // Start at 0, gradually increase to max based on difficulty
        let maxSalary = 500_000 * difficultyMultiplier
        return Int((quizResult.percentageCorrect / 100) * maxSalary)
    }
    
    private var shareText: String {
        """
        🎉 I just completed \(quizResult.subject.name) on Brainmaxx!
        
        📊 My Results:
        • SAT Score: \(estimatedSATScore)
        • IQ Score: \(estimatedIQ)
        • Future Salary: \(formatCurrency(estimatedSalary))
        
        📝 Stats:
        • Questions: \(quizResult.score)/\(quizResult.totalQuestions)
        • Points: \(quizResult.score * 20)
        • Difficulty: \(quizResult.difficulty.displayName)
        
        💪 Try it yourself! #Brainmaxx #SATPrep
        """
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "party.popper.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text("Great Job!")
                        .font(.title)
                        .bold()
                }
                
                Text("You've completed \(quizResult.subject.name)!")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Estimated SAT Score
            ResultCard(
                icon: "graduationcap.fill",
                title: "Estimated SAT Score",
                value: "\(estimatedSATScore)",
                color: .blue
            )
            
            // Estimated IQ
            ResultCard(
                icon: "brain.head.profile",
                title: "Estimated IQ",
                value: "\(estimatedIQ)",
                color: .purple
            )
            
            // Estimated Future Salary
            ResultCard(
                icon: "dollarsign.circle.fill",
                title: "Estimated Future Salary",
                value: formatCurrency(estimatedSalary),
                color: .green
            )
            
            // Stats Grid
            VStack(alignment: .leading, spacing: 16) {
                StatsRow(
                    icon: "checkmark.circle.fill",
                    label: "Questions",
                    value: "\(quizResult.score)/\(quizResult.totalQuestions)"
                )
                
                StatsRow(
                    icon: "star.fill",
                    label: "Total Points",
                    value: "\(quizResult.score * 20)"
                )
                
                StatsRow(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Difficulty",
                    value: quizResult.difficulty.displayName
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 2)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                ShareLink(
                    item: shareText,
                    preview: SharePreview(
                        "Brainmaxx Results",
                        image: Image(systemName: "star.circle.fill")
                    )
                ) {
                    Label("Share Results", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            HapticManager.shared.buttonPress()
                        }
                }
                .buttonStyle(.bordered)
                
                Button {
                    HapticManager.shared.buttonPress()
                    NotificationCenter.default.post(name: .returnToHome, object: nil)
                    dismiss()
                } label: {
                    Text("Go Back to Feed")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .interactiveDismissDisabled() // Prevent swipe to dismiss
    }
    
    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

// MARK: - Supporting Views
struct ResultCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Title row
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .font(.subheadline)
            
            // Centered value
            Text(value)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 1)
    }
}

struct StatsRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

extension Notification.Name {
    static let returnToHome = Notification.Name("returnToHome")
}

#Preview {
    ResultsView(navigationPath: .constant(NavigationPath()), quizResult: QuizResult(
        subject: Subject(
            id: "math",
            name: "Mathematics",
            description: "Math practice questions",
            iconName: "function",
            topics: [:]
        ),
        difficulty: .hard,
        answeredQuestions: Array(repeating: Question(
            id: "test",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Test",
            difficulty: .medium,
            question: Question.Content(
                text: "Test",
                originalMath: nil,
                mathOptions: ["1"],
                correctAnswers: ["1"]
            ),
            explanation: Question.Explanation(
                text: "Test",
                originalMath: nil
            ),
            images: []
        ), count: 40),
        totalQuestions: 44
    ))
} 