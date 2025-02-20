import SwiftUI

struct QuestionView: View {
    let question: Question
    @Binding var showQuestion: Bool
    let onAnswered: (Bool) -> Void
    
    @State private var selectedOption: Int?
    @State private var showExplanation = false
    @State private var animateCorrect: Bool = false
    @State private var animateIncorrect: Bool = false
    @State private var shake: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Question text with math formatting
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Question:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        MathView(content: question.question.originalMath ?? question.question.displayText)
                            .frame(minHeight: 60, maxHeight: geometry.size.height * 0.15)
                    }
                    .padding(.horizontal)
                    
                    // Question image if available
                    if let imageName = question.images.first {
                        AsyncImage(url: Bundle.main.url(forResource: imageName, withExtension: nil)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: geometry.size.height * 0.25)
                            case .failure(_):
                                Text("Failed to load image")
                                    .foregroundColor(.secondary)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Options in 2x2 grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select your answer:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(question.question.displayOptions.indices, id: \.self) { index in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedOption = index
                                        let isCorrect = question.question.displayOptions[index] == question.question.correctAnswers.first
                                        
                                        if isCorrect {
                                            animateCorrect = true
                                        } else {
                                            animateIncorrect = true
                                            shake = true
                                        }
                                        
                                        // Show explanation immediately
                                        withAnimation(.easeInOut) {
                                            showExplanation = true
                                        }
                                        
                                        // Notify parent after a delay to allow animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            onAnswered(isCorrect)
                                        }
                                    }
                                } label: {
                                    VStack {
                                        // Use MathView for all options to ensure consistent formatting
                                        MathView(content: cleanMathContent(question.question.displayOptions[index]))
                                            .frame(minHeight: 44)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: geometry.size.height * 0.1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(optionColor(for: index))
                                            .shadow(radius: 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(selectedOption == index ? (question.question.displayOptions[index] == question.question.correctAnswers.first ? Color.green : Color.red) : Color.clear,
                                                           lineWidth: 4)
                                            )
                                    )
                                    .scaleEffect(selectedOption == index ? (question.question.displayOptions[index] == question.question.correctAnswers.first ? (animateCorrect ? 1.1 : 1.0) : (animateIncorrect ? 0.9 : 1.0)) : 1.0)
                                }
                                .disabled(selectedOption != nil)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Show explanation after answering
                    if showExplanation {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? .green : .red)
                                Text(selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? "Correct!" : "Incorrect")
                                    .font(.headline)
                                    .foregroundColor(selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? .green : .red)
                            }
                            
                            Text("Explanation:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            MathView(content: question.explanation.originalMath ?? question.explanation.displayText)
                                .frame(minHeight: 60, maxHeight: geometry.size.height * 0.2)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.vertical)
            }
        }
        .onChange(of: animateCorrect) { oldValue, newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.animateCorrect = false
            }
        }
        .onChange(of: animateIncorrect) { oldValue, newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.animateIncorrect = false
                self.shake = false
            }
        }
    }
    
    private func optionColor(for index: Int) -> Color {
        if let selected = selectedOption {
            if index == selected {
                // Selected option
                if question.question.displayOptions[index] == question.question.correctAnswers.first {
                    return .green  // Correct answer
                } else {
                    return .red    // Wrong answer
                }
            } else if question.question.displayOptions[index] == question.question.correctAnswers.first {
                return .green.opacity(0.7)  // Show correct answer
            }
        }
        
        // Default colors for unselected options
        switch index {
        case 0: return Color(red: 0.8, green: 0.2, blue: 0.3) // Red
        case 1: return Color(red: 0.2, green: 0.4, blue: 0.8) // Blue
        case 2: return Color(red: 0.85, green: 0.7, blue: 0.2) // Yellow
        case 3: return Color(red: 0.4, green: 0.75, blue: 0.3) // Green
        default: return .gray
        }
    }
    
    private func cleanMathContent(_ content: String) -> String {
        // If content already has math tags, return as is
        if content.contains("<math") {
            return content
        }
        
        // Check if content contains mathematical symbols or expressions
        let mathSymbols = ["÷", "×", "±", "∓", "≤", "≥", "≠", "≈", "∞", "∑", "∏", "∫", "∂", "√", "∛", "∜",
                          "⁄", "¼", "½", "¾", "⅓", "⅔", "⅕", "⅖", "⅗", "⅘", "⅙", "⅚", "⅛", "⅜", "⅝", "⅞",
                          "π", "ℯ", "ϕ", "∅", "∈", "∉", "⊂", "⊃", "∪", "∩", "∧", "∨", "¬", "⇒", "⇔", "∀", "∃",
                          "∄", "ℕ", "ℤ", "ℚ", "ℝ", "ℂ"]
        
        let containsMathSymbols = mathSymbols.contains { content.contains($0) }
        let containsNumbers = content.contains { $0.isNumber }
        let containsFractions = content.contains("/")
        
        // If content has math symbols or is a number/fraction, wrap in math tags
        if containsMathSymbols || containsNumbers || containsFractions {
            return "<math>\(content)</math>"
        }
        
        // Otherwise return as plain text
        return content
    }
}

#Preview("Question View") {
    QuestionView(
        question: Question(
            id: "sample-001",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Linear equations in one variable",
            difficulty: .medium,
            question: Question.Content(
                text: "What value of x satisfies the equation 2x + 5 = 15?",
                originalMath: "<math>2x + 5 = 15</math>",
                mathOptions: [
                    "5",
                    "7",
                    "8",
                    "10"
                ],
                correctAnswers: ["5"]
            ),
            explanation: Question.Explanation(
                text: "To solve 2x + 5 = 15, subtract 5 from both sides to get 2x = 10, then divide both sides by 2 to get x = 5.",
                originalMath: "<math>2x + 5 = 15 ⟹ 2x = 10 ⟹ x = 5</math>"
            ),
            images: []
        ),
        showQuestion: .constant(true),
        onAnswered: { _ in }
    )
    .frame(height: 600)
}

#Preview("Dark Mode") {
    QuestionView(
        question: Question(
            id: "sample-001",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Linear equations in one variable",
            difficulty: .medium,
            question: Question.Content(
                text: "What value of x satisfies the equation 2x + 5 = 15?",
                originalMath: "<math>2x + 5 = 15</math>",
                mathOptions: [
                    "5",
                    "7",
                    "8",
                    "10"
                ],
                correctAnswers: ["5"]
            ),
            explanation: Question.Explanation(
                text: "To solve 2x + 5 = 15, subtract 5 from both sides to get 2x = 10, then divide both sides by 2 to get x = 5.",
                originalMath: "<math>2x + 5 = 15 ⟹ 2x = 10 ⟹ x = 5</math>"
            ),
            images: []
        ),
        showQuestion: .constant(true),
        onAnswered: { _ in }
    )
    .frame(height: 600)
    .preferredColorScheme(.dark)
}

#Preview("With Image") {
    QuestionView(
        question: Question(
            id: "sample-002",
            type: "multiple-choice",
            subject: "Math",
            topic: "Geometry",
            skill: "Linear equations in two variables",
            difficulty: .hard,
            question: Question.Content(
                text: "In the coordinate plane shown above, what is the slope of line L?",
                originalMath: "",
                mathOptions: [
                    "-4/5",
                    "-5/4",
                    "4/5",
                    "5/4"
                ],
                correctAnswers: ["-4/5"]
            ),
            explanation: Question.Explanation(
                text: "The slope can be calculated by finding the change in y divided by the change in x between any two points on the line. Using the points (0,4) and (5,0), the slope is (0-4)/(5-0) = -4/5.",
                originalMath: ""
            ),
            images: ["sample_graph.png"]
        ),
        showQuestion: .constant(true),
        onAnswered: { _ in }
    )
    .frame(height: 600)
}



