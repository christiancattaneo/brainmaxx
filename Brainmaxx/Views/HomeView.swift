import SwiftUI

struct HomeView: View {
    @StateObject private var dataService = DataService.shared
    @StateObject private var audioManager = AudioManager.shared
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var navigationPath = NavigationPath()
    @State private var showAIDialog = false
    @State private var selectedAISubject = ""
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var isEditingAISubjects = false
    @State private var showDeleteAllConfirmation = false
    
    // Animation states for the background
    @State private var animateGradient1 = false
    @State private var animateGradient2 = false
    
    // Get only AI-generated subjects
    private var aiGeneratedSubjects: [Subject] {
        dataService.subjects.filter { $0.id.hasPrefix("ai-") }
    }
    
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
                        
                        Text("Learn and Earn 💸💸")
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
                        BrainLoadingView()
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
                                    .overlay(
                                        Group {
                                            if isEditingAISubjects && subject.id.hasPrefix("ai-") {
                                                Button {
                                                    HapticManager.shared.buttonPress()
                                                    dataService.deleteAISubject(withID: subject.id)
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                        .font(.system(size: 24))
                                                        .background(Color.white.opacity(0.8))
                                                        .clipShape(Circle())
                                                }
                                                .padding(8)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(20)
                            
                            // Edit button for AI-generated subjects
                            if !aiGeneratedSubjects.isEmpty {
                                VStack(spacing: 12) {
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            isEditingAISubjects.toggle()
                                            HapticManager.shared.buttonPress()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: isEditingAISubjects ? "checkmark.circle.fill" : "pencil")
                                            Text(isEditingAISubjects ? "Done" : "Edit AI Subjects")
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(isEditingAISubjects ? Color.green : Color.blue)
                                        )
                                        .foregroundColor(.white)
                                    }
                                    
                                    if isEditingAISubjects {
                                        Button {
                                            HapticManager.shared.warning()
                                            showDeleteAllConfirmation = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "trash")
                                                Text("Delete All AI Subjects")
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(Color.red)
                                            )
                                            .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                        }
                        .alert("Delete All AI Subjects?", isPresented: $showDeleteAllConfirmation) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete All", role: .destructive) {
                                HapticManager.shared.buttonPress()
                                dataService.deleteAllAISubjects()
                                withAnimation {
                                    isEditingAISubjects = false
                                }
                            }
                        } message: {
                            Text("This will permanently delete all your AI-generated subjects and their questions. This action cannot be undone.")
                        }
                    }
                }
                
                // AI Section at bottom - moved outside the main VStack to hover above everything
                if let aiSubject = dataService.subjects.first(where: { $0.id == "ai" }) {
                    VStack {
                        Spacer()
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
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .contentShape(Rectangle())
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                HapticManager.shared.buttonPress()
                                showAIDialog = true
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAIDialog) {
            NavigationStack {
                AISubjectDialog(
                    selectedSubject: $selectedAISubject,
                    difficulty: selectedDifficulty,
                    navigationPath: $navigationPath
                )
            }
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
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

#Preview {
    HomeView()
} 
