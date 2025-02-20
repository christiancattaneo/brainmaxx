import SwiftUI

struct FeedView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataService = DataService.shared
    @Binding var navigationPath: NavigationPath
    
    let subject: Subject
    let difficulty: Difficulty
    
    @State private var showResults = false
    @State private var currentIndex = 0
    @State private var answeredQuestions: Set<String> = []
    @State private var showScrollIndicator = false
    @State private var totalPoints: Int = 0
    @State private var questions: [Question] = []
    
    private var currentProgress: Double {
        let totalCount = questions.count
        guard totalCount > 0 else { return 0 }
        return Double(answeredQuestions.count) / Double(totalCount)
    }
    
    private var quizResult: QuizResult? {
        QuizResult(
            subject: subject,
            difficulty: difficulty,
            answeredQuestions: questions.filter { answeredQuestions.contains($0.id) },
            totalQuestions: questions.count
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProgressHeader(
                points: totalPoints,
                totalQuestions: questions.count,
                difficulty: difficulty
            )
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 1)
            )
            .padding(.horizontal, 8)
            
            if questions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("No questions available")
                        .font(.headline)
                    Text("Please try a different difficulty level")
                        .foregroundColor(.secondary)
                    Button("Return to Home") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            // Progress Bar
                            ProgressBarView(progress: currentProgress)
                                .frame(width: 32)
                                .frame(maxHeight: .infinity)
                                .padding(.leading, 8)
                            
                            // Main Feed
                            ScrollViewReader { scrollProxy in
                                ScrollView(.vertical, showsIndicators: false) {
                                    LazyVStack(spacing: 0) {
                                        ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                                            QuestionView(
                                                question: question,
                                                showQuestion: .constant(true),
                                                onAnswered: { isCorrect in
                                                    // Mark question as answered
                                                    answeredQuestions.insert(question.id)
                                                    
                                                    // Update points
                                                    if isCorrect {
                                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                                            totalPoints += 20
                                                        }
                                                        
                                                        // Show scroll indicator after correct answer
                                                        withAnimation {
                                                            showScrollIndicator = true
                                                        }
                                                        
                                                        // Auto-scroll to next question (if not the last one)
                                                        if index > 0 {  // Changed from index < questions.count - 1
                                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                                currentIndex = index - 1  // Changed from index + 1
                                                                scrollProxy.scrollTo(questions[currentIndex].id, anchor: .bottom)  // Changed anchor to .bottom
                                                            }
                                                        }
                                                        
                                                        // Hide indicator after delay
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                            withAnimation {
                                                                showScrollIndicator = false
                                                            }
                                                        }
                                                    }
                                                    
                                                    // Check if all questions are answered
                                                    if answeredQuestions.count == questions.count {
                                                        showResults = true
                                                    }
                                                }
                                            )
                                            .frame(width: geometry.size.width - 40, height: geometry.size.height)
                                            .id(question.id)
                                            .overlay(alignment: .bottom) {
                                                if showScrollIndicator && answeredQuestions.contains(question.id) && index > 0 {
                                                    ScrollIndicator()
                                                        .transition(.opacity)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            // Load questions when view appears
            questions = Array(subject.getQuestions(forDifficulty: difficulty))  // Remove .reversed()
        }
        .onChange(of: currentProgress) { _, progress in
            if progress >= 1.0 {
                showResults = true
            }
        }
        .fullScreenCover(isPresented: $showResults) {
            if let result = quizResult {
                ResultsView(navigationPath: $navigationPath, quizResult: result)
            }
        }
    }
}

struct ProgressBarView: View {
    let progress: Double
    
    @State private var animatedProgress: Double = 0
    @State private var showPulse: Bool = false
    
    private func progressColor(_ progress: Double) -> Color {
        let hue = progress * 0.7 // Scale from 0 to 0.7 to get red->blue->yellow
        return Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }
    
    var body: some View {
        ZStack {
            // Background track
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(maxWidth: 32)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Progress fill
            GeometryReader { geometry in
                Rectangle()
                    .fill(progressColor(animatedProgress))
                    .frame(height: max(0, min(geometry.size.height, geometry.size.height * animatedProgress)))
                    .frame(maxWidth: 32, maxHeight: .infinity, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .allowsHitTesting(false)
            }
            
            // Progress percentage
            VStack {
                Text(String(format: "%.0f%%", min(max(0, progress * 100), 100)))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(progressColor(progress))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .opacity(progress > 0 ? 1 : 0)
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .onChange(of: progress) { _, newProgress in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newProgress
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Supporting Views
struct ScrollIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "chevron.up")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.blue)
                .offset(y: isAnimating ? -8 : 0)
            Text("Scroll up for next question")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.9))
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    FeedView(
        navigationPath: .constant(NavigationPath()),
        subject: Subject(
            id: "math-preview",
            name: "Mathematics",
            description: "Math practice questions",
            iconName: "function",
            topics: [:]
        ),
        difficulty: .medium
    )
} 
