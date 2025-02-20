import SwiftUI

// Futuristic AI background animation
struct AIGlowingBackground: View {
    @State private var animate = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            // Animated overlay gradients
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 150, height: 150)
                .blur(radius: 20)
                .offset(x: animate ? 100 : -100, y: 0)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
            
            // Pulsing circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale)
                .blur(radius: 5)
        }
        .onAppear {
            // Start the horizontal animation
            animate = true
            
            // Start the pulsing animation
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.2
            }
        }
    }
}

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
    @StateObject private var audioManager = AudioManager.shared
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var navigationPath = NavigationPath()
    @State private var showAIDialog = false
    @State private var selectedAISubject = ""
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    // Animation states for the background
    @State private var animateGradient1 = false
    @State private var animateGradient2 = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // First animated gradient layer
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.2),
                        Color.indigo.opacity(0.3)
                    ],
                    startPoint: animateGradient1 ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient1 ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(
                    Animation.easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true),
                    value: animateGradient1
                )
                
                // Second animated gradient layer
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.2),
                        Color.blue.opacity(0.2),
                        Color.cyan.opacity(0.2)
                    ],
                    startPoint: animateGradient2 ? .topTrailing : .bottomLeading,
                    endPoint: animateGradient2 ? .bottomLeading : .topTrailing
                )
                .ignoresSafeArea()
                .animation(
                    Animation.easeInOut(duration: 4.0)
                        .repeatForever(autoreverses: true),
                    value: animateGradient2
                )
                .blendMode(.plusLighter)
                
                // Main content
                VStack(spacing: 0) {
                    // Title and Description
                    VStack(spacing: 24) {
                        // Centered title
                        VStack(spacing: 16) {
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
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 2)
                            
                            Text("brainmaxx")
                                .font(.system(size: 40, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Learn and Earn! 💸💸")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
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
                        HapticManager.shared.selectionChanged()
                        dataService.setDifficulty(newDifficulty)
                    }
                    .padding(.bottom, 20)
                    
                    // Subjects Grid or Error
                    if dataService.loadingError != nil {
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles.rectangle.stack")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .padding(.bottom, 8)
                            
                            Text("No Questions Available")
                                .font(.title3.bold())
                            
                            Text("Try selecting a different difficulty level")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button {
                                dataService.reloadQuestions()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
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
                            .padding(.top, 8)
                        }
                        .padding()
                        .frame(maxHeight: .infinity)
                    } else if dataService.subjects.isEmpty {
                        FuturisticLoadingView()
                            .frame(maxHeight: .infinity)
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
                            .padding(20)
                            .padding(.bottom, 100)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    // AI Section at bottom
                    if let aiSubject = dataService.subjects.first(where: { $0.id == "ai" }) {
                        HStack(spacing: 16) {
                            // Icon with pulsing effect
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: aiSubject.iconName)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Questions")
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
                            ZStack {
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                AIGlowingBackground()
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .padding(.bottom, safeAreaInsets.bottom)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                HapticManager.shared.buttonPress()
                                showAIDialog = true
                            }
                        }
                    }
                }
                .background(Color(.systemBackground))
                
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
            .onAppear {
                print("🏠 HomeView appeared")
                
                // Start the animations with slight delays
                withAnimation {
                    animateGradient1 = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        animateGradient2 = true
                    }
                }
                
                // Start playing background music
                print("🎵 Starting background music from HomeView")
                audioManager.playBackgroundMusic()
            }
        }
    }
}

// Create new CurriculumGenerationView
struct CurriculumGenerationView: View {
    let subject: Subject
    let difficulty: Difficulty
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath
    @StateObject private var dataService = DataService.shared
    @State private var currentNodeIndex = 0
    @State private var questions: [Question] = []
    @State private var errorMessage: String?
    
    private let totalNodes = 11
    private let pathWidth: CGFloat = 2
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .overlay {
                VStack(spacing: 24) {
                            // Icon and Title
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
                            .padding(.top, 32)
                            
                            Spacer()
                            
                            // Progress Nodes
                            ProgressNodesView(
                                currentNodeIndex: currentNodeIndex,
                                totalNodes: totalNodes,
                                geometry: geometry
                            )
                            
                            Spacer()
                            
                            // Status
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
                            .padding(.bottom, 32)
                        }
                        .padding()
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
                            }
                        }
                    }
                }
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.3)) {
                        currentNodeIndex += 1
                    }
                    
                    var updatedSubject = subject
                    updatedSubject.updateTopics(["Generated": questions])
                    dataService.addOrUpdateAISubject(updatedSubject)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        navigationPath = NavigationPath()
                        dismiss()
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

// Progress Nodes View Component
private struct ProgressNodesView: View {
    let currentNodeIndex: Int
    let totalNodes: Int
    let geometry: GeometryProxy
    
    private let pathWidth: CGFloat = 2
    
    private var sizes: (nodeSize: CGFloat, largeNodeSize: CGFloat, spacing: CGFloat) {
        let screenHeight = geometry.size.height
        let baseNodeSize = screenHeight * 0.015
        let baseLargeNodeSize = baseNodeSize * 2
        let baseSpacing = screenHeight * 0.04
        
        return (
            nodeSize: max(8, min(baseNodeSize, 16)),
            largeNodeSize: max(16, min(baseLargeNodeSize, 32)),
            spacing: max(24, min(baseSpacing, 40))
        )
    }
    
    private var totalLineHeight: CGFloat {
        CGFloat(totalNodes - 1) * sizes.spacing
    }
    
    private var progressHeight: CGFloat {
        if currentNodeIndex >= totalNodes - 1 {
            return totalLineHeight
        }
        return CGFloat(currentNodeIndex) * (totalLineHeight / CGFloat(totalNodes - 1))
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                // Background line
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: pathWidth)
                    .frame(height: totalLineHeight)
                
                // Animated progress line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .blue,
                                .purple
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: pathWidth)
                    .frame(height: progressHeight)
                
                // Nodes
                VStack(spacing: sizes.spacing) {
                    // End node (top)
                    Circle()
                        .fill(currentNodeIndex >= totalNodes - 1 ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: sizes.largeNodeSize, height: sizes.largeNodeSize)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: sizes.largeNodeSize * 0.5, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(currentNodeIndex >= totalNodes - 1 ? 1 : 0)
                        )
                    
                    // Middle nodes
                    ForEach((1...9).reversed(), id: \.self) { index in
                        Circle()
                            .fill(currentNodeIndex >= index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: sizes.nodeSize, height: sizes.nodeSize)
                    }
                    
                    // Start node (bottom)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: sizes.largeNodeSize, height: sizes.largeNodeSize)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: sizes.largeNodeSize * 0.5, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(height: totalLineHeight)
            .frame(maxHeight: geometry.size.height * 0.4)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressHeight)
        }
    }
}

// Subject Card View
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

// AI Subject Dialog
struct AISubjectDialog: View {
    @Binding var isPresented: Bool
    @Binding var selectedSubject: String
    let difficulty: Difficulty
    @Binding var navigationPath: NavigationPath
    @State private var subjectInput = ""
    @State private var selectedSymbol = "sparkles.rectangle.stack"
    @State private var showCurriculumGeneration = false
    @FocusState private var isInputFocused: Bool
    
    // Common subject symbols
    private let subjectSymbols = [
        "sparkles.rectangle.stack",  // Default AI/Learning
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
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Main content
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Close button
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    isPresented = false
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            .padding(.bottom, -8)
                        }
                        .padding(.horizontal, 20)
                        
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
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .frame(maxWidth: min(geometry.size.width - 48, 400))
                    .frame(height: min(max(geometry.size.height * 0.7, 400), 600))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
        .fullScreenCover(isPresented: $showCurriculumGeneration) {
            CurriculumGenerationView(
                subject: Subject.createAISubject(
                    id: "ai-\(subjectInput.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    name: subjectInput,
                    description: "AI-generated \(subjectInput) curriculum",
                    iconName: selectedSymbol
                ),
                difficulty: difficulty,
                navigationPath: $navigationPath
            )
        }
    }
    
    private func createSubject() {
        let trimmedInput = subjectInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        showCurriculumGeneration = true
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

// Futuristic Loading Animation
struct FuturisticLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 0.6
    @State private var innerRotation: Double = 0
    @State private var sparkleOffset: CGFloat = 0
    
    var title: String = "Generating Questions"
    var subtitle: String = "Using AI to create your curriculum"
    var showSparkles: Bool = true
    
    var body: some View {
        ZStack {
            // Outer rotating ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Inner rotating elements
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12, height: 12)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(index) * 120))
                    .rotationEffect(.degrees(innerRotation))
            }
            
            // Center pulsing dot
            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
                .scaleEffect(scale)
            
            if showSparkles {
                // Floating sparkles
                ForEach(0..<5) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat.random(in: 8...14)))
                        .foregroundColor(.blue.opacity(0.6))
                        .offset(
                            x: CGFloat.random(in: -50...50),
                            y: -sparkleOffset + CGFloat(index * 20)
                        )
                        .animation(
                            Animation
                                .easeInOut(duration: Double.random(in: 1.5...2.5))
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: sparkleOffset
                        )
                }
            }
            
            // Loading text
            VStack(spacing: 12) {
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Start animations
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: false)
            ) {
                innerRotation = 360
            }
            
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
                opacity = 1
                sparkleOffset = 40
            }
        }
    }
}

#Preview {
    HomeView()
} 
