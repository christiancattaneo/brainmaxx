import SwiftUI

// Question Header View
private struct QuestionHeaderView: View {
    let text: String?
    let mathExpression: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let text = text {
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.bottom, 4)
            }
            
            if let math = mathExpression {
                MathExpressionView(expression: math)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal)
    }
}

// Question Option View
private struct QuestionOptionView: View {
    let option: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                if option.contains("/") || option.contains("^") || option.contains("\\") {
                    MathExpressionView(expression: option)
                } else {
                    Text(option)
                        .font(.body)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

// Explanation View
private struct ExplanationView: View {
    let answer: String
    let correctAnswers: [String]
    let explanationText: String?
    let explanationMath: String?
    
    var isCorrect: Bool {
        correctAnswers.contains(answer)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
            }
            
            Text("Explanation:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let text = explanationText {
                Text(text)
                    .font(.body)
                    .padding(.bottom, 4)
            }
            
            if let math = explanationMath {
                MathExpressionView(expression: math)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// Main Question View
struct QuestionView: View {
    let question: Question
    @Binding var showQuestion: Bool
    let onAnswered: (Bool) -> Void
    
    @State private var selectedAnswer: String?
    @State private var showExplanation = false
    @State private var simplifiedQuestion: Question?
    @State private var isLoading = false
    @State private var error: Error?
    
    private let simplifier = QuestionSimplifier()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let simplified = simplifiedQuestion {
                // Show simplified version
                QuestionHeaderView(
                    text: simplified.question.text,
                    mathExpression: simplified.question.originalMath
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(simplified.question.displayOptions, id: \.self) { option in
                        QuestionOptionView(
                            option: option,
                            isSelected: selectedAnswer == option,
                            isDisabled: selectedAnswer != nil
                        ) {
                            selectedAnswer = option
                            let isCorrect = simplified.question.correctAnswers.contains(option)
                            showExplanation = true
                            onAnswered(isCorrect)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                // Show original question
                QuestionHeaderView(
                    text: question.question.text,
                    mathExpression: question.question.originalMath
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(question.question.displayOptions, id: \.self) { option in
                        QuestionOptionView(
                            option: option,
                            isSelected: selectedAnswer == option,
                            isDisabled: selectedAnswer != nil
                        ) {
                            selectedAnswer = option
                            let isCorrect = question.question.correctAnswers.contains(option)
                            showExplanation = true
                            onAnswered(isCorrect)
                            
                            // If incorrect, get simplified version
                            if !isCorrect {
                                Task {
                                    await simplifyCurrentQuestion()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if showExplanation, let answer = selectedAnswer {
                if let simplified = simplifiedQuestion {
                    ExplanationView(
                        answer: answer,
                        correctAnswers: simplified.question.correctAnswers,
                        explanationText: simplified.explanation.text,
                        explanationMath: simplified.explanation.originalMath
                    )
                } else {
                    ExplanationView(
                        answer: answer,
                        correctAnswers: question.question.correctAnswers,
                        explanationText: question.explanation.text,
                        explanationMath: question.explanation.originalMath
                    )
                }
            }
            
            if isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 5)
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        
                        Text("Generating simpler version...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Using AI to create an easier question")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(20)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            if let error = error {
                Text("Failed to generate simpler version: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding(.vertical)
    }
    
    private func simplifyCurrentQuestion() async {
        isLoading = true
        error = nil
        do {
            simplifiedQuestion = try await simplifier.simplifyQuestion(question)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

// MARK: - Preview
struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        // Basic preview
        QuestionView(
            question: SampleData.subjects[0].getQuestions(forDifficulty: .easy)[0],
            showQuestion: .constant(true),
            onAnswered: { _ in }
        )
        
        // Dark mode preview
        QuestionView(
            question: SampleData.subjects[0].getQuestions(forDifficulty: .medium)[0],
            showQuestion: .constant(true),
            onAnswered: { _ in }
        )
        .preferredColorScheme(.dark)
        
        // Preview with image
        QuestionView(
            question: SampleData.subjects[0].getQuestions(forDifficulty: .hard)[0],
            showQuestion: .constant(true),
            onAnswered: { _ in }
        )
        .previewDisplayName("With Image")
    }
}



