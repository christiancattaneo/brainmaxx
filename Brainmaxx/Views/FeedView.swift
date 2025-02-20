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
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 1)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            
            if dataService.isGeneratingQuestions {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Generating questions...")
                        .font(.headline)
                    Text("Using AI to create new questions for you")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else if let error = dataService.loadingError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Error")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    VStack(spacing: 8) {
                        Button {
                            Task {
                                // Reload questions and try again
                                dataService.reloadQuestions()
                                questions = await dataService.getQuestionsForCurrentSelection()
                            }
                        } label: {
                            Label("Try Again", systemImage: "arrow.clockwise")
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button("Return to Home") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else if questions.isEmpty {
                VStack(spacing: 16) {
                    FuturisticLoadingView(
                        title: "Loading Questions",
                        subtitle: "Finding questions at your level",
                        showSparkles: false
                    )
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
                                    VStack(spacing: 0) {
                                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                            ForEach(Array(questions.enumerated()).reversed(), id: \.element.id) { index, question in
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
                                                            if index > 0 {
                                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                                    currentIndex = index - 1
                                                                    scrollProxy.scrollTo(questions[currentIndex].id, anchor: .bottom)
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
                                                    },
                                                    onSimplifiedQuestion: { newQuestion in
                                                        // Insert the simplified question after the current one
                                                        if let currentIndex = questions.firstIndex(where: { $0.id == question.id }) {
                                                            withAnimation(.spring(response: 0.6)) {
                                                                questions.insert(newQuestion, at: currentIndex)
                                                                // Update current index to point to the new question
                                                                self.currentIndex = questions.count - currentIndex - 1
                                                            }
                                                            
                                                            // Scroll to the new question after a brief delay
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                                    scrollProxy.scrollTo(newQuestion.id, anchor: .center)
                                                                }
                                                            }
                                                        }
                                                    }
                                                )
                                                .frame(width: geometry.size.width - 40, height: geometry.size.height - 40)
                                                .id(question.id)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height - 40)
                                .clipShape(Rectangle())
                                .scrollDisabled(true)  // Disable manual scrolling
                            }
                            .ignoresSafeArea(.keyboard)  // Prevent keyboard from pushing content
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
            print("📚 FeedView appeared for subject: \(subject.name) with difficulty: \(difficulty.displayName)")
            if subject.name.lowercased() == "english" && difficulty == .hard {
                print("🎯 Hard English selected - will attempt to generate questions if none available")
            }
            dataService.selectSubject(subject)
        }
        .onChange(of: currentProgress) { _, progress in
            if progress >= 1.0 {
                showResults = true
            }
        }
        // Add navigation path observer
        .onChange(of: navigationPath) { _, newPath in
            if newPath.isEmpty {
                dismiss()
            }
        }
        .fullScreenCover(isPresented: $showResults) {
            if let result = quizResult {
                ResultsView(navigationPath: $navigationPath, quizResult: result)
            }
        }
        .task {
            print("🔄 Starting async question loading for \(subject.name) (\(difficulty.displayName))")
            
            // Create tasks for loading delay and questions
            async let questionsLoad = dataService.getQuestionsForCurrentSelection()
            
            // Add a minimum loading time of 2 seconds for better UX
            do {
                try await Task.sleep(for: .seconds(2))
                questions = await questionsLoad
                print("✅ Finished loading questions. Count: \(questions.count)")
            } catch {
                print("⚠️ Loading interrupted: \(error.localizedDescription)")
                questions = await questionsLoad
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
                .padding(.vertical, 32) // Add padding to shorten the bar
            
            // Progress fill
            GeometryReader { geometry in
                Rectangle()
                    .fill(progressColor(animatedProgress))
                    .frame(height: max(0, min(geometry.size.height - 64, (geometry.size.height - 64) * animatedProgress))) // Adjust for padding
                    .frame(maxWidth: 32, maxHeight: .infinity, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical, 32) // Match padding with background
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
            .padding(.top, 8)
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
