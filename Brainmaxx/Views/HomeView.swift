import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.toEdgeInsets() ?? .init()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

extension UIEdgeInsets {
    func toEdgeInsets() -> EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

struct HomeView: View {
    @StateObject private var dataService = DataService.shared
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var navigationPath = NavigationPath()
    @State private var showAIDialog = false
    @State private var selectedAISubject = ""
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Title and Description
                        VStack(spacing: 24) {
                            HStack(spacing: 16) {
                                Group {
                                    if let image = UIImage(named: "brain-lightbulb") {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                    } else {
                                        Image(systemName: "sparkles.rectangle.stack")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.blue)
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 2)
                                
                                Text("brainmaxx")
                                    .font(.system(size: 36, weight: .bold))
                            }
                            
                            Text("Choose a subject to begin your SAT prep journey")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 32)
                        
                        // Difficulty Selector
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.displayName)
                                    .tag(difficulty)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .onChange(of: selectedDifficulty) { _, newDifficulty in
                            print("🎚️ Difficulty changed to: \(newDifficulty.displayName)")
                            dataService.setDifficulty(newDifficulty)
                        }
                        
                        // Subjects Grid or Error
                        if let error = dataService.loadingError {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text(error)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    dataService.reloadQuestions()
                                } label: {
                                    Label("Reload", systemImage: "arrow.clockwise")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                        } else if dataService.subjects.isEmpty {
                            // Loading state
                            ProgressView("Loading subjects...")
                                .padding()
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(dataService.subjects.filter { $0.id != "ai" }) { subject in
                                        NavigationLink {
                                            FeedView(
                                                navigationPath: $navigationPath,
                                                subject: subject,
                                                difficulty: selectedDifficulty
                                            )
                                        } label: {
                                            SubjectCard(subject: subject, difficulty: selectedDifficulty)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                        }
                    }
                    
                    Spacer()
                    
                    // AI Section at bottom
                    if let aiSubject = dataService.subjects.first(where: { $0.id == "ai" }) {
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                // Icon
                                Image(systemName: aiSubject.iconName)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(aiSubject.name)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Tap to create your own curriculum...")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                            .padding(.bottom, 8 + (safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom : 16))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    showAIDialog = true
                                }
                            }
                        }
                        .edgesIgnoringSafeArea(.bottom)
                    }
                }
                
                // AI Subject Dialog
                if showAIDialog {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .blur(radius: 2)
                    
                    AISubjectDialog(
                        isPresented: $showAIDialog,
                        selectedSubject: $selectedAISubject,
                        difficulty: selectedDifficulty,
                        navigationPath: $navigationPath
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
            .onChange(of: navigationPath) { oldPath, newPath in
                if newPath.isEmpty {
                    dataService.selectSubject(nil)
                    selectedDifficulty = .medium
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .returnToHome)) { _ in
                withAnimation {
                    navigationPath = NavigationPath()
                    dataService.selectSubject(nil)
                    selectedDifficulty = .medium
                }
            }
        }
    }
}

// AI Subject Dialog View
struct AISubjectDialog: View {
    @Binding var isPresented: Bool
    @Binding var selectedSubject: String
    let difficulty: Difficulty
    @Binding var navigationPath: NavigationPath
    @State private var subjectInput = ""
    @State private var isLoading = false
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showLoadingView = false
    @State private var selectedSymbol = "sparkles.rectangle.stack"
    
    // Common subject symbols
    private let subjectSymbols = [
        "sparkles.rectangle.stack",  // Default AI/Learning (changed from brain.head.profile)
        "book.fill",              // General education
        "function",               // Math
        "textformat",             // Language
        "atom",                   // Science
        "globe.americas.fill",    // Geography
        "clock.fill",             // History
        "paintpalette.fill",      // Art
        "music.note",             // Music
        "figure.run",             // Physical Education
        "keyboard",               // Computer Science
        "leaf.fill",              // Biology
        "flame.fill",             // Chemistry
        "star.fill",              // Astronomy
        "books.vertical.fill",    // Literature
        "wand.and.stars",         // Magic/Special
    ]
    
    var body: some View {
        ZStack {
            if showLoadingView {
                AILoadingView(
                    subject: Subject.createAISubject(
                        id: "ai-\(subjectInput.lowercased().replacingOccurrences(of: " ", with: "-"))",
                        name: subjectInput,
                        description: "AI-generated \(subjectInput) curriculum",
                        iconName: selectedSymbol
                    ),
                    difficulty: difficulty,
                    navigationPath: $navigationPath,
                    dataService: DataService.shared
                )
            } else {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: selectedSymbol)
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .padding(.bottom, 8)
                        
                        Text("What would you like to learn?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Enter any subject and I'll create a personalized curriculum for you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Subject Input and Symbol Picker
                    VStack(spacing: 16) {
                        TextField("", text: $subjectInput)
                            .placeholder(when: subjectInput.isEmpty) {
                                Text("e.g. Quantum Physics, World History, Poetry...")
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 18))
                            .padding(.horizontal)
                            .focused($isInputFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isInputFocused = true
                                }
                            }
                            .submitLabel(.go)
                            .onSubmit {
                                createSubject()
                            }
                        
                        // Symbol Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(subjectSymbols, id: \.self) { symbol in
                                    Image(systemName: symbol)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedSymbol == symbol ? .white : .blue)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            selectedSymbol == symbol ? 
                                                Color.blue : 
                                                Color.blue.opacity(0.1)
                                        )
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedSymbol = symbol
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Generate Button
                        Button {
                            createSubject()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Generate Questions")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
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
                        .disabled(subjectInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(subjectInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                        .padding(.horizontal)
                    }
                    
                    // Cancel button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isPresented = false
                        }
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                    }
                }
                .padding(24)
                .frame(maxWidth: min(UIScreen.main.bounds.width - 48, 400))
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
            }
        }
    }
    
    private func createSubject() {
        let trimmedInput = subjectInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3)) {
            showLoadingView = true
        }
    }
}

// Helper view extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Navigation Destination
struct FeedDestination: Hashable {
    let subject: Subject
    let difficulty: Difficulty
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(subject.id)
        hasher.combine(difficulty)
    }
    
    static func == (lhs: FeedDestination, rhs: FeedDestination) -> Bool {
        lhs.subject.id == rhs.subject.id && lhs.difficulty == rhs.difficulty
    }
}

struct SubjectCard: View {
    let subject: Subject
    let difficulty: Difficulty
    
    private var isAISection: Bool {
        subject.id == "ai"
    }
    
    private var cardGradient: LinearGradient {
        if isAISection {
            return LinearGradient(
                colors: [
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var iconBackground: Color {
        if isAISection {
            return .white.opacity(0.2)
        } else {
            return Color.blue.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        isAISection ? .white : .primary
    }
    
    private var secondaryTextColor: Color {
        isAISection ? .white.opacity(0.8) : .secondary
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: subject.iconName)
                .font(.system(size: 32))
                .foregroundColor(isAISection ? .white : .blue)
                .frame(width: 56, height: 56)
                .background(iconBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isAISection ? .white.opacity(0.3) : .clear, lineWidth: 1)
                )
                .padding(.top, 8)
            
            // Title
            Text(subject.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
            
            // Description
            Text(subject.description)
                .font(.system(size: 14))
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            
            // Question count or AI badge
            Group {
                if isAISection {
                    Label("AI Generated", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                } else {
            Text("\(subject.getQuestions(forDifficulty: difficulty).count) questions")
                .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
            }
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardGradient)
                .shadow(radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isAISection ? .white.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .overlay(
            Group {
                if isAISection {
                    // Animated sparkles effect
                    SparklesOverlay()
                }
            }
        )
    }
}

// Animated sparkles overlay for AI section
struct SparklesOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(x: CGFloat(i * 20 - 20), y: isAnimating ? -10 : 0)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// AI Loading View
struct AILoadingView: View {
    let subject: Subject
    let difficulty: Difficulty
    @Binding var navigationPath: NavigationPath
    @State private var currentNodeIndex = 0
    @State private var pathProgress: CGFloat = 0
    @State private var questions: [Question] = []
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    let dataService: DataService
    
    private let totalNodes = 11 // 1 start + 9 middle + 1 end
    private let nodeSize: CGFloat = 12
    private let largeNodeSize: CGFloat = 24
    private let pathWidth: CGFloat = 2
    private let spacing: CGFloat = 40 // Increased for better visibility
    
    private var progressLineHeight: CGFloat {
        // Calculate the exact height needed between nodes
        let totalSpacing = spacing * CGFloat(totalNodes - 1)
        let adjustedProgress = CGFloat(currentNodeIndex) / CGFloat(totalNodes - 1)
        return totalSpacing * adjustedProgress
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .padding(.bottom, 4)
                    
                    Text("Generating Your Curriculum")
                        .font(.title3.bold())
                    
                    Text("\(subject.name)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Vertical Path with Nodes
                ZStack(alignment: .top) {
                    // Progress line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: pathWidth)
                        .frame(height: progressLineHeight)
                        .frame(maxHeight: CGFloat(totalNodes - 1) * spacing, alignment: .bottom)
                    
                    // Nodes
                    VStack(spacing: spacing) {
                        // End node (top)
                        Circle()
                            .fill(currentNodeIndex >= totalNodes - 1 ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: largeNodeSize, height: largeNodeSize)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(currentNodeIndex >= totalNodes - 1 ? 1 : 0)
                            )
                        
                        // Middle nodes
                        ForEach((1...9).reversed(), id: \.self) { index in
                            Circle()
                                .fill(currentNodeIndex >= index ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: nodeSize, height: nodeSize)
                        }
                        
                        // Start node (bottom)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: largeNodeSize, height: largeNodeSize)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .frame(height: CGFloat(totalNodes - 1) * spacing)
                .frame(maxHeight: geometry.size.height * 0.6)
                .padding(.vertical, 24)
                
                Spacer(minLength: 0)
                
                // Status text
                VStack(spacing: 8) {
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
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
                        .padding(.top, 8)
                    } else {
                        Text("Generated \(currentNodeIndex) of 10 questions")
                            .font(.headline)
                        Text("Using AI to create personalized questions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .onAppear {
            generateQuestions()
        }
    }
    
    private func generateQuestions() {
        Task {
            do {
                for _ in 0..<10 {
                    if let question = try await OpenAIService.shared.generateQuestion(
                        subject: subject.name,
                        difficulty: difficulty
                    ) {
                        await MainActor.run {
                            questions.append(question)
                            withAnimation(.spring(response: 0.3)) {
                                currentNodeIndex += 1
                                pathProgress = CGFloat(currentNodeIndex) / CGFloat(totalNodes - 1)
                            }
                        }
                    }
                }
                
                // All questions generated successfully
                await MainActor.run {
                    withAnimation(.spring(response: 0.3)) {
                        currentNodeIndex += 1 // Move to final node
                        pathProgress = 1.0
                    }
                    
                    // Create updated subject with generated questions
                    var updatedSubject = subject
                    updatedSubject.updateTopics(["Generated": questions])
                    
                    // Save to DataService
                    dataService.addOrUpdateAISubject(updatedSubject)
                    
                    // Return to home screen after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // First clear the navigation stack
                        navigationPath = NavigationPath()
                        // Then dismiss this view after a brief delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                dismiss()
                            }
                        }
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

#Preview {
    HomeView()
} 
