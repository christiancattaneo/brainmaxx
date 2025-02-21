import SwiftUI

struct QuestionView: View {
    let question: Question
    @Binding var showQuestion: Bool
    let onAnswered: (Bool) -> Void
    let onSimplifiedQuestion: ((Question) -> Void)?
    
    @State private var selectedOption: Int?
    @State private var showExplanation = false
    @State private var animateCorrect: Bool = false
    @State private var animateIncorrect: Bool = false
    @State private var shake: Bool = false
    @State private var isGeneratingSimpler: Bool = false
    @State private var showLoadingView = false
    
    @Environment(\.dismiss) private var dismiss
    
    private func generateSimplerQuestion() async {
        isGeneratingSimpler = true
        showLoadingView = true
        
        do {
            if let newQuestion = try await OpenAIService.shared.generateQuestion(
                subject: question.subject,
                difficulty: question.difficulty,
                customPrompt: "ask a simpler version of this: \(question.question.displayText)"
            ) {
                // Call the completion handler with the new question
                onSimplifiedQuestion?(newQuestion)
                
                // Wait a moment for the animation to complete
                try? await Task.sleep(for: .seconds(0.6))
                
                // Hide the loading view first
                withAnimation {
                    showLoadingView = false
                    isGeneratingSimpler = false
                }
                
                // Wait for loading view to fade out
                try? await Task.sleep(for: .seconds(0.3))
                
                // Then dismiss the explanation overlay
                withAnimation {
                    showExplanation = false
                }
            }
        } catch {
            print("Failed to generate simpler question: \(error)")
            showLoadingView = false
            isGeneratingSimpler = false
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main question content
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Question text with math formatting
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Question:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if let text = question.question.text, !text.isEmpty {
                                Text(text)
                                    .font(.body)
                                    .padding(.bottom, 4)
                            }
                            if let math = question.question.originalMath {
                                MathView(content: math)
                                    .frame(minHeight: 60)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
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
                                // Calculate max height needed for any option
                                let maxHeight = question.question.displayOptions.reduce(CGFloat.zero) { maxHeight, option in
                                    let textHeight = (option as NSString).boundingRect(
                                        with: CGSize(width: geometry.size.width / 2 - 48, height: .infinity),
                                        options: .usesLineFragmentOrigin,
                                        attributes: [.font: UIFont.systemFont(ofSize: 17)],
                                        context: nil
                                    ).height
                                    return max(maxHeight, textHeight + 32)  // Add padding
                                }
                                
                                ForEach(question.question.displayOptions.indices, id: \.self) { index in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedOption = index
                                            let isCorrect = question.question.displayOptions[index] == question.question.correctAnswers.first
                                            
                                            if isCorrect {
                                                animateCorrect = true
                                                HapticManager.shared.success()
                                            } else {
                                                animateIncorrect = true
                                                shake = true
                                                HapticManager.shared.error()
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
                                            MathView(content: cleanMathContent(question.question.displayOptions[index]))
                                                .frame(height: max(maxHeight, 44))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(optionColor(for: index))
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
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
                                    // Incorrect/Correct indicator
                                    HStack {
                                        Image(systemName: selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? .green : .red)
                                        Text(selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? "Correct!" : "Incorrect")
                                            .font(.headline)
                                            .foregroundColor(selectedOption != nil && question.question.displayOptions[selectedOption!] == question.question.correctAnswers.first ? .green : .red)
                                    }
                                    
                                    Spacer()
                                    
                                    // Brainmaxx button - only show for incorrect answers
                                    if selectedOption != nil && question.question.displayOptions[selectedOption!] != question.question.correctAnswers.first {
                                        Button {
                                            Task {
                                                HapticManager.shared.buttonPress()
                                                await generateSimplerQuestion()
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                if isGeneratingSimpler {
                                                    ProgressView()
                                                        .scaleEffect(0.8)
                                                        .tint(.white)
                                                }
                                                Text(isGeneratingSimpler ? "simplifying..." : "brainmaxx")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(
                                                        .linearGradient(
                                                            colors: [
                                                                .white,
                                                                .white.opacity(0.8),
                                                                .white
                                                            ],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                ZStack {
                                                    // Animated gradient background
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [
                                                                    Color(red: 0.2, green: 0.4, blue: 1.0),
                                                                    Color(red: 0.4, green: 0.2, blue: 1.0),
                                                                    Color(red: 0.8, green: 0.2, blue: 0.8)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .opacity(isGeneratingSimpler ? 0.6 : 0.8)
                                                    
                                                    // Shiny overlay
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [
                                                                    .white.opacity(0.5),
                                                                    .clear,
                                                                    .white.opacity(0.2),
                                                                    .clear
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .opacity(isGeneratingSimpler ? 0.3 : 1)
                                                    
                                                    // Subtle border
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(
                                                            LinearGradient(
                                                                colors: [
                                                                    .white.opacity(0.6),
                                                                    .clear,
                                                                    .white.opacity(0.3)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                }
                                            )
                                            .overlay(
                                                // Glow effect
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                .blue.opacity(0.5),
                                                                .purple.opacity(0.5)
                                                            ],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ),
                                                        lineWidth: 2
                                                    )
                                                    .blur(radius: 2)
                                            )
                                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                            .scaleEffect(showExplanation ? 1 : 0.95)
                                            .opacity(isGeneratingSimpler ? 0.8 : 1)
                                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showExplanation)
                                            .animation(.easeInOut, value: isGeneratingSimpler)
                                        }
                                        .disabled(isGeneratingSimpler)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                
                                Text("Explanation:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                MathView(content: question.explanation.originalMath ?? question.explanation.displayText)
                                    .frame(minHeight: 60)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.vertical, 16)
                    .frame(minHeight: geometry.size.height - 40)
                }
            }
            
            // Loading overlay
            if showLoadingView {
                FuturisticLoadingView(
                    title: "Generating Simpler Question",
                    subtitle: "Using AI to break down the concept",
                    showSparkles: true
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .padding(.top, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1) // Ensure it stays on top
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
        onAnswered: { _ in },
        onSimplifiedQuestion: nil
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
        onAnswered: { _ in },
        onSimplifiedQuestion: nil
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
        onAnswered: { _ in },
        onSimplifiedQuestion: nil
    )
    .frame(height: 600)
}



