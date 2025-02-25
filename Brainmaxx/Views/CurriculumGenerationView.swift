import SwiftUI

struct CurriculumGenerationView: View {
    let subject: Subject
    let difficulty: Difficulty
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath
    @StateObject private var dataService = DataService.shared
    @State private var currentNodeIndex = 0
    @State private var questions: [Question] = []
    @State private var errorMessage: String?
    
    private let totalNodes = 11 // Start node + 9 middle nodes + end node
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color(.systemBackground).ignoresSafeArea()
                    
                    // Main content with 3 sections: header, progress, footer
                    VStack(spacing: 0) {
                        // Header section
                        VStack(spacing: 16) {
                            Image(systemName: subject.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Generating Your Curriculum")
                                .font(.title2.bold())
                            
                            Text(subject.name)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Center section with progress line
                        Spacer()
                        
                        // Simple centered progress line
                        CleanProgressLine(
                            currentStep: currentNodeIndex,
                            totalSteps: 10
                        )
                        .frame(width: 50, height: 400)
                        .offset(x: 10)
                        
                        Spacer()
                        
                        // Footer section
                        VStack(spacing: 8) {
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                
                                Button("Try Again") {
                                    errorMessage = nil
                                    currentNodeIndex = 0
                                    questions = []
                                    generateQuestions()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Cancel") {
                                    dismiss()
                                }
                                .foregroundColor(.secondary)
                            } else {
                                Text("Generated \(currentNodeIndex) of 10 questions")
                                    .font(.headline)
                                Text("Using AI to create personalized questions")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            currentNodeIndex = 0
            generateQuestions()
        }
    }
    
    private func generateQuestions() {
        Task {
            do {
                for i in 0..<10 {
                    if let question = try await OpenAIService.shared.generateQuestion(
                        subject: subject.name,
                        difficulty: difficulty
                    ) {
                        await MainActor.run {
                            questions.append(question)
                            withAnimation(.spring(response: 0.3)) {
                                currentNodeIndex = i + 1
                            }
                        }
                    }
                }
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.3)) {
                        currentNodeIndex = totalNodes - 1
                    }
                    
                    var updatedSubject = subject
                    updatedSubject.updateTopics(["Generated": questions])
                    dataService.addOrUpdateAISubject(updatedSubject)
                    
                    // Wait a moment to show completion, then dismiss both views
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Reset navigation path to return to home screen
                        navigationPath = NavigationPath()
                        
                        // Dismiss the generation view first
                        dismiss()
                        
                        // Post notification to dismiss the parent AI dialog too
                        NotificationCenter.default.post(name: .dismissAIDialog, object: nil)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Add the notification name
extension Notification.Name {
    static let dismissAIDialog = Notification.Name("dismissAIDialog")
}

// A clean, simple progress line with nodes
struct CleanProgressLine: View {
    let currentStep: Int
    let totalSteps: Int
    
    private let lineWidth: CGFloat = 3
    private let smallNodeSize: CGFloat = 12
    private let largeNodeSize: CGFloat = 30
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top node (checkmark)
                NodeView(
                    isActive: currentStep >= totalSteps,
                    size: largeNodeSize,
                    color: currentStep >= totalSteps ? .green : .gray.opacity(0.3),
                    systemName: "checkmark"
                )
                
                // Connection lines and middle nodes
                ForEach(0..<totalSteps-1, id: \.self) { index in
                    ZStack {
                        // Only show line for active segments - no grey background
                        if currentStep >= totalSteps - 1 - index {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple.opacity(0.8)],
                                    startPoint: .bottom, 
                                    endPoint: .top
                                ))
                                .frame(width: lineWidth)
                        }
                            
                        // Middle node at the top of this segment
                        if index < totalSteps - 2 {
                            VStack {
                                Spacer()
                                NodeView(
                                    isActive: currentStep >= totalSteps - 2 - index,
                                    size: smallNodeSize,
                                    color: currentStep >= totalSteps - 2 - index ? .blue : .gray.opacity(0.3)
                                )
                            }
                        }
                    }
                    .frame(height: max(1, (geo.size.height - largeNodeSize * 2) / CGFloat(totalSteps - 1)))
                }
                
                // Bottom node (sparkles)
                NodeView(
                    isActive: true,
                    size: largeNodeSize,
                    color: .blue,
                    systemName: "sparkles"
                )
            }
            .frame(height: geo.size.height)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
    }
}

// Reusable node component
struct NodeView: View {
    let isActive: Bool
    let size: CGFloat
    let color: Color
    var systemName: String? = nil
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .shadow(color: isActive ? color.opacity(0.5) : .clear, radius: 3)
            
            if let systemName = systemName {
                Image(systemName: systemName)
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
} 
