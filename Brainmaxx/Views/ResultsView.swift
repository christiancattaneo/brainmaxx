import SwiftUI

struct ResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Binding var navigationPath: NavigationPath
    let quizResult: QuizResult
    
    // Computed properties for estimates
    private var estimatedSATScore: Int {
        // Base score of 400 + percentage of max points (400)
        400 + Int((quizResult.percentageCorrect / 100) * 400)
    }
    
    private var estimatedIQ: Int {
        // Base IQ of 100 + bonus based on performance and difficulty
        let difficultyBonus: Double = switch quizResult.difficulty {
            case .easy: 10
            case .medium: 25
            case .hard: 40
        }
        return 100 + Int((quizResult.percentageCorrect / 100) * difficultyBonus)
    }
    
    private var estimatedSalary: Int {
        // Base salary of $50,000 + bonus based on performance and difficulty
        let difficultyMultiplier: Double = switch quizResult.difficulty {
            case .easy: 1.5
            case .medium: 2.0
            case .hard: 3.0
        }
        return 50_000 + Int((quizResult.percentageCorrect / 100) * 450_000 * difficultyMultiplier)
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
                }
                .buttonStyle(.bordered)
                
                Button {
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