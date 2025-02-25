import SwiftUI

struct AISubjectDialog: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSubject: String
    let difficulty: Difficulty
    @Binding var navigationPath: NavigationPath
    @State private var subjectInput = ""
    @State private var selectedSymbol = "sparkles.rectangle.stack"
    @State private var showCurriculumGeneration = false
    @State private var isSymbolLoading = false
    @FocusState private var isInputFocused: Bool
    
    // Set these to true by default and don't expose as toggles
    private let autoSelectSymbol = true
    private let useAI = true
    
    // Common subject symbols
    private let subjectSymbols = [
        "sparkles.rectangle.stack",  // Default AI/Learning
        "book.fill",              // General education
        "function",               // Math
        "textformat",             // Language
        "atom",                   // Science
        "globe.americas.fill",    // Geography
        "heart",                  // Health/Medicine
        "brain",                  // Psychology/Neuroscience
        "music.note",             // Music
        "paintpalette",           // Art
        "chart.bar",              // Statistics/Data
        "leaf",                   // Biology/Nature
        "building.columns",       // History/Architecture
        "desktopcomputer",        // Computing
        "flask",                  // Chemistry
        "star",                   // Astronomy/Space
        "figure.run",             // Sports
        "film",                   // Film/Media
        "theatermasks.fill",      // Drama/Theatre
        "briefcase",              // Business
        "network",                // Networks/Social
        "dna",                    // Genetics
        "camera",                 // Photography
        "mountain.2",             // Geography/Geology
        "brain.head.profile"      // Psychology/AI
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Image(systemName: selectedSymbol)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    if isSymbolLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                    }
                }
                
                Text("What would you like to learn?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Create a personalized curriculum!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
            
            // Subject Input
            TextField("e.g. Quantum Physics, World History, Poetry...", text: $subjectInput)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .onChange(of: subjectInput) { oldValue, newValue in
                    if autoSelectSymbol && !newValue.isEmpty {
                        updateSymbol()
                    }
                }
                .onSubmit {
                    if !subjectInput.isEmpty {
                        createSubject()
                    }
                }
                .padding(.horizontal)
            
            // Icon Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(subjectSymbols, id: \.self) { symbol in
                        Button {
                            selectedSymbol = symbol
                            // Keep manual selection capability without changing state
                        } label: {
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
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Generate Button
            Button {
                createSubject()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Questions")
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
            .padding(.horizontal)
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            isInputFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAIDialog)) { _ in
            // When curriculum generation completes, dismiss this dialog too
            dismiss()
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
    
    private func updateSymbol() {
        // Clear any previous update delays
        Task {
            if useAI && autoSelectSymbol && !subjectInput.isEmpty {
                isSymbolLoading = true
                
                // Use async version with OpenAI
                let suggestedSymbol = await SymbolSelector.selectSymbolAsync(
                    for: subjectInput,
                    availableSymbols: subjectSymbols
                )
                
                // Update UI on main thread
                await MainActor.run {
                    selectedSymbol = suggestedSymbol
                    isSymbolLoading = false
                }
            } else if autoSelectSymbol && !subjectInput.isEmpty {
                // Use sync version without OpenAI
                let suggestedSymbol = SymbolSelector.selectSymbolSync(for: subjectInput)
                
                if subjectSymbols.contains(suggestedSymbol) {
                    selectedSymbol = suggestedSymbol
                } else {
                    selectedSymbol = subjectSymbols[0]
                }
            }
        }
    }
    
    private func createSubject() {
        let trimmedInput = subjectInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        if autoSelectSymbol {
            // Do one final symbol update if auto-select is on
            if !isSymbolLoading {
                // Only if we're not already loading a symbol
                Task {
                    await updateSymbolFinal()
                    await MainActor.run {
                        showCurriculumGeneration = true
                    }
                }
            }
        } else {
            showCurriculumGeneration = true
        }
    }
    
    private func updateSymbolFinal() async {
        if useAI && !subjectInput.isEmpty {
            isSymbolLoading = true
            
            // Use async version with OpenAI
            let suggestedSymbol = await SymbolSelector.selectSymbolAsync(
                for: subjectInput,
                availableSymbols: subjectSymbols
            )
            
            // Update UI on main thread
            await MainActor.run {
                selectedSymbol = suggestedSymbol
                isSymbolLoading = false
            }
        } else if !subjectInput.isEmpty {
            // Use sync version without OpenAI
            let suggestedSymbol = SymbolSelector.selectSymbolSync(for: subjectInput)
            
            if subjectSymbols.contains(suggestedSymbol) {
                selectedSymbol = suggestedSymbol
            } else {
                selectedSymbol = subjectSymbols[0]
            }
        }
    }
}

#Preview {
    NavigationStack {
        AISubjectDialog(
            selectedSubject: .constant(""),
            difficulty: .medium,
            navigationPath: .constant(NavigationPath())
        )
    }
} 